# Generating a population of random boolean networks which are defined by their
# interactions. A path of value 1 indicates an activation, 0 indicates no path,
# and -1 indicates a repression. A path can also be defined as a stochastic
# process, this is an array of 0s and 1s, or 0s and -1s, generated with the
# Markov property, frequency can be modulated by altering its propensity to
# change state.

# Setting up the interaction type, consisting of a path from one gene to
# another, and its associated lag. Lags are any real number between 0 and
# MAXLAG, paths are set as follows:
#   -1 ->> repression
#    0 ->> no interaction
#    1 ->> activation
#    s ->> random array of 0s and 1s
#   -s ->> random array of 0s and -1s
include("markov.jl")
type Interaction
  states::Array{Int64}
end

type Network
  paths::Array{Array{Int64}}
  transmats::Array{Array{Float64}}
  lags::Array{Int64}
  gates::Array{Int64} # (0 = or; 1 = and)
  generation::Int64
  concseries::Array{Int64}
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

function create_interaction(i::Interaction, ALLMINS::Int64, MAXLAG::Int64)
  
  transmat::Array{Float64} = create_transmat(i.states)
  g = MarkovGenerator(i.states, transmat)
  chain::Array{Int64} = generate(g, ALLMINS)
  lag::Int64 = Base.convert(Int64, floor(MAXLAG*rand()))
  return(chain, lag, transmat)
end

function create_network(ALLMINS::Int64, NNODES::Int64, MAXLAG::Int64)
  # Randomly select interaction type for each entry.
  allpaths::Array{Array{Int64}} = [Int64[] for i in 1:(NNODES^2)]
  lags::Array{Int64} = zeros(Int64, NNODES^2)
  gatechoices = (0, 1)
  gates::Array{Int64} = [gatechoices[ceil(length(gatechoices)*rand())]
                         for i in 1:NNODES]
  transmats::Array{Array{Float64}} = [Float64[] for i in 1:(NNODES^2)]
  for p = 1:(NNODES^2)
    intchoices = [repression, activation, noInteraction,
                  stochasticAct, stochasticRep]
    randselect = ceil(length(intchoices)*rand())
    (allpaths[p], lags[p], transmats[p]) = create_interaction(intchoices
                                                              [randselect],
                                                              ALLMINS, MAXLAG)
  end
  allpaths = transpose(reshape(allpaths, NNODES, NNODES))
  for i in 1:length(allpaths)
    allpaths[i] = vec(allpaths[i])
  end
  lags = reshape(lags, NNODES, NNODES).'
  network = Network(allpaths, transmats, lags, gates, 1, Int64[])
  return network
end

function create_population(POPSIZE::Int64, ALLMINS::Int64, NNODES::Int64,
                           MAXLAG::Int64)
  population::Array{Network} = [create_network(ALLMINS, NNODES,
                                               MAXLAG) for j in 1:POPSIZE]
  return population
end
