require("evolveclock.jl")
include("GeneticAlgorithms.jl")
using GeneticAlgorithms.runga
model = runga(clockga; initial_pop_size = 16)
