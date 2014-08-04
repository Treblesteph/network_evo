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

type Interaction
  path::Array{Int64}
  lag::Int64
end

function generatePopulation(popSize)
  pathchoices::Tuple{Array{Int64}} = ([-1], [0], [1], zeros(Int64, alltime),
                                      zeros(Int64,alltime))
  population::Array{Array{Int64}} = [zeros(Int64, nnodes) for i in 1:popsize]
  for n = 1:popsize
    population[:,n]::Array{Int64} =
  end
end
