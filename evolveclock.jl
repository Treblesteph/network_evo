module clockga
import GeneticAlgorithms
using Distributions

include("generate_networks.jl");
include("dynamic_simulation.jl");

# Can alter these:
const DAWNWINDOW = 3
const DUSKWINDOW = 3
DAWNROWS = []; DAWNS = zeros(GeneticAlgorithms.ALLDAYS, DAWNWINDOW * 60)
DUSKROWS = []; DUSKS = zeros(GeneticAlgorithms.ALLDAYS, DUSKWINDOW * 60)
for t = 1:GeneticAlgorithms.ALLDAYS
  DAWNS[t, :] = (1+60*24*(t-1)):(60*(DAWNWINDOW+24*(t-1)))
  DUSKS[t, :] = (1+60*(12+24*(t-1))):(60*(12+DUSKWINDOW+24*(t-1)))
  DAWNROWS = [DAWNROWS, transpose(DAWNS[t, :])]
  DUSKROWS = [DUSKROWS, transpose(DUSKS[t, :])]
end

type EvolvableNetwork <: GeneticAlgorithms.Entity
  net::Network
  fitness
  EvolvableNetwork() = new(create_network(GeneticAlgorithms.ALLMINS,
                                          GeneticAlgorithms.NNODES,
                                          GeneticAlgorithms.MAXLAG), nothing)
  EvolvableNetwork(net) = new(net, nothing)
end

function create_entity(num)
  netw = generate_fit_network(GeneticAlgorithms.ALLMINS,
                              GeneticAlgorithms.NNODES,
                              GeneticAlgorithms.MAXLAG, 50)
  EvolvableNetwork(netw)
end

function fitness(ent::EvolvableNetwork)
  fitness(ent.net)
end

#TODO: Add in another fitness function including a light pattern.

function fitness(net::Network)
  gene1 = net.concseries[:, 1]
  gene2 = net.concseries[:, 2]

  fitnessG1::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)
  fitnessG2::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)

  dawnFitness::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)
  notDawnFitness::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)
  duskFitness::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)
  notDuskFitness::Array{Float64} = zeros(GeneticAlgorithms.ALLDAYS)

  # First working out the fitness for each day.
  for d in 1:GeneticAlgorithms.ALLDAYS
    dawnFitness[d] = sum(gene1[DAWNS[d, :]]) / length(DAWNS[d, :])
    notDawnFitness[d] = 1 - (sum(gene1[(1 + DAWNS[d, end]):(d * 24 * 60)]) /
                        length((1 + DAWNS[d, end]):(d * 24 * 60)))
    duskFitness[d] = sum(gene2[DUSKS[d, :]]) / length(DUSKS[d, :])
    notDuskFitness[d] = 1 - (sum(gene2[1 + (d - 1) * 24 * 60:(DUSKS[d, 1] - 1)]) /
                        length(1 + (d - 1) * 24 * 60:(DUSKS[d, 1] - 1)))
    fitnessG1[d] = (dawnFitness[d] + notDawnFitness[d]) / 2
    fitnessG2[d] = (duskFitness[d] + notDuskFitness[d]) / 2
  end
  # Next order the daily fitnesses, and weight so that the least fit day
  # contributes most to the fitness.
  sort!(fitnessG1; rev = true)
  sort!(fitnessG2; rev = true)
  # Remember that currently, a low number is a poor fitness.
  allG1fitness::Array{Float64} = []
  allG2fitness::Array{Float64} = []
  for d in 1:GeneticAlgorithms.ALLDAYS
    thisG1fitness = repmat([fitnessG1[d]], 2^d, 1)
    thisG2fitness = repmat([fitnessG2[d]], 2^d, 1)
    allG1fitness = [allG1fitness, thisG1fitness]
    allG2fitness = [allG2fitness, thisG2fitness]
  end

  score = 1 - mean([allG1fitness, allG2fitness])
end

function isless(lhs::EvolvableNetwork, rhs::EvolvableNetwork)
  println("calling isless method...")
  abs(lhs.fitness) > abs(rhs.fitness)
end

function group_entities(pop)
  # Kill off the 35% least fit networks
  #TODO: Change this percentage to a global constant.
  threshold = floor(0.35 * length(pop))
  pop = pop[1:end-threshold]
  # Stop when the top 50% of networks have optimal fitness.
  if sum([pop[x].fitness for x in 1:(ceil(length(pop)/2))]) < 0.00001
    return
  end
  # Keeping population that didn't get killed off.
  produce(pop)
  # Selecting groupings that will become parents.
  for i in 1:threshold
    #TODO: Something less stong than an exponential distribution to reduce
    #      the chance of getting stuck in a local minimum. Carl and James
    #      used 1/sqrt(rank).
    ind = round(rand(Truncated(Exponential(2), 1, length(pop)), 2))
    produce([ind[1], ind[2]])
  end
