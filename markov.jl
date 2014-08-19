# Type representing a Markov chain generator.
# It stores an array of the possible states in the chain,
# and a transition matrix defining the probabilities
# of moving from one state to another.
import Base.next

type MarkovGenerator
  states::Array{Int}
  transmat::Array{Float64}
end

# Given the current state, get the next state of a Markov chain
function next(generator::MarkovGenerator, state::Int64)
  col = findfirst(generator.states, state)
  probs = generator.transmat[:,col]
  cumprob = 0.0
  stop = rand()
  current = 0
  for prob in probs
    current += 1
    limit = cumprob + prob
    if stop <= limit
      return generator.states[current]
    end
    cumprob = limit
  end
  return generator.states[current]
end

# Generate a sequence of states of length `len` using the
# MarkovGenerator.
function generate(generator::MarkovGenerator, len::Int64)
  state::Int64 = generator.states[ceil(rand() * length(generator.states))]
  chain::Array{Int64} = zeros(Int64, len)
  for i in 1:len
    nextstate = next(generator, state)
    chain[i] = nextstate
    state = nextstate
  end
  return chain
end

# Demo of use
# states = [0, 1]
# transitions = [
#  0.2 0.9;
#  0.8 0.1
# ]
# m = MarkovGenerator(states, transitions)
# chain = generate(m, 50)
