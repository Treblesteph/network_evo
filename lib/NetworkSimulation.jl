import Multichoose.multichoose

export runsim

# Performs a dynamic simuation for a network which is encoded by a matrix
# of interactions (where P_ij specifies the path from node i to node j).

function make_decision_mat(nnodes::Int64, defaulton::Bool)
# This function makes a matrix containing all of the possible scenarios for
# time t (columns 1:end-1), and their resultant effect on the initial condition
# i.e. giving the state at time t + 1 in the last column.
  genes_i = 1:nnodes            # Column indices for gene values.
  paths_i = 1+nnodes:2*nnodes   # Column indices for path values.
  envpath_i = 1+2*nnodes        # Column index for environmental path.
  input_i = 2+2*nnodes          # Column index for environmental input.
  gate_i = 3+2*nnodes           # Column index for logic gate.
  init_i = 4+2*nnodes           # Column index for initial value.
  # Range of values that each column can take.
  genechoices = [Bool[0, 1] for i in 1:nnodes]
  pathchoices = [Int8[0, 1, -1] for i in 1:nnodes]
  inputchoices = Array[Bool[0, 1]]
  envpathchoices = Array[Bool[0, 1]]
  gatechoices = Array[Bool[0, 1]] # 0 = or; 1 = and.
  initchoices = Array[Bool[0, 1]]
  allchoices = [convert(Array{Array{Int64}}, genechoices),
                convert(Array{Array{Int64}}, pathchoices),
                convert(Array{Array{Int64}}, inputchoices),
                convert(Array{Array{Int64}}, envpathchoices),
                convert(Array{Array{Int64}}, gatechoices),
                convert(Array{Array{Int64}}, initchoices)]
  # Scenariomat is all combinations of genes, gene paths, inputs, environment
  # paths, gates, and initial conditions - i.e. all possible scenarios.
  scenariomat::Array{Int64, 2} = multichoose(allchoices, 0)
  # Decision array will become the last column of decision matrix, it is the
  # column determining the state at time t + 1 based on the scenariomat.
  decisionarray::Array{Bool, 1} = decision_array(scenariomat, genes_i,
                                                  paths_i, envpath_i,
                                                  input_i,gate_i,
                                                  init_i, defaulton)
  decdict = Dict{Array{Number}, Bool}()
  for r in 1:size(scenariomat, 1)
    key = scenariomat[r, :][:]
    value = decisionarray[r]
    decdict[key] = value
  end
  return decdict
end

