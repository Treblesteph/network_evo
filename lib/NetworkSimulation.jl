module NetworkSimulation

import Multichoose.multichoose, BoolNetwork.Network

export Network, runsim

# Performs a dynamic simuation for a network which is encoded by a matrix
# of interactions (where P_ij specifies the path from node i to node j).

function make_decision_mat(nnodes::Int64, defaulton::Bool)
# This function makes a matrix containing all of the possible scenarios for
# time t (columns 1:end-1), and their resultant effect on the initial condition
# i.e. giving the state at time t + 1 in the last column.
  genes_i = 1:nnodes            # Column indices for gene values.
  paths_i = 1+nnodes:2*nnodes   # Column indices for path values.
  input_i = 1+2*nnodes          # Column index for environmental input.
  envpath_i = 2+2*nnodes        # Column index for environmental path.
  gate_i = 3+2*nnodes           # Column index for logic gate.
  init_i = 4+2*nnodes           # Column index for initial value.
  # Range of values that each column can take.
  genechoices::Array{Array{Int64}} = [[0, 1] for i in 1:nnodes]
  pathchoices::Array{Array{Int64}} = [[0, 1, -1] for i in 1:nnodes]
  inputchoices::Array{Array{Int64}} = Array[[0, 1]]
  envpathchoices::Array{Array{Int64}} = Array[[0, 1]]
  gatechoices::Array{Array{Int64}} = Array[[0, 1]] # 0 = or; 1 = and.
  initchoices::Array{Array{Int64}} = Array[[0, 1]]
  allchoices::Array{Array{Int64}} = [genechoices, pathchoices, inputchoices,
                                     envpathchoices, gatechoices, initchoices]
  # Scenariomat is all combinations of genes, gene paths, inputs, environment
  # paths, gates, and initial conditions - i.e. all possible scenarios.
  scenariomat::Array{Int64, 2} = multichoose(allchoices, 0)
  # Decision array will become the last column of decision matrix, it is the
  # column determining the state at time t + 1 based on the scenariomat.
  decisionarray::Array{Int64, 1} = decision_array(scenariomat, genes_i,
                                                  paths_i, input_i,
                                                  envpath_i, gate_i,
                                                  init_i, defaulton)
  decisionmat::Array{Int64, 2} = hcat(scenariomat, decisionarray)
  decdict = Dict{Array{Int64}, Int64}()
  for r in 1:size(decisionmat, 1)
    row = decisionmat[r, :]
    key = row[1:end-1]
    value = row[end]
    decdict[key] = value
  end
  return decdict
end

function decision_array(scenariomat::Array{Int64}, genes_i, paths_i, input_i,
                        envpath_i, gate_i, init_i, defaulton)
  decisionarray::Array{Int64, 1} = zeros(Int64, size(scenariomat, 1))
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
    thisrowpaths::Array{Int64} = scenariomat[d, paths_i]
    thisrowenvpath::Int64 = scenariomat[d, envpath_i]
    thisrowgenes::Array{Int64} = scenariomat[d, genes_i]
    thisrowinput::Int64 = scenariomat[d, input_i]

    actcount::Int64 = length(find(y -> y == 1, scenariomat[d, paths_i])) +
                      thisrowenvpath
    acteffect::Int64 = sum(thisrowpaths[find(x -> x == 1, thisrowpaths)] .*
                           thisrowgenes[find(x -> x == 1, thisrowpaths)]) +
                       (thisrowenvpath * thisrowinput)
    repcount::Int64 = length(find(y -> y == -1, scenariomat[d, paths_i]))
    repeffect::Int64 = - sum(thisrowpaths[find(x -> x == -1, thisrowpaths)] .*
                             thisrowgenes[find(x -> x == -1, thisrowpaths)])


    # CASE 1: Initially the target gene is off.
    if scenariomat[d, init_i] == 0

    # CASE 1.1: Target initially off, "or" logic gate.
      if scenariomat[d, gate_i] == 0

    # CASE 1.1.1: Gene default off.
        if defaulton == 0

    # CASE 1.1.1.1: Target init off, "or" gate, overall activation.
          if repeffect < acteffect

            decisionarray[d] = 1

    # CASE 1.1.1.2: Target init off, "or" gate, overall not activation.
          else

            decisionarray[d] = 0

          end

    # CASE 1.1.2: Gene default on.
        elseif defaulton == 1

    # CASE 1.1.2.1: Target init off, "or" gate, overall not repression.
          if repeffect <= acteffect

            decisionarray[d] = 1

    # CASE 1.1.2.2: Target init off, "or" gate, overall repression.
          else

            decisionarray[d] = 0

          end

    # CASE 1.1.2.3: Default on not Bool error.
        else

          error("defaulton must be Bool type.")

        end

    # CASE 1.2: Target init off, "and" gate.
      elseif scenariomat[d, gate_i] == 1

    # CASE 1.2.1: Gene default off.
        if defaulton == 0

    # CASE 1.2.1.1: Target init off, "and" gate, overall activation.
          if (actcount == acteffect) && (actcount > 0) &&
             ((repeffect < acteffect) || (repeffect < repcount))

             decisionarray[d] = 1

    # CASE 1.2.1.2: Target init off, "and" gate, overall not activation.
          else

            decisionarray[d] = 0

          end

    # CASE 1.2.2: Gene default on.
        elseif defaulton == 1

    # CASE 1.2.2.1: Target init off, "and" gate, overall not repression.
          if ((repcount > repeffect) || (repcount == 0)) ||
             ((actcount == acteffect) && (actcount > repcount))

             decisionarray[d] = 1

    # CASE 1.2.2.2: Target init off, "and" gate, overall repression.
          else

            decisionarray[d] = 0

          end

    # CASE 1.2.2.3: Default on not Bool error.
      else

        error("defaulton must be Bool type.")

      end

    # CASE 1.3: Error - target off, non-boolean logic gate.
      else

        error("Logic gate should take on a boolean value (zero or one).")

      end

    # CASE 2: Initially the target gene is on.
    elseif scenariomat[d, init_i] == 1

    # CASE 2.1: Target initially on, "or" logic gate.
      if scenariomat[d, gate_i] == 0

    # CASE 2.1.1: Gene default off.
        if defaulton == 0

    # CASE 2.1.1.1: Target init on, "or" gate, overall activation.
          if repeffect < acteffect

            decisionarray[d] = 1

    # CASE 2.1.1.2: Target init on, "or" gate, overall activation.
          else

            decisionarray[d] = 0

          end

    # CASE 2.1.2: Gene default on.
        elseif defaulton == 1

    # CASE 2.1.2.1: Target init on, "or" gate, overall not repression.
          if repeffect <= acteffect

            decisionarray[d] = 1

    # CASE 2.1.2.2: Target init on, "or" gate, overall repression.
          else

            decisionarray[d] = 0

          end

    # CASE 2.1.2.3: Default on not Bool error.
        else

          error("defaulton must be Bool type.")

        end

    # CASE 2.2: Target initially on, "and" logic gate.
      elseif scenariomat[d, gate_i] == 1

    # CASE 2.2.1: Gene default off.
        if defaulton == 0

    # CASE 2.2.1.1: Target init on, "and" gate, overall activation.
        if ((actcount == acteffect) && (actcount > 0)) &&
           ((repeffect < acteffect) || (repeffect < repcount))

          decisionarray[d] = 1

    # CASE 2.2.1.2: Target init on, "and" gate, overall not activation.
        else

          decisionarray[d] = 0

        end

    # CASE 2.2.2: Gene default on.
      elseif defaulton == 1

    # CASE 2.2.2.1: Target init on, "and" gate, overall not repression.
        if ((repcount > repeffect) || (repcount == 0)) ||
           ((actcount == acteffect) && (actcount > repcount))

           decisionarray[d] = 1

    # CASE 2.2.2.2: Target init on, "and" gate, overall repression.
        else

          decisionarray[d] = 0

        end

    # CASE 2.2.2.3: Default on not Bool error.
      else

        error("defaulton must be Bool type.")

      end

    # CASE 2.3: Error - target on, non-boolean logic gate.
      else

        error("Logic gate should take on a boolean value (zero or one).")

      end

    # CASE 3: Error - initial target gene not boolean.
    else

      error("Target gene should be 0 or 1 initially in boolean framework.")

    end

  end

  return decisionarray