end

Base.convert(::Type{Network}, T::Type{Network}) = T

function crossover(group::Array{Any})
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
  child.net.concseries = dynamic_simulation(child.net,
                                            GeneticAlgorithms.NNODES,
                                            GeneticAlgorithms.ALLMINS,
                                            GeneticAlgorithms.MAXLAG)
  child
end

function mutate(ent)
  # Path sign switch mutations.
  if rand(Float64) < GeneticAlgorithms.MUTATEPATH
    pathind = (rand(Uint) % length(ent.net.paths)) + 1
    (ent.net.transmats[pathind], ent.net.paths[pathind]) =
      mutate_path(ent.net.paths[pathind], ent.net.transmats[pathind])
  end
  # Transition matrix mutations.
  if rand(Float64) < GeneticAlgorithms.MUTATETMAT
    tmatind = (rand(Uint) % length(ent.net.transmats)) + 1
    (ent.net.transmats[tmatind], ent.net.paths[tmatind]) =
      mutate_tmat(ent.net.transmats[tmatind], ent.net.paths[tmatind])
  end
  # Lag duration mutations.
  if rand(Float64) < GeneticAlgorithms.MUTATELAG
    lagind = (rand(Uint) % length(ent.net.lags)) + 1
    ent.net.lags[lagind] = mutate_lag(ent.net.lags[lagind])
  end
  # Gate type switch mutations.
  if rand(Float64) < GeneticAlgorithms.MUTATEGATE
    gateind = (rand(Uint) % length(ent.net.gates)) + 1
    ent.net.gates[gateind] = mutate_gate(ent.net.gates[gateind])
  end
  ent
end

function mutate_path(path::Array{Int64}, transmat::Array{Float64})
  # Mutation causes the path to switch according to following options:
  # activator >> repressor
  # activator >> no interaction
  # repressor >> activator
  # repressor >> no interaction
  # no interaction >> activator
  # no interaction >> stochastic activator
  # no interaction >> repressor
  # no interaction >> stochastic repressor
  # If a stochastic interaction is introduced, its transition matrix starts
  # with 50%/50% probabilities.
  if sum(unique(path)) != 1         # Activation or repression
    randselect = rand()
    if randselect <= 0.75
      path = -path
    elseif randselect <= 1
      path = zeros(Int64, GeneticAlgorithms.ALLMINS)
    end
  elseif sum(unique(path)) == 0     # No interaction
    randselect = rand()
    if randselect <= 0.4
      path = ones(Int64, GeneticAlgorithms.ALLMINS)
    elseif randselect <= 0.5
      transmat = [0.5 0.5; 0.5 0.5]
      g = MarkovGenerator([0, 1], transmat)
      path = generate(g, GeneticAlgorithms.ALLMINS)
    elseif randselect <= 0.9
      path = -1 * ones(Int64, GeneticAlgorithms.ALLMINS)
    elseif randselect <= 1
      transmat = [0.5 0.5; 0.5 0.5]
      g = MarkovGenerator([0, -1], transmat)
      path = generate(g, GeneticAlgorithms.ALLMINS)
    end
  end
  (transmat, path)
end

function mutate_tmat(transmat::Array{Float64}, path::Array{Int64})
  # Generate new value from truncated normal distribution
  #TODO: The way this is programmed currently means that a 2x2 transition
  #      matrix is required (i.e. only two states). This should be generalised.
  if length(unique(path)) > 1 # Only works for stochastic interactions.
    transmat[1, 1] = cts_neighbr(transmat[1, 1], GeneticAlgorithms.TMAT_STD, 0, 1)
    transmat[1, 2] = cts_neighbr(transmat[1, 2], GeneticAlgorithms.TMAT_STD, 0, 1)
    transmat[2, 1] = 1 - transmat[1, 1]
    transmat[2, 2] = 1 - transmat[1, 2]
    g = MarkovGenerator(unique(path), transmat)
    path = generate(g, GeneticAlgorithms.ALLMINS)
  end
  (transmat, path)
end

function mutate_lag(lag::Int64)
  lag = round(cts_neighbr(lag, GeneticAlgorithms.LAG_STD, 0,
                          GeneticAlgorithms.MAXLAG))
end

function cts_neighbr(val::Number, stdev::Number, lower::Number, upper::Number)
  tnorm = Truncated(Normal(val, stdev), lower, upper)
  newval = rand(tnorm)
end

function mutate_gate(gate::Int64)
  # Mutation causes gate to switch (0 = or; 1 = and)
  # either or >> and
  # or and >> or
  gate = mod(gate+1, 2)
end


end
