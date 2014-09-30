module TestMarkov

using FactCheck
include("./markov.jl")

facts("Checking some deterministic examples work") do
  states1 = [1, 2, 3, 4]
  states2 = [0, 1]
  states3 = [0, 0, 0]
  states4 = [0, 1, 0, 1]
  transitions1 = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] # All stay the same.
  transitions2 = [0 1 0 0; 0 1 0 0; 0 1 0 0; 0 1 0 0] # All change to state 2.
  transitions3 = [0 0 1 0; 1 0 0 0; 0 0 0 1; 1 0 0 0] # All change.
  transitions4 = [0 1; 1 0]
  transitions5 = [1 0; 0 1]
  transitions6 = [1 0 0; 0 1 0; 0 0 1]
  transitions7 = [0 0 1; 0 0 1; 0 0 1]
  transitions8 = [0 1 0; 1 0 0; 0 0 1]
  mgen = MarkovGenerator()

end
