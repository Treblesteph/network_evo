# Performs a dynamic simuation for a network which is encoded by a matrix
# of interactions (where P_ij specifies the path from node i to node j).

include("multichoose.jl");

function make_decision_mat(NNODES)
  genes = 1:NNODES
  paths = NNODES+1:2*NNODES
  gates = 1+2*NNODES
  inits = 2+2*NNODES
  genechoices::Array{Array{Int64}} = [[0, 1] for i in 1:NNODES]
  pathchoices::Array{Array{Int64}} = [[0, 1, -1] for i in 1:NNODES]
  gatechoices::Array{Array{Int64}} = Array[[0, 1]] # 0 = or; 1 = and.
  initchoices::Array{Array{Int64}} = Array[[0, 1]]
  allchoices::Array{Array{Int64}} = [genechoices, pathchoices,
                                     [gatechoices], [initchoices]]
  scenariomat::Array{Int64, 2} = multichoose(allchoices)
  decisionarray::Array{Int64, 1} = decision_array(scenariomat, genes,
                                                  paths, gates, inits)
  decisionmat::Array{Int64, 2} = hcat(scenariomat, decisionarray)
  return decisionmat
end

function decision_array(scenariomat, genes, paths, gates, inits)
  decisionarray::Array{Int64, 1} = zeros(Int64, size(scenariomat, 1))
  for d in 1:length(decisionarray)
    pathcount::Int64 = sum(scenariomat[d, paths])
    effectsum::Int64 = sum(scenariomat[d, genes] .* scenariomat[d, paths])
    ############### Case 1: Initially the target gene is off. ################
    if scenariomat[d, inits] == 0
      ########## Case 1.1: Target initially off, "or" logic gate. ############
      if scenariomat[d, gates] == 0
        if effectsum > 0
          decisionarray[d] = 1
        else
          decisionarray[d] = 0
        end
      ########## Case 1.2: Target initially off, "and" logic gate. ###########
    elseif scenariomat[d, gates] == 1
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
  elseif scenariomat[d, inits] == 1
      ########## Case 2.1: Target initially on, "or" logic gate. #############
      if scenariomat[d, gates] == 0
        if effectsum < 0
          decisionarray[d] = 0
        else
          decisionarray[d] = 1
        end
      ########## Case 2.2: Target initially on, "and" logic gate. ############
    elseif scenariomat[d, gates] == 1
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

function dynamic_simulation(net)
  # Generating decision matrix
  decmat = make_decision_mat(NNODES)
  decdict = Dict{Array{Int64}, Int64}()
  for r in 1:size(decmat, 1)
    row = decmat[r, :]
    key = row[1:end-1]
    value = row[end]
    decdict[key] = value
  end
  # Extracting network properties for ease of use.
  paths::Array{Array{Int64}} = copy(net.paths)
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
      init::Array{Int64} = [concs[MAXLAG+t, nd]]
      # Next will compare this row to the rows in decision matrix to determine
      # the next state of gene nd.
      decisionrow::Array{Int64, 1} = [genes, path, gate, init]
      concs[t+MAXLAG+1, nd] = decdict[decisionrow]
    end
  end
  concs = concs[MAXLAG+1:end, :]
end
