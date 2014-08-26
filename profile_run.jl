require("evolveclock.jl")
include("GeneticAlgorithms.jl")
using GeneticAlgorithms.runga
model = runga(clockga; initial_pop_size = 6, stop_after = 1)
@profile runga(clockga; initial_pop_size = 6, stop_after = 1)
Profile.print()
