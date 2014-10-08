# Generating a population of random boolean networks which are defined by their
# interactions. A path of value 1 indicates an activation, 0 indicates no path,
# and -1 indicates a repression. A path can also be defined as a stochastic
# process, this is an array of 0s and 1s, or 0s and -1s, generated with the
# Markov property, frequency can be modulated by altering its propensity to
# change state.

# Setting up the interaction type, consisting of a path from one gene to
# another, and its associated lag. Lags are any real number between 0 and
# GeneticAlgorithms.MAXLAG, paths are set as follows:
#   -1 ->> repression
#    0 ->> no interaction
#    1 ->> activation
#    s ->> random array of 0s and 1s
#   -s ->> random array of 0s and -1s
include("markov.jl")
include("dynamic_simulation.jl")
import GeneticAlgorithms
import clockga

type Interaction
  states::Array{Int64}
end

type Network
  paths::Array{Array{Int64}}
  transmats::Array{Array{Float64}}
  envpath::Array{Int64} # Is gene activated by environment (bool.)?
  lags::Array{Int64}
  gates::Array{Int64}  # (0 = or; 1 = and)
  generation::Int64
  concseries::Array{Int64}
end

# Setting method for defining network with no concentration series.
function Network(paths::Array{Array{Int64}},
                 transmats::Array{Array{Float64}},
                 envpath::Array{Int64},
                 lags::Array{Int64},
                 gates::Array{Int64},
                 generation::Int64)
  Network(paths, transmats, envpath, lags, gates, generation, [])
end

function Network(ALLMINS::Int64, interactions::Array{Interaction},
                 envpaths::Array{Int64}, lags::Array{Int64},
                 gates::Array{Int64}, envsignal::Array{Int64})
  NNODES::Int64 = length(gates)
  paths::Array{Array{Int64}} = [Int64[] for i in 1:(NNODES^2)]
  transmats::Array{Array{Float64}} = [Float64[] for i in 1:(NNODES^2)]
  for j in 1:(NNODES^2)
    (paths[j], transmats[j]) = create_interaction(interactions[j], ALLMINS)
  end
end

function reshapepaths!(paths::Array{Array{Int64}})
  NNODES = sqrt(length(paths))
  paths = transpose(reshape(paths, NNODES, NNODES))
  for i in 1:length(paths)
    paths[i] = vec(paths[i])
  end
end

repression = Interaction([-1])
activation = Interaction([1])
noInteraction = Interaction([0])
stochasticAct = Interaction([0, 1])
stochasticRep = Interaction([0, -1])

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

function create_network()

function create_network(ALLMINS::Int64, NNODES::Int64, MAXLAG::Int64,
                        ENVIRON)
  # Randomly select interaction type for each entry.
  allpaths::Array{Array{Int64}} = [Int64[] for i in 1:(NNODES^2)]
  lags::Array{Int64} = zeros(Int64, NNODES^2)
  gatechoices = (0, 1)
  gates::Array{Int64} = [gatechoices[ceil(length(gatechoices)*rand())]
                         for i in 1:NNODES]
  transmats::Array{Array{Float64}} = [Float64[] for i in
                                      1:(NNODES^2)]
  for p = 1:(NNODES^2)
    intchoices = [repression, activation, noInteraction,
                  stochasticAct, stochasticRep]
    randselect = ceil(length(intchoices)*rand())
    #TODO: Random paths need to be re-generated each generation (for each
    #      dynanic simulation).
    lags[p]::Int64 = Base.convert(Int64, floor(MAXLAG*rand()))
    (allpaths[p], transmats[p]) = create_interaction(intchoices[randselect],
                                                     ALLMINS)
  end
  allpaths = reshapepaths(allpaths)
  lags = transpose(reshape(lags, NNODES, NNODES))
  randselect = ceil(length(NNODES)*rand())
  envpaths = [round(rand()) for i in 1:NNODES]
  network = Network(allpaths, transmats, envpaths, lags, gates, 1, Int64[])
  network.concseries = dynamic_simulation(network, NNODES, ALLMINS,
                                          MAXLAG, ENVIRON,
                                          GeneticAlgorithms.decisionhash)
  return network
end

