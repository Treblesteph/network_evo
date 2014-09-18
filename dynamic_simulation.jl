# Performs a dynamic simuation for a network which is encoded by a matrix
# of interactions (where P_ij specifies the path from node i to node j).
include("multichoose.jl");

function make_decision_mat(NNODES)
# This function makes a matrix containing all of the possible scenarios for
# time t (columns 1:end-1), and their resultant effect on the initial condition
# i.e. giving the state at time t + 1 in the last column.
  genes_i = 1:NNODES            # Column indices for gene values.
  paths_i = 1+NNODES:2*NNODES   # Column indices for path values.
  input_i = 1+2*NNODES          # Column index for environmental input.
  gate_i = 2+2*NNODES           # Column index for logic gate.
  init_i = 3+2*NNODES           # Column index for initial value.
  # Range of values that each column can take.
  genechoices::Array{Array{Int64}} = [[0, 1] for i in 1:NNODES]
  pathchoices::Array{Array{Int64}} = [[0, 1, -1] for i in 1:NNODES]
  inputchoices::Array{Array{Int64}} = Array[[0, 1]]
  gatechoices::Array{Array{Int64}} = Array[[0, 1]] # 0 = or; 1 = and.
  initchoices::Array{Array{Int64}} = Array[[0, 1]]
  allchoices::Array{Array{Int64}} = [genechoices, pathchoices, inputchoices,
                                     gatechoices, initchoices]
  # Scenariomat is all combinations of genes, paths, inputs, gates, and
  # initial conditions - i.e. all possible scenarios.
  scenariomat::Array{Int64, 2} = multichoose(allchoices)
  # Decision array will become the last column of decision matrix, it is the
  # column determining the state at time t + 1 based on the scenariomat.
  decisionarray::Array{Int64, 1} = decision_array(scenariomat, genes_i, paths_i,
                                                  input_i, gate_i, init_i)
  decisionmat::Array{Int64, 2} = hcat(scenariomat, decisionarray)
  return decisionmat
end

function decision_array(scenariomat, genes_i, paths_i, input_i, gate_i, init_i)
  decisionarray::Array{Int64, 1} = zeros(Int64, size(scenariomat, 1))
  for d in 1:length(decisionarray)
    pathcount::Int64 = sum(scenariomat[d, paths_i])
    effectsum::Int64 = sum(scenariomat[d, genes_i] .* scenariomat[d, paths_i])
    ############### Case 1: Initially the target gene is off. ################
    if scenariomat[d, init_i] == 0
      ########## Case 1.1: Target initially off, "or" logic gate. ############
      if scenariomat[d, gate_i] == 0
        if effectsum > 0
          decisionarray[d] = 1
        else
          decisionarray[d] = 0
        end
      ########## Case 1.2: Target initially off, "and" logic gate. ###########
    elseif scenariomat[d, gate_i] == 1
        if pathcount == effectsum
          decisionarray[d] = 1
        else
          decisionarray[d] = 0
        end
      ########## Case 1.3: Error - target off, non-boolean logic gate. #######
      else
        error("Logic gate should take on a boolean value (zero or one).")
      end
    ############### Case 2: Initially the target gene is on.  ################
  elseif scenariomat[d, init_i] == 1
      ########## Case 2.1: Target initially on, "or" logic gate. #############
      if scenariomat[d, gate_i] == 0
        if effectsum < 0
          decisionarray[d] = 0
        else
          decisionarray[d] = 1
        end
      ########## Case 2.2: Target initially on, "and" logic gate. ############
    elseif scenariomat[d, gate_i] == 1
        if effectsum == -pathcount
          decisionarray[d] = 0
        else
          decisionarray[d] = 1
        end
      ########## Case 2.3: Error - target on, non-boolean logic gate. ########
      else
        error("Logic gate should take on a boolean value (zero or one).")
      end
    ########### Case 3: Error - initial target gene not boolean. #############
    else
      error("Target gene should be 0 or 1 initially in boolean framework.")
    end
  end
  return decisionarray
end

function dynamic_simulation(net, NNODES, ALLMINS, MAXLAG, ENVIRON)
  # Generating decision matrix
  #TODO: This only really needs to be made once, currently it is remade each
  #      time a dynamic simulation is run.
  decmat = make_decision_mat(NNODES)
  decdict = Dict{Array{Int64}, Int64}()
  for r in 1:size(decmat, 1)
    row = decmat[r, :]
    key = row[1:end-1]
    value = row[end]
    decdict[key] = value
  end
  # Making an array of length ALLMINS which indicates whether the environmental
  # signal is on or off.
  environ_signal::Array{Int64} = zeros(Int64, ALLMINS)
  environ_signal[ENVIRON] = 1
  # Extracting network properties for ease of use.
  paths::Array{Array{Int64}} = copy(net.paths)
  inputs::Array{Int64} = copy(net.inputs)
  lags::Array{Int64} = copy(net.lags)
  gates::Array{Int64} = copy(net.gates)
  timearray::Array{Int64} = [1:ALLMINS]
  concs::Array{Int64} = zeros(Int64, ALLMINS, NNODES)
  concs[1, :] = ones(NNODES);
  concs = vcat(zeros(Int64, MAXLAG, NNODES), concs)
  # Adding MAXLAG zeros to the beginning of path vectors.
  for i in 1:length(paths)
    history = zeros(Int64, MAXLAG)
    paths[i] = [history, paths[i]]
  end
  for nd in 1:NNODES
    for t in timearray[1:end-1] # First row is initial condition (already set).
      # Take all current and previous concentrations, all incoming paths and
      # their lags, and the gate type, to determine the next concentration.
      genes::Array{Int64} = [concs[MAXLAG+t-lags[nd, jj], jj] for jj in 1:NNODES]
      path::Array{Int64} = [paths[nd, k][MAXLAG+t-lags[nd, k]] for k in 1:NNODES]
      gate::Array{Int64} = [gates[nd]]
      input::Array{Int64} = [inputs[nd]]
      init::Array{Int64} = [concs[MAXLAG+t, nd]]
      # Next will compare this row to the rows in decision matrix to determine
      # the next state of gene nd.
      decisionrow::Array{Int64, 1} = [genes, path, input, environ_signal[t],
                                      gate, init]
      concs[t+MAXLAG+1, nd] = decdict[decisionrow]
    end
  end
  concs = concs[MAXLAG+1:end, :]
end
