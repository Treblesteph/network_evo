# Generating a population of random boolean networks that are defined by their
# interactions. A path of value 1 indicates an activation, 0 indicates no path,
# and -1 indicates a repression. A path can also be defined as a stochastic
# process, this is an array of 0s and 1s, or 0s and -1s, generated with the
# Markov property, frequency can be modulated by altering its propensity to
# change state through the transition matrix.

include("markov.jl")
include("dynamic_simulation.jl")
import GeneticAlgorithms
import clockga

#----- Interactions

type Interaction
  states::Array{Int64}
end

repression = Interaction([-1])
activation = Interaction([1])
noInteraction = Interaction([0])
stochasticAct = Interaction([0, 1])
stochasticRep = Interaction([0, -1])

#----- Networks

type Network
  # Order of paths 1->1, 1->2, 1->3 ... 2->1, 2->2, ...
  paths::Array{Array{Int64}}
  transmats::Array{Array{Float64}}
  envpath::Array{Int64} # Is gene activated by environment (bool.)?
  lags::Array{Int64}
  gates::Array{Int64}  # (0 = or; 1 = and)
  generation::Int64
  concseries::Array{Int64}

  #-- Inner constructor with concentration timeseries.

  Network(paths::Array{Array{Int64}}, transmats::Array{Array{Float64}},
          envpath::Array{Int64}, lags::Array{Int64}, gates::Array{Int64},
          concseries::Array{Int64}) =
          new(paths, transmats, envpath, lags, gates, 1, concseries)

  #-- Inner constructor without concentration timeseries.

  Network(paths::Array{Array{Int64}}, transmats::Array{Array{Float64}},
          envpath::Array{Int64}, lags::Array{Int64}, gates::Array{Int64}) =
          new(paths, transmats, envpath, lags, gates, 1, [])

  #-- Inner constructor with generation number.

  Network(paths::Array{Array{Int64}}, transmats::Array{Array{Float64}},
          envpath::Array{Int64}, lags::Array{Int64}, gates::Array{Int64},
          generation::Int64) =
          new(paths, transmats, envpath, lags, gates, generation, [])
end

#-- Outer Network constructor for predefined interactions.

function Network(allmins::Int64, maxlag::Int64, decisions::Dict,
                 envsignal::Array{Int64}, interactions::Array{Interaction},
                 envpaths::Array{Int64}, lags::Array{Int64},
                 gates::Array{Int64})
  nnodes::Int64 = length(gates)
  paths::Array{Array{Int64}} = [Int64[] for i in 1:(nnodes^2)]
  transmats::Array{Array{Float64}} = [Float64[] for i in 1:(nnodes^2)]
  for j in 1:(nnodes^2)
    (paths[j], transmats[j]) = create_interaction(interactions[j], allmins)
  end
  paths = reshapepaths!(paths)
  lags = transpose(reshape(lags, nnodes, nnodes))
  network = Network(paths, transmats, envpaths, lags, gates, 1)
  network.concseries = dynamic_simulation(network, nnodes, allmins, maxlag,
                                          envsignal, decisions)
  return network
end

#-- Outer Network constructor for random network.

function Network(allmins::Int64, nnodes::Int64, maxlag::Int64,
                 decisions::Dict, envsignal::Array{Int64},
                 interactchoices::Array{Interaction})
# This function can be used to create stochastic or deterministic models
# by controlling the interactchoices array.

  # Initialising fields of Network.
  paths::Array{Array{Int64}} = [Int64[] for i in 1:(nnodes^2)]
  lags::Array{Int64} = zeros(Int64, nnodes^2)
  transmats::Array{Array{Float64}} = [Float64[] for i in
                                      1:(nnodes^2)]

  # Setting random gates.
  gatechoices = (0, 1)
  gates::Array{Int64} = [gatechoices[ceil(length(gatechoices)*rand())]
                         for i in 1:nnodes]

  # Setting random environmental paths.
  envpaths::Array{Int64} = Int64[round(rand()) for i in 1:nnodes]

  # Filling paths, lags, and transition matrices for each interaction.
  for p = 1:(nnodes^2)
    # Randomly select interaction type for each entry.
    randselect = ceil(length(interactchoices)*rand())
    #TODO: Random paths need to be re-generated each generation (for each
    #      dynanic simulation).
    lags[p]::Int64 = Base.convert(Int64, floor(maxlag*rand()))
    (paths[p], transmats[p]) = create_interaction(interactchoices[randselect],
                                                  allmins)
  end

  paths = reshapepaths!(paths)
  lags = transpose(reshape(lags, nnodes, nnodes))
  network = Network(paths, transmats, envpaths, lags, gates)
  network.concseries = dynamic_simulation(network, nnodes, allmins,
                                          maxlag, envsignal, decisions)
  return network