function create_determ_net(ALLMINS::Int64,NNODES::Int64, MAXLAG::Int64,
                           ENVIRON)
  allpaths::Array{Array{Int64}} = [Int64[] for i in 1:(NNODES^2)]
  lags::Array{Int64} = zeros(Int64, NNODES^2)
  gatechoices = (0, 1)
  gates::Array{Int64} = [gatechoices[ceil(length(gatechoices)*rand())]
                         for i in 1:NNODES]
  transmats::Array{Array{Float64}} = [Float64[] for i in
                                      1:(NNODES^2)]
  for p = 1:(NNODES^2)
    intchoices = [repression, activation, noInteraction]
    randselect = ceil(length(intchoices)*rand())
    lags[p]::Int64 = Base.convert(Int64, floor(MAXLAG*rand()))
    (allpaths[p] transmats[p]) = create_interaction(intchoices[randselect],
                                                    ALLMINS)
  end
  allpaths = transpose(reshape(allpaths, NNODES, NNODES))
  for i in 1:length(allpaths)
    allpaths[i] = vec(allpaths[i])
  end
  lags = transpose(reshape(lags, NNODES, NNODES))
  randselect = ceil(length(NNODES)*rand())
  envpaths = [round(rand()) for i in 1:NNODES]
  network = Network(allpaths, transmats, envpaths, lags, gates, 1, Int64[])
  network.concseries = dynamic_simulation(network, NNODES, ALLMINS,
                                          MAXLAG, ENVIRON,
                                          GeneticAlgorithms.decisionhash)
  return network
end

# Adding a method for create_network that uses globals so needs fewer
# input arguments :)

function create_network(ind::Number)

  create_network(GeneticAlgorithms.ALLMINS, GeneticAlgorithms.NNODES,
                 GeneticAlgorithms.MAXLAG, clockga.DAYS)

end


function create_troein_1D(ALLMINS::Int64, ENVIRON)
  # Creating a boolean representation of the network shown in figure 1D of
  # Troein, Locke et al., 2009.
  # Activation from gene 3 to 4 (lag 2.61hr)
  # Repression from gene 3 to 1 (lag 2.61hr)
  # Repression from gene 4 to 2 (lag 14hr)
  # Light sensing in genes 1, 2, & 3
  # All gates set as "or"
  paths::Array{Array{Int64}} = [[zeros(Int64, ALLMINS)] for i in 1:16]
  paths[9] -= 1; paths[12] += 1; paths[15] -= 1;
  transmats::Array{Array{Float64}} = [[1 0; 0 1] for i in 1:16]
  envpath::Array{Int64} = [1, 1, 1, 0]
  lags::Array{Int64} = zeros(Int64, 16)
  lags[9] = 157; lags[12] = 157; lags[15] = 840;
  gates::Array{Int64} = zeros(Int64, 4)
  generation::Int64 = 1
  paths = transpose(reshape(paths, 4, 4))
  for i in 1:length(paths)
    paths[i] = vec(paths[i])
  end
  lags = transpose(reshape(lags, 4, 4))
  network = Network(paths, transmats, envpath, lags,
                    gates, generation, Int64[])
  network.concseries = dynamic_simulation(network, 4, ALLMINS,
                                          60*24, ENVIRON,
                                          GeneticAlgorithms.decisionhash)
  return network
end

function generate_fit_network(ALLMINS::Int64, NNODES::Int64, MAXLAG::Int64,
                              selectfrom::Int64, ENVIRON, determ_stoch)
# Generates an array of networks and chooses the fittest one.
  if determ_stoch == 1
    select_pop::Array{Network} = [create_network(ALLMINS, NNODES, MAXLAG,
                                          ENVIRON) for j in 1:selectfrom]
  elseif determ_stoch == 0
    select_pop = [create_determ_net(ALLMINS, NNODES, MAXLAG,
                                    ENVIRON) for j in 1:selectfrom]
  end
  fitnessval::Array{Float64} = ones(Float64, selectfrom)
  for g in 1:selectfrom
    fitnessval[g] = fitness(select_pop[g])
  end
  fitnet::Network = select_pop[fitnessval .== apply(min, fitnessval)][1]
end

function create_population(POPSIZE::Int64, ALLMINS::Int64, NNODES::Int64,
                           MAXLAG::Int64, ENVIRON)
  population::Array{Network} = [create_network(ALLMINS, NNODES,
                                               MAXLAG, ENVIRON)
                                for j in 1:POPSIZE]
  return population
end