end

function runsim(net::Network, params::Dict)

  # Making an array of length allmins which indicates whether the environmental
  # signal is on or off (because the argument envsignal is a list of indices).
  environ_signal::Array{Int64} = zeros(Int64, params["allmins"])
  environ_signal[params["envsignal"]] = 1

  # Extracting network properties for ease of use.
  paths::Array{Array{Int64}} = copy(net.paths)
  envpaths::Array{Int64} = copy(net.envpath)
  lags::Array{Int64} = copy(net.lags)
  envlag::Array{Int64} = copy(net.envlag)
  gates::Array{Int64} = copy(net.gates)

  # Making matrix containing all gene concentrations over time (plus history
  # of zeros to simulate the lags).
  concs::Array{Int64} = zeros(Int64, params["maxlag"] +
                              params["allmins"], params["nnodes"])

  # Setting initial concentrations, and history, according to defaults.
  if params["defaulton"] == 1
    concs[params["maxlag"] + 1, :] = ones(Int64, params["nnodes"])
    history = ones(Int64, params["maxlag"])
  elseif params["defaulton"] == 0
    concs[params["maxlag"] + 1, :] = zeros(Int64, params["nnodes"])
    history = zeros(Int64, params["maxlag"])
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

  for t in 1:(params["allmins"] - 1) # First row is initial condition.

    # Take all current and previous concentrations, all incoming paths and
    # their lags, and the gate type, to determine the next concentration.

    ncount = 0 # Determines what path/lag index to use from the 1D arrays.
    genes::Array{Int64} = zeros(Int64, params["nnodes"])
    path::Array{Int64} = zeros(Int64, params["nnodes"])
    for k in 1:params["nnodes"]
      genes[k] = concs[params["maxlag"] + t - lags[ncount + k], k]
      path[k] = paths[ncount + k][params["maxlag"] + t - lags[ncount + k]]
      ncount += params["nnodes"]
    end

    for nd in 1:params["nnodes"]
      envpath::Array{Int64} = [envpaths[nd]]
      envinput::Array{Int64} = [environ_signal[params["allmins"] + t - envlag[nd]]]
      gate::Array{Int64} = [gates[nd]]
      init::Array{Int64} = [concs[params["maxlag"] + t, nd]]
      # Next will compare this row to the rows in decision matrix to determine
      # the next state of gene nd.
      decisionrow::Array{Int64, 1} = [genes, path, envpath, envinput,
                                      gate, init]
      concs[t + params["maxlag"] + 1, nd] = params["decisionhash"][decisionrow]
    end
  end
  concs = concs[params["maxlag"]+1:end, :]
end

end # NetworkSimulation
