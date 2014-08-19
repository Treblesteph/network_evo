module clockga
import GeneticAlgorithms

include("generate_networks.jl");
include("dynamic_simulation.jl");

# Can alter these:
alldays = 4
popsize = 5
dawnwindow = 3 * 60
duskwindow = 3 * 60
# Don't change these!
nnodes = 4
maxlag = 60
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
  netw.concseries = dynamic_simulation(netw)
  EvolvableNetwork(netw)
end

function fitness(ent)
  alltime = 1:allmins
  dawnrows = []
  duskrows = []
  for t = 1:alldays
    dawnrows = [dawnrows, (1+60*24*(t-1)):(1+60*(3+24*(t-1)))]
    duskrows = [duskrows, (1+60*(12+24*(t-1))):(1+60*(15+24*(t-1)))]
  end
  println("dawnrows: $dawnrows")
  println("duskrows: $duskrows")
  println(size(ent.net.concseries))
  println(size(ent.net.concseries[[1,2,3,5,7,11], 1]))
  score = sum(ent.net.concseries[dawnrows, 1]) + # gene 1 on at dawn
          sum(ent.net.concseries[duskrows, 2])   # gene 2 on at dusk
end

function group_entities(pop)
  if pop[1].fitness == 0
    return
  end

  for i in 1:length(pop)
    produce([1, i])
  end
end

function crossover(group)
  child = EvolvableNetwork()

  num_parents = length(group)
  for i in 1:length(group[1].net)
    parent = (rand(Uint) % num_parents) + 1
    child.net[i] = group[parent].net[i]
  end

  child
end

function mutate(ent)
  rand(Float64) < 0.8 && return

  rand_element = rand(Uint) % 5 + 1
  ent.net[rand_element] = create_network(allmins, nnodes, maxlag)
end

end
