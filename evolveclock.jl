module clockga
import GeneticAlgorithms

include("generate_networks.jl");
include("dynamic_simulation.jl");
include("reproduction.jl")

# Can alter these:
alldays = 4
popsize = 5
dawnwindow = 3 * 60
duskwindow = 3 * 60
mutatepath = 0.05  # Percent of time path sign switched.
mutatetmat = 0.05  # Percent of time transition matrix mutates.
mutatelag = 0.05   # Percent of time lag duration mutates.
mutategate = 0.05  # Percent of time gate type switches.

# Don't change these unless altering framework.
nnodes = 4
maxlag = 60*24
allhours = alldays * 24
allmins = allhours * 60

type EvolvableNetwork <: GeneticAlgorithms.Entity
  net::Network
  fitness
  EvolvableNetwork() = new(nothing, nothing)
  EvolvableNetwork(net) = new(net, nothing)
end

function create_entity(num)
  netw = create_network(allmins, nnodes, maxlag)
  EvolvableNetwork(netw)
end

function fitness(ent)
  ent.net.concseries = dynamic_simulation(ent.net)
  alltime = 1:allmins
  dawnrows = []
  duskrows = []
  for t = 1:alldays
    dawnrows = [dawnrows, (1+60*24*(t-1)):(1+60*(3+24*(t-1)))]
    duskrows = [duskrows, (1+60*(12+24*(t-1))):(1+60*(15+24*(t-1)))]
  end
  maxfitness = length(dawnrows) + length(duskrows)
  # Optimal fitness is 0 (so score is actually cost function).
  score = maxfitness -
          sum(ent.net.concseries[dawnrows, 1]) + # gene 1 on at dawn
          sum(ent.net.concseries[duskrows, 2])   # gene 2 on at dusk
end

function isless(lhs::EvolvableNetwork, rhs::EvolvableNetwork)
  abs(lhs.fitness) > abs(rhs.fitness)
end

function group_entities(pop)
  # Kill off the five least fit networks
  pop = pop[1:end-5]
  # Stop when the top 50% of networks have optimal fitness.
  if sum([pop[x].fitness for x in 1:(ceil(length(pop)/2))] == 0
    return
  end

  for i in 1:length(pop)
    produce([1, i])
  end
end

function mutate(ent)
  rand(Float64) < 0.8 && return

  rand_element = rand(Uint) % 5 + 1
  ent.net[rand_element] = create_network(allmins, nnodes, maxlag)
end

end