end

#-- Outer Network constructor for random fittest selected network.
# TODO: this should accept the fitness function as an argument,
#       so this file doesn't need to require GeneticAlgorithms, clockga, etc.
function Network(allmins::Int64, nnodes::Int64, maxlag::Int64,
                 decisions::Dict, envsignal::Array{Int64},
                 interactchoices::Array{Interaction}, selectfrom::Int64, fitness)
# Generates an array of networks and chooses the fittest one.
  select_pop::Array{Network} = [Network(allmins, nnodes, maxlag,
                                        decisions, envsignal,
                                        interactchoices) for j in 1:selectfrom]
  fitnessval::Array{Float64} = ones(Float64, selectfrom)
  for g in 1:selectfrom
    fitnessval[g] = fitness(select_pop[g])
  end
  fitnet::Network = select_pop[fitnessval .== apply(min, fitnessval)][1]
end

#---- Subsidiary functions, required for making networks.

function reshapepaths!(paths::Array{Array{Int64}})
  nnodes::Int64 = convert(Int64, sqrt(length(paths)))
  paths = transpose(reshape(paths, nnodes, nnodes))
  for i in 1:length(paths)
    paths[i] = vec(paths[i])
  end
  return paths
end

function create_transmat(states::Array)
  # Randomly populating transition matrix with probabilities, where T_ij
  # gives the probability of transitioning from state i to state j.
  transmat::Array{Float64} = rand(length(states), length(states))
  # Normalising so the columns sum to 1 (since they represent probabilities).
  for k = 1:length(states)
    transmat[:,k] /= sum(transmat[:,k])
  end
  transmat = round(transmat, 1)
  return transmat
end

function create_interaction(i::Interaction, ALLMINS::Int64)
  if i == repression
    chain = -1 * ones(Int64, ALLMINS)
    transmat = [1 0; 0 1]
  elseif i == activation
    chain = ones(Int64, ALLMINS)
    transmat = [1 0; 0 1]
  elseif i == noInteraction
    chain = zeros(Int64, ALLMINS)
    transmat = [1 0; 0 1]
  else
    transmat::Array{Float64} = create_transmat(i.states)
    g = MarkovGenerator(i.states, transmat)
    chain = generate(g, ALLMINS)
  end
  return(chain, transmat)
end

#TODO: Add in extrinsic noise: a stochastic process that is common to a
#      (sub)set of genes in the network.

function create_troein_1D(allmins::Int64, envsignal::Array{Int64},
                          decisions::Dict)
  # Creating a boolean representation of the network shown in figure 1D of
  # Troein, Locke et al., 2009.
  # Activation from gene 3 to 4 (lag 2.61hr)
  # Repression from gene 3 to 1 (lag 2.61hr)
  # Repression from gene 4 to 2 (lag 14hr)
  # Light sensing in genes 1, 2, & 3
  # All gates set as "or"

  # First making a network with no interactions.
  interactions = [noInteraction]
  net = Network(allmins, 4, 14*60, decisions, envsignal, interactions)

  # Now overwriting the interactions, paths, envrionmental paths, and gates.
  net.paths[3] -= 1; net.paths[15] += 1; net.paths[8] -= 1;
  net.envpath = [1, 1, 1, 0]
  net.lags[3] = 157; net.lags[15] = 157; net.lags[8] = 840;
  net.gates = zeros(Int64, 4)

  net.concseries = dynamic_simulation(net, 4, allmins, 60*24,
                                      envsignal, decisions)
  return net
end

function should_be_a_clock(allmins:Int64, envsignal::Array{Int64},
                           decisions::Dict)

  
end
