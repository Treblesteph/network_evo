require("evolveclock.jl")
include("GeneticAlgorithms.jl")
using GeneticAlgorithms.runga
using HDF5, JLD
model = runga(clockga; initial_pop_size = 100, stop_after = 100000)
now = strftime("%F_%H_%M", time())
concs1 = model.population[1].net.concseries
concs2 = model.population[2].net.concseries
concs3 = model.population[3].net.concseries
concs4 = model.population[4].net.concseries
concs5 = model.population[5].net.concseries
save("out_$(now).jld", "concs1", concs1, "concs2", concs2,
     "concs3", concs3, "concs4", concs4, "concs5", concs5)