function decision_array(scenariomat::Array{Int64}, genes_i, paths_i, envpath_i,
                        input_i, gate_i, init_i, defaulton)
  decisionarray::Array{Bool, 1} = zeros(Int64, size(scenariomat, 1))
  for d in 1:length(decisionarray)

    # actcount is the number of incoming activator paths
    # acteffect is the number of active incoming activator paths
    # repcount is the number of incoming repressor paths
    # repeffect is the number of active incoming repressor paths

    # netact and netrep depend on logic gate status:
    # - 'or' gates require that activate/repress effect >= 1
    # - 'and' gates require that activate/repress count == a/r effect

    # This captures the requirements that an 'or' gate needs at least
    # one active path, whereas an 'and' gate requires that all present
    # paths are active.

    # Shortcut names:
    thisrowpaths = scenariomat[d, paths_i]
    thisrowenvpath = scenariomat[d, envpath_i]
    thisrowgenes = scenariomat[d, genes_i]
    thisrowinput = scenariomat[d, input_i]

    pathonindex = find(x -> x == 1, thisrowpaths)
    pathoffindex = find(y -> y == -1, thisrowpaths)

    actcount::Int64 = length(pathonindex) + thisrowenvpath
    acteffect::Int64 = sum(thisrowpaths[pathonindex] .*
                           thisrowgenes[pathonindex]) +
                       (thisrowenvpath * thisrowinput)

    repcount::Int64 = length(pathoffindex)
    repeffect::Int64 = - sum(thisrowpaths[pathoffindex] .*
                             thisrowgenes[pathoffindex])


    # CASE 1: "or" logic gate.
    if scenariomat[d, gate_i] == 0

    # CASE 1.1: Gene default off.
      if defaulton == 0

    # CASE 1.1.1: Gene default off, "or" gate, overall activation.
        if repeffect < acteffect

          decisionarray[d] = 1

    # CASE 1.1.2: Gene default off, "or" gate, overall not activation.
        else

          decisionarray[d] = 0

        end

    # CASE 1.2: Gene default on.
      elseif defaulton == 1

    # CASE 1.2.1: Gene default on, "or" gate, overall not repression.
        if repeffect <= acteffect

          decisionarray[d] = 1

    # CASE 1.2.2: Gene default on, "or" gate, overall repression.
        else

          decisionarray[d] = 0

        end

    # CASE 1.2.3: Default on not Bool error.
      else

        error("defaulton must be Bool type.")

      end

    # CASE 2: "and" gate.
    elseif scenariomat[d, gate_i] == 1

    # CASE 2.1: Gene default off.
      if defaulton == 0

    # CASE 2.1.1: Gene default off, "and" gate, overall activation.
        if (actcount == acteffect) && (actcount > 0) &&
           ((repeffect < acteffect) || (repeffect < repcount))

           decisionarray[d] = 1

    # CASE 2.1.2: Gene default off, "and" gate, overall not activation.
        else

          decisionarray[d] = 0

        end

    # CASE 2.2: Gene default on.
      elseif defaulton == 1

    # CASE 2.2.1: Gene default on, "and" gate, overall not repression.
        if ((repcount > repeffect) || (repcount == 0)) ||
           ((actcount == acteffect) && (actcount > repcount))

           decisionarray[d] = 1

    # CASE 2.2.2: Gene default on, "and" gate, overall repression.
        else

          decisionarray[d] = 0

        end

    # CASE 2.2.3: Default on not Bool error.
    else

      error("defaulton must be Bool type.")

    end

    # CASE 3: Error - non-boolean logic gate.
    else

      error("Logic gate should take on a boolean value (zero or one).")

    end

  end

  return decisionarray

end

