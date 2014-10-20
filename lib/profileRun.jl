require("EvolveClock.jl")
include("GeneticAlgorithms.jl")
using GeneticAlgorithms.runga
model = runga(EvolveClock; initial_pop_size = 6, stop_after = 1)
@profile runga(EvolveClock; initial_pop_size = 6, stop_after = 1)
Profile.print()
