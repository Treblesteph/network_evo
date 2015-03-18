module BoolNetwork

using Markov

export Network

# Generating a population of random boolean networks that are defined by their
# interactions. A path of value 1 indicates an activation, 0 indicates no path,
# and -1 indicates a repression. A path can also be defined as a stochastic
# process, this is an array of 0s and 1s, or 0s and -1s, generated with the
# Markov property, frequency can be modulated by altering its propensity to
# change state through the transition matrix.

#----- Define interactions

type Interaction
  states::Array{Int64}
end

repression = Interaction([-1])
activation = Interaction([1])
noInteraction = Interaction([0])
stochasticAct = Interaction([0, 1])
stochasticRep = Interaction([0, -1])

#----- Networks

# Network constructor 1 (default)
type Network
  # Order of paths 1->1, 1->2, 1->3 ... 2->1, 2->2, ...
  paths::Array{Array{Int64}}
  transmats::Array{Array{Float64}}
  envpath::Array{Bool} # Is gene activated by environment (bool.)?
  lags::Array{Int64}
  envlag::Array{Int64}
  gates::Array{Bool}  # (0 = or; 1 = and)
  generation::Int64
  concseries::Array{Bool}
  analysis::Dict

  #-- Inner constructor with concentration timeseries.

# Network constructor 2
  Network{T<:Int64, S<:Float64}(paths::Array{Array{T, 1}, 1},
          transmats::Array{Array{S, 2}, 1},
          envpath::Array{Bool, 1}, lags::Array{T, 1},
          envlag::Array{T, 1}, gates::Array{Bool, 1},
          concseries::Array{T}) =
          new(paths, transmats, envpath, lags, envlag,
              gates, 1, concseries, Dict())
          # Using constructor 1

  #-- Inner constructor without concentration timeseries.

# Network constructor 3
  Network{T<:Int64, S<:Float64}(paths::Array{Array{T, 1}, 1},
          transmats::Array{Array{S, 2}, 1},
          envpath::Array{Bool, 1}, lags::Array{T, 1},
          envlag::Array{T, 1}, gates::Array{Bool, 1}) =
          new(paths, transmats, envpath, lags,
              envlag, gates, 1, [], Dict())
          # Using constructor 1

  #-- Inner constructor with generation number.

# Network constructor 4
  Network{T<:Int64, S<:Float64}(paths::Array{Array{T, 1}, 1},
          transmats::Array{Array{S, 2}, 1},
          envpath::Array{Bool, 1}, lags::Array{T, 1},
          envlag::Array{T, 1}, gates::Array{Bool, 1},
          generation::T) =
          new(paths, transmats, envpath, lags, envlag,
              gates, generation, [], Dict())
          # Using constructor 1
end

include("NetworkSimulation.jl")

# Outer Network constructor for deterministic, predefined paths

# Network constructor 5
function Network(acts::Array{Int64}, reps::Array{Int64}, gates::Array{Bool},
                 envs::Array{Int64}, params::Dict)

  if !(length(acts) == length(reps) == (params["nnodes"]^2))
    error("Acts and reps must be nnodes^2 long.")
  end

  for lags in [acts, reps, envs]
    if any(x -> x != 0 && x < params["minlag"], lags)
      error("Minimum lag values for acts are less than minlag")
    elseif any(x -> x > params["maxlag"], lags)
      error("Maximum lag values for envs are greater than maxlag")
    end
  end

  paths = [Int64[] for i in 1:(params["nnodes"]^2)]
  transmats = [zeros(Float64, 2, 2) for i in 1:(params["nnodes"]^2)]

  for i in 1:(params["nnodes"]^2)
    if acts[i] > 0
      paths[i] = ones(Int64, params["allmins"])
    elseif reps[i] > 0
      paths[i] = -1 * ones(Int64, params["allmins"])
    else
      paths[i] = zeros(Int64, params["allmins"])
    end
  end

  lags = acts + reps

  envpath = zeros(Bool, params["nnodes"])

  envpath[find(x -> x > 0, envs)] = 1

  envlag = envs

  net = Network(paths, transmats, envpath, lags, envlag, gates, 1)
  # Using constructor 4

  net.concseries = runsim(net, params)

  return net

end

#-- Outer Network constructor for predefined interactions.

# Network constructor 6
function Network(params::Dict)

  nnodes::Int64 = length(params["gates"])
  paths = [Int64[] for i in 1:(params["nnodes"]^2)]
  transmats = [zeros(Float64, 2, 2) for i in 1:(params["nnodes"]^2)]

  for j in 1:(nnodes^2)
    (paths[j], transmats[j]) = create_interaction(params["interactions"][j],
                                                  params["allmins"])
  end

  network = Network(paths, transmats, params["envpaths"], params["lags"],
                    params["envlag"], params["gates"], 1)
  # Using constructor 4

  network.concseries::Array{Bool} = runsim(network, params)

  return network