function runsim(net::Network, params::Dict)
  # Naming variables from parameter hash for speed.
  nnodes::Int64 = params["nnodes"]
  maxlag::Int64 = params["maxlag"]
  allmins::Int64 = params["allmins"]
  decisionhash::Dict = params["decisionhash"]


  # Making an array of length allmins which indicates whether the environmental
  # signal is on or off (because the argument envsignal is a list of indices).
  environ_signal::Array{Int64} = zeros(Int64, allmins)
  for pp in params["envsignal"]
    environ_signal[pp] = 1
  end

  # Extracting network properties for ease of use.
  paths::Array{Array{Int64}} = copy(net.paths)
  envpaths::Array{Int64} = net.envpath
  lags::Array{Int64} = net.lags
  envlag::Array{Int64} = net.envlag
  gates::Array{Int64} = net.gates

  # Making matrix containing all gene concentrations over time (plus history
  # of zeros to simulate the lags).
  concs = zeros(Bool, maxlag + allmins, nnodes)

  # Setting initial concentrations, and history, according to defaults.
  if params["defaulton"] == 1
    concs[maxlag + 1, :] = ones(Bool, nnodes)
    history = ones(Int64, maxlag)
  elseif params["defaulton"] == 0
    concs[maxlag + 1, :] = zeros(Bool, nnodes)
    history = zeros(Int64, maxlag)
  else
    error("Defaulton must be a boolean value.")
  end

  # Adding history to the beginning of path vectors (to deal with lags).

  for i in 1:length(paths)
    paths[i] = [history, paths[i]]
  end

  # Making environmental signal longer than simulation so that it can be used
  # for lags into history.
  environ_signal = [environ_signal, environ_signal]

  decisionrow = Array(Int64, nnodes * 2 + 4)

  # Sampling time according to lag intervals.
  sampletimes = get_sample_times(allmins, lags, envlag, params["envsignal"])

  if sampletimes[1] == 1
    sampletimes = sampletimes[2:end]
  end

  samplecount = 1

  for t in 2:allmins # Initial condition (at t = 1) is already set.

    # If the time point is not in sampletimes, don't change anything.
    if samplecount > length(sampletimes)
      concs[t + maxlag, :] = concs[t + maxlag - 1, :]
    else
      if (t != sampletimes[samplecount])
        concs[t + maxlag, :] = concs[t + maxlag - 1, :]

      # If the time point is in sampletimes, update according to decisionrow.
      else

        samplecount += 1

        # Take all current and previous concentrations, all incoming paths and
        # their lags, and the gate type, to determine the next concentration.

        ncount = 0 # Determines what path/lag index to use from the 1D arrays.

        # Loop through nodes to fill their concentrations in turn.
        for nd in 1:nnodes

          # Loop through all nodes to determine how they affect node nd.
          for k in 1:nnodes

            # Previous time point (taking lag into account too).
            twithlag::Int64 = maxlag + t - 1 - lags[ncount + k]

            # Fill all gene values from previous time point into decisionrow.
            decisionrow[k] = concs[twithlag, k]

            # Fill all path values from previous time point into decisionrow.
            decisionrow[k + nnodes] = paths[ncount + k][twithlag]

          end

          # Increment ncount by nnodes to start on genes/paths for next node.
          ncount += nnodes

          # Buffer is the space filled in decisionrow by gene and paths values.
          buffer = nnodes * 2

          # Fill envpath value (time invariable) into decisionrow.
          decisionrow[buffer + 1] = envpaths[nd]

          # Fill env signal value from previous time point into decisionrow.
          decisionrow[buffer + 2] = environ_signal[allmins + t - 1 - envlag[nd]]

          # Fill gate value (time invariable) into decisionrow.
          decisionrow[buffer + 3] = gates[nd]

          # Fill value for this gene at previous time point into decisionrow.
          decisionrow[buffer + 4] = concs[maxlag + t - 1, nd]

          # Compare this row to the rows in decision matrix to determine
          # the next state of gene nd.
          concs[t + maxlag, nd] = decisionhash[decisionrow]
        end
      end
    end
  end

  # Delete history from the beginning of concs matrix.
  concs = concs[maxlag+1:end, :]

end

function get_sample_times(allmins, lags, envlag, envsignal)

  sampletimes = Int64[]

  # Add 1 to the array so the initial state is always calculated.
  push!(sampletimes, 1)

  uniquelags = unique(lags)

  # Discard any lags that are multiples of others.
  sortedlags = sort(uniquelags, rev=true)
  keeplags = [sortedlags[end]] # smallest lag can't be a multiple

  for i in (length(sortedlags) - 1)
    lag = sortedlags[i]
    smallerlags = sortedlags[(i + 1):end]
    push!(keeplags, smallerlags[find(x -> lag % x != 0, smallerlags)]...)
  end

  # For each remaining lag add all multiples up to allmins to sampletimes.
  for lag in keeplags
    i = 1
    while i <= allmins
      next = lag * i
      if next < allmins
        push!(sampletimes, next)
      end
      i += 1
    end
  end

  # For every time when envsignal changes, add it to the sample time array
  # and add envlag so it corresponds to when the change has an effect.
  changepoints = detect_changepoints(envsignal)

  push!(sampletimes, map(x -> x + envlag[1], changepoints)...)

  # Sort the sample times and return the unique ordered values.
  return unique(sort(sampletimes))
end

function detect_changepoints(envsignal)

  changepoints = Int64[]

  # Flatten and iterate through envsignal (an array of arrays).
  # Whenever two entries, A and B, are non-consecutive,
  # A+1 and B are changepoints

  last = 0
  for t in vcat(envsignal...)
    if t - last > 1
      # Non-consecutive entries
      push!(changepoints, last + 1)
      push!(changepoints, t)
    end
    last = t
  end

  return unique(changepoints)
end
