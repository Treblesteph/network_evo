require("evolveclock.jl")
include("GeneticAlgorithms.jl")
include("generate_networks.jl")
using GeneticAlgorithms.runga
using HDF5, JLD
model = runga(clockga; initial_pop_size = 100, stop_after = 25000)
now = strftime("%F_%H_%M", time())
concs1 = model.population[1].net.concseries
concs2 = model.population[2].net.concseries
concs3 = model.population[3].net.concseries
concs4 = model.population[4].net.concseries
concs5 = model.population[5].net.concseries
all_fitnesses = model.all_fitnesses
save("out_$(now).jld", "concs1", concs1, "concs2", concs2,
     "concs3", concs3, "concs4", concs4, "concs5", concs5,
     "all_fitnesses", all_fitnesses)


function net2hash(net::Network)
  NNODES = length(net.gates)
  hash::Dict{String, Array{Number}} = Dict{String, Array{Number}}()
  # Paths
  for row in 1:size(net.paths,1)
    for col in 1:size(net.paths,2)
      hash["path$(row)to$(col)"] = net.paths[row, col]
    end
  end
  # Transition matrices
  counter1 = 1
  counter2 = 1
  for ind in 1:length(net.transmats)
    hash["transmat$(counter1)to$(counter2)"] = net.transmats[ind]
    counter1 += 1
    if mod(counter1, NNODES) == 1
      counter1 = 1
      counter2 += 1
    end
  end
  # Environmental paths
  for g in 1:NNODES
    hash["envpath$(g)"] = net.envpath[g]
  end
  # Lags
  for row in 1:size(net.lags,1)
    for col in 1:size(net.lags,2)
      hash["lag$(row)to$(col)"] = net.lags[row, col]
    end
  end
  # Gates
  for h in 1:NNODES
    hash["gate$(h)"] = net.gates[h]
  end
  # Generation
  hash["generation"] = net.generation
  hash["concseries"] = net.concseries
end