end

#-- Outer Network constructor for random network.

# Network constructor 7
function Network(params::Dict, interactchoices::Array{Interaction})
  # This function can be used to create stochastic or deterministic models
  # by controlling the interactchoices array.
  # Initialising fields of Network.
  paths = [Int64[] for i in 1:(params["nnodes"]^2)]
  lags = zeros(Int64, params["nnodes"]^2)
  transmats = [zeros(Float64, 2, 2) for i in 1:(params["nnodes"]^2)]

  # Setting random gates.
  gatechoices = (0, 1)
  gates = Bool[gatechoices[ceil(length(gatechoices)*rand())]
                         for i in 1:params["nnodes"]]

  # Setting random environmental paths.
  envpaths = Bool[round(rand()) for i in 1:params["nnodes"]]
  envlag::Array{Int64} = [params["minlag"] + (Base.convert(Int64,
                          floor((params["maxlag"] - params["minlag"]) *
                          rand()))) for i = 1:params["nnodes"]]
  # Filling paths, lags, and transition matrices for each interaction.
  for p = 1:(params["nnodes"]^2)
    # Randomly select interaction type for each entry.
    randselect = ceil(length(interactchoices)*rand())
    #TODO: Random paths need to be re-generated each generation (for each
    #      dynanic simulation).
    lags[p]::Int64 = params["minlag"] + (Base.convert(Int64,
                     floor((params["maxlag"] - params["minlag"]) * rand())))
    (paths[p], transmats[p]) = create_interaction(interactchoices[randselect],
                                                  params["allmins"])
  end

  network = Network(paths, transmats, envpaths, lags, envlag, gates)
  # Using constructor 3
  network.concseries::Array{Bool} = runsim(network, params)
  return network
end

#-- Outer Network constructor for random fittest selected network.

# Network constructor 8
function Network(interactchoices::Array{Interaction}, selectfrom::Int64,
                 fitfunct::Function, params)
# Generates an array of networks and chooses the fittest one.
  select_pop::Array{Network} = [Network(params,
                                interactchoices) for j in 1:selectfrom]
  # Using constructor 7
  fitnessval = ones(Float64, selectfrom)
  for g in 1:selectfrom
    fitnessval[g] = fitfunct(select_pop[g], params)
  end
  fitnet::Network = select_pop[fitnessval .== apply(min, fitnessval)][1]
end

#---- Subsidiary functions, required for making networks.

function create_transmat(states::Array)
  # Randomly populating transition matrix with probabilities, where T_ij
  # gives the probability of transitioning from state i to state j.
  transmat = rand(Float64, length(states), length(states))
  # Normalising so the columns sum to 1 (since they represent probabilities).
  for k = 1:length(states)
    transmat[:,k] /= sum(transmat[:,k])
  end
  transmat = round(transmat, 1)
  return transmat
end

function create_interaction(i::Interaction, allmins::Int64)
  if i == repression
    chain = -1 * ones(Int64, allmins)
    transmat = [1 0; 0 1]
  elseif i == activation
    chain = ones(Int64, allmins)
    transmat = [1 0; 0 1]
  elseif i == noInteraction
    chain = zeros(Int64, allmins)
    transmat = [1 0; 0 1]
  else
    transmat::Array{Float64} = create_transmat(i.states)
    g = MarkovGenerator(i.states, transmat)
    chain = generate(g, allmins)
  end
  return(chain, transmat)
end

#TODO: Add in extrinsic noise: a stochastic process that is common to a
#      (sub)set of genes in the network.


#---- Exporting networks to a hash.

function net2hash(net::Network)
  NNODES = length(net.gates)
  hash::Dict = Dict()
  counter = 1
  nnodes = length(net.gates)
  for a in 1:nnodes
    for b in 1:nnodes
      hash["$(a)to$(b)"] = Dict()
      hash["$(a)to$(b)"]["path"] = net.paths[(a - 1) * nnodes + b]
      hash["$(a)to$(b)"]["lag"] = net.lags[(a - 1) * nnodes + b]
      # hash["$(a)to$(b)"]["transitions"] = net.transmats[(a - 1) * nnodes + b]
    end
  end
  hash["envpaths"] = net.envpath
  hash["gates"] = net.gates
  hash["generation"] = [net.generation]
  hash["concseries"] = [net.concseries]
  return hash
end

function net2df(net::Network)
  netframe = DataFrame()
end


end # Network
