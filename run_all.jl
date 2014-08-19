include("generate_networks.jl");
include("dynamic_simulation.jl");

# Can alter these variables
alldays = 4
popsize = 5

# Don't change these!
nnodes = 4
maxlag = 60
allhours = alldays * 24
allmins = allhours * 60

population = create_population(popsize, allmins, nnodes, maxlag)
concseries = [zeros(Int64, allmins, nnodes) for i in 1:popsize]

for net in 1:popsize
  println("Running simulation number $net of $popsize")
  concseries[net] = dynamic_simulation(population[net])
end
