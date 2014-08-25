module clockga
import GeneticAlgorithms

include("generate_networks.jl");
include("dynamic_simulation.jl");

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
  EvolvableNetwork() = new(create_network(allmins, nnodes, maxlag), nothing)
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
  # Kill off the 10% least fit networks
  threshold = floor(0.1 * length(pop))
  pop = pop[1:end-threshold]
  # Stop when the top 50% of networks have optimal fitness.
  if sum([pop[x].fitness for x in 1:(ceil(length(pop)/2))]) == 0
    return
  end

  for i in 1:length(pop)
    produce([1, i])
  end
end

Base.convert(::Type{Network}, T::Type{Network}) = T

function crossover(group::Array{Any})
  println("Performing a crossover...")
  # Initialising an empty network to be the child.
  child = EvolvableNetwork()
  num_parents = length(group)
  # Set each path according to a random choice between parents.
  for i in 1:length(group[1].net.paths)
    parent = (rand(Uint) % num_parents) + 1
    child.net.paths[i] = group[parent].net.paths[i]
    child.net.transmats[i] = group[parent].net.transmats[i]
  end
  # Set each lag according to a random choice between parents.
  for i in 1:length(group[1].net.lags)
    parent = (rand(Uint) % num_parents) + 1
    child.net.lags[i] = group[parent].net.lags[i]
  end
  # Set each gate according to a random choice between parents.
  for i in 1:length(group[1].net.gates)
    parent = (rand(Uint) % num_parents) + 1
    child.net.gates[i] = group[parent].net.gates[i]
  end
  child.net.generation = 1 + group[1].net.generation
  #TODO: Create an array for generation, push new generation to the array
  #      each time the network survives for a new generation. To get generation
  #      from GeneticAlgorithms code, something like model.gen_num.
  child.net.concseries = []
  child
end

function mutate(ent)
  println("Performing a mutation...")
  # Path sign switch mutations.
  pathind = (rand(Uint) % length(ent.net.paths))
  if rand(Float64) < mutatepath
    ent.net.paths[pathind] = mutate_path(ent.net.paths[pathind])
  end
  # Transition matrix mutations.
  tmatind = (rand(Uint) % length(ent.net.transmats))
  if rand(Float64) < mutatetmat
    (ent.net.transmats[tmatind], ent.net.paths[tmatind]) =
      mutate_tmat(ent.net.transmats[tmatind], ent.net.paths[tmatind])
  end
  # Lag duration mutations.
  lagind = (rand(Uint) % length(ent.net.lags))
  if rand(Float64) < mutatelag
    ent.net.lags[lagind] = mutate_lag(ent.net.lags[lagind])
  end
  # Gate type switch mutations.
  gateind = (rand(Uint) % length(ent.net.gates))
  if rand(Float64) < mutategate
    ent.net.gate[gateind] = mutate_gate(ent.net.gates[gateind])
  end
  ent
end

function mutate_path(path::Array{Int64})
  # Mutation causes the path to switch
  # either activator >> repressor
  # or repressor >> activator
  path = -path
end

function mutate_tmat(transmat::Array{Float64}, path::Array{Int64})
  #TODO: Make transition matrix mutation more sophisticated. Probably a
  #      Markov process itself with a fixed transition function?
  transmat = create_transmat(unique(path))
  g = MarkovGenerator(unique(path), transmat)
  path = generate(g, allmins)
  (transmat, path)
end

function mutate_lag(lag::Int64)
  # Lag can change to anything within a two hour interval.
  laginterval = [lag-60:lag+60]
  lagselector = (rand(Uint) % length(laginterval))
  # Lag must not exceed maxlag value.
  lag = min(laginterval[lagselector], maxlag)
  # Lag cannot be less than zero.
  lag = max(0, laginterval[lagselector])
end

function mutate_gate(gate::Int64)
  # Mutation causes gate to switch (0 = or; 1 = and)
  # either or >> and
  # or and >> or
  gate = mod(gate+1, 2)
end


end
