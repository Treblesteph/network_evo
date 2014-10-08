# Performs a dynamic simuation for a network which is encoded by a matrix
# of interactions (where P_ij specifies the path from node i to node j).
include("multichoose.jl");

function make_decision_mat(nnodes::Int64)
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
                                                  envpath_i, gate_i, init_i)
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
                        envpath_i, gate_i, init_i)
  decisionarray::Array{Int64, 1} = zeros(Int64, size(scenariomat, 1))
  for d in 1:length(decisionarray)
    # Pathcount is the number of interactions present, and effectsum is the
    # overall effect of all of the path values and gene concentrations. Then,
    # for an `or' gate, if the effectsum exceeds 0 (or < 0) then the gene will
    # switch on from off (or off from on). For `and' gates, the effectsum must
    # exceed the path count in order to have an effect.
    pathcount::Int64 = sum(scenariomat[d, paths_i]) + scenariomat[d, envpath_i]
    effectsum::Int64 = sum(scenariomat[d, genes_i] .*
                           scenariomat[d, paths_i]) +
                       sum(scenariomat[d, input_i] .*
                           scenariomat[d, envpath_i])
    # Case 1: Initially the target gene is off.
    if scenariomat[d, init_i] == 0
    # Case 1.1: Target initially off, "or" logic gate.
      if scenariomat[d, gate_i] == 0
    # Case 1.1.1: Target initially off, "or" logic gate, overall activation.
        if effectsum > 0.
          decisionarray[d] = 1
    # Case 1.1.2: Target initially off, "or" logic gate, overall not activation.
        else
          decisionarray[d] = 0
        end
    # Case 1.2: Target initially off, "and" logic gate.
    elseif scenariomat[d, gate_i] == 1
    # Case 1.2.1: Target initially off, "and" logic gate, all paths activate.
        if pathcount == effectsum
          decisionarray[d] = 1
    # Case 1.2.2: Target initially off, "and" logic gate, not all paths activate.
        else
          decisionarray[d] = 0
        end
    # Case 1.3: Error - target off, non-boolean logic gate.
      else
        error("Logic gate should take on a boolean value (zero or one).")
      end
    # Case 2: Initially the target gene is on.
    elseif scenariomat[d, init_i] == 1
    # Case 2.1: Target initially on, "or" logic gate.
      if scenariomat[d, gate_i] == 0
    # Case 2.1.1: Target initially on, "or" logic gate, overall repression.
        if effectsum < 0
          decisionarray[d] = 0
    # Case 2.1.2: Target initially on, "or" logic gate, overall not repression.
        else
          decisionarray[d] = 1
        end
    # Case 2.2: Target initially on, "and" logic gate.
    elseif scenariomat[d, gate_i] == 1
    # Case 2.2.1: Target initially on, "and" logic gate, all paths repress.
        if effectsum == -pathcount
          decisionarray[d] = 0
    # Case 2.2.2: Target initially on, "and" logic gate, not all paths repress.
        else
          decisionarray[d] = 1
        end
    # Case 2.3: Error - target on, non-boolean logic gate.
      else
        error("Logic gate should take on a boolean value (zero or one).")
      end
    # Case 3: Error - initial target gene not boolean.
    else
      error("Target gene should be 0 or 1 initially in boolean framework.")
    end
  end
  return decisionarray
end

function dynamic_simulation(net::Network, nnode::Int64, allmins::Int64,
                            maxlag::Int64, envsignal::Array{Int64},
                            dec_hash::Dict)
  # Making an array of length allmins which indicates whether the environmental
  # signal is on or off.
  environ_signal::Array{Int64} = zeros(Int64, allmins)
  environ_signal[envsignal] = 1
  # Extracting network properties for ease of use.
  paths::Array{Array{Int64}} = copy(net.paths)
  envpaths::Array{Int64} = copy(net.envpath)
  lags::Array{Int64} = copy(net.lags)
  gates::Array{Int64} = copy(net.gates)
  timearray::Array{Int64} = [1:allmins]
  concs::Array{Int64} = zeros(Int64, allmins, nnode)
  concs[1, :] = zeros(Int64, nnode)
  concs = vcat(zeros(Int64, maxlag, nnode), concs)
  # Adding maxlag zeros to the beginning of path vectors.
  for i in 1:length(paths)
    history = zeros(Int64, maxlag)
    paths[i] = [history, paths[i]]
  end
  for nd in 1:nnode
    for t in timearray[1:end-1] # First row is initial condition (already set).
      # Take all current and previous concentrations, all incoming paths and
      # their lags, and the gate type, to determine the next concentration.
      genes::Array{Int64} = [concs[maxlag+t-lags[nd, jj], jj] for jj in 1:NNODES]
      path::Array{Int64} = [paths[nd, k][maxlag+t-lags[nd, k]] for k in 1:NNODES]
      envpath::Array{Int64} = [envpaths[nd]]
      envinput::Array{Int64} = [environ_signal[t]]
      gate::Array{Int64} = [gates[nd]]
      init::Array{Int64} = [concs[maxlag+t, nd]]
      # Next will compare this row to the rows in decision matrix to determine
      # the next state of gene nd.
      decisionrow::Array{Int64, 1} = [genes, path, envpath, envinput,
                                      gate, init]
      concs[t+maxlag+1, nd] = dec_hash[decisionrow]
    end
  end
  concs = concs[maxlag+1:end, :]
end
