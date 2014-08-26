include("generate_networks.jl");
include("dynamic_simulation.jl");

# Can alter these variables
alldays = 4
POPSIZE = 12

# Don't change these!
NNODES = 4
MAXLAG = 60
ALLHOURS = alldays * 24
ALLMINS = ALLHOURS * 60

population = create_population(POPSIZE, ALLMINS, NNODES, MAXLAG)
concseries = [zeros(Int64, ALLMINS, NNODES) for i in 1:POPSIZE]

for net in 1:POPSIZE
  println("Running simulation number $net of $POPSIZE")
  concseries[net] = dynamic_simulation(population[net])
end
