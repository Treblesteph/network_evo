import GeneticAlgorithms
import clockga

# Contains functions for performing simulated reproduction on networks.

Base.convert(::Type{Network}, T::Type{Network}) = T

function crossover(group)
  println("Performing a crossover...")
  println(typeof(group))
  # Initialising an empty network to be the child.
  childnet = EvolvableNetwork()
  num_parents = length(group)
  # Set each path according to a random choice between parents.
  for i in 1:length(group[1].net.paths)
    parent = (rand(Uint) % num_parents) + 1
    childnet.net.paths[i] = group[parent].net.paths[i]
    childnet.net.transmats[i] = group[parent].net.transmats[i]
  end
  # Set each lag according to a random choice between parents.
  for i in 1:length(group[1].net.lags)
    parent = (rand(Uint) % num_parents) + 1
    childnet.net.lags[i] = group[parent].net.lags[i]
  end
  # Set each gate according to a random choice between parents.
  for i in 1:length(group[1].net.gates)
    parent = (rand(Uint) % num_parents) + 1
    childnet.net.gates[i] = group[parent].net.gates[i]
  end
  childnet.net.generation = 1 + group[1].net.generation
  #TODO: Create an array for generation, push new generation to the array
  #      each time the network survives for a new generation. To get generation
  #      from GeneticAlgorithms code, something like model.gen_num.
  childnet.net.concseries = []
end

function mutate(ent::EvolvableNetwork)
  println("Performing a mutation...")
  println(typeof(ent))
  # Path sign switch mutations.
  pathind = (rand(Uint) % length(ent.net.paths))
  rand(Float64) < mutatepath && mutate_path(ent.net.paths[pathind])
  # Transition matrix mutations.
  tmatind = (rand(Uint) % length(ent.net.transmats))
  rand(Float64) < mutatetmat && mutate_tmat(ent.net.transmats[tmatind],
                                            ent.net.paths[tmatind])
  # Lag duration mutations.
  randlagind = (rand(Uint) % length(ent.net.lags))
  rand(Float64) < mutatelag && mutate_lag(ent.net.lags[randlagind])
  # Gate type switch mutations.
  randgateind = (rand(Uint) % length(ent.net.gates))
  rand(Float64) < mutategate && mutate_gate(ent.net.gates[randgateind])
end

function mutate_path(path::Array{Int64})
  # Mutation causes the path to switch
  # either activator >> repressor
  # or repressor >> activator
  path = -path
end

function mutate_tmat(transmat::Array{Float64}, path::Array{Int64})
  transmat = create_transmat(unique(path))
  g = MarkovGenerator(unique(path), transmat)
  path = generate(g, allmins)
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
