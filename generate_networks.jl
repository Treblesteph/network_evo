# Generating a population of random boolean networks which are defined by their
# interactions. A path of value 1 indicates an activation, 0 indicates no path,
# and -1 indicates a repression. A path can also be defined as a stochastic
# process, this is an array of 0s and 1s, or 0s and -1s, generated with the
# Markov property, frequency can be modulated by altering its propensity to
# change state.

# Setting up the interaction type, consisting of a path from one gene to
# another, and its associated lag. Lags are any real number between 0 and
# maxLag, paths are set as follows:
#   -1 ->> repression
#    0 ->> no interaction
#    1 ->> activation
#    s ->> random array of 0s and 1s
#   -s ->> random array of 0s and -1s

alltime = 4 * 24 * 60 # Total simulation time.
popsize = 100         # Total number of networks per generation.
# Setting up the states and transition matrix for stochastic interactions:
states = [0, 1]

type Interaction
  lag::Int64
end
type DeterministicInteraction
  init::int64
end
type Repression < DeterministicInteraction; end
type Activation < DeterministicInteraction; end
type NoInteraction < DeterministicInteraction; end
end
type StochasticInteraction < Interaction
  markovgen::MarkovGenerator
end
type StochasticActivation < StochasticInteraction; end
type StochasticRepression < StochasticInteraction; end

function next(interaction::DeterministicInteraction)
end
function next(interaction::StochasticInteraction)

function generatePopulation(popSize, nnode, popsize)
  pathchoices::Tuple{Array{Int64}} = ([-1], [0], [1],
                                      generate(mgen, alltime),
                                      generate(mgen, alltime))
  # Randomly populating transition matrix with probabilities, where T_ij will
  # give the probability of transitioning from state i to state j.
  transitions::Array{Float64} = rand(length(states), length(states))
  # Normalising columns so they sum to 1 (i.e. so they are probabilities).
  for k = 1:length(states)
    transitions[:,k] /= sum(transitions[:,k])
  end
  transitions = round(transitions, 1)
  population::Array{Array{Array{Int64}}} = [[Int64[] for i in 1:popsize]
                                            for j in 1:(nnode^2)]
  for n = 1:popsize
    randselect = ceil(length(pathchoices)*rand())
    population[:,n]::Array{Int64} =
  end
  return population
end
