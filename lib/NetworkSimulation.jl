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
  envpath_i = 1+2*nnodes          # Column index for environmental path.
  input_i = 2+2*nnodes        # Column index for environmental input.
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

  for t in 1:(allmins - 1) # First row is initial condition.

    # Take all current and previous concentrations, all incoming paths and
    # their lags, and the gate type, to determine the next concentration.

    ncount = 0 # Determines what path/lag index to use from the 1D arrays.

    for nd in 1:nnodes

      for k in 1:nnodes
        twithlag::Int64 = maxlag + t - lags[ncount + k]
        decisionrow[k] = concs[twithlag, k] # Genes
        decisionrow[k + nnodes] = paths[ncount + k][twithlag] # Paths
      end
      ncount += nnodes

      buffer = nnodes * 2
      decisionrow[buffer + 1] = envpaths[nd] # Environmental paths
      decisionrow[buffer + 2] = environ_signal[allmins + t - envlag[nd]]
      decisionrow[buffer + 3] = gates[nd]
      decisionrow[buffer + 4] = concs[maxlag + t, nd] # This gene init.

      # Next will compare this row to the rows in decision matrix to determine
      # the next state of gene nd.
      concs[t + maxlag + 1, nd] = decisionhash[decisionrow]
    end
  end
  concs = concs[maxlag+1:end, :]
end
