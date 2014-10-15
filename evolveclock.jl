module clockga
import GeneticAlgorithms
using Distributions

include("generate_networks.jl");
include("dynamic_simulation.jl");

# Fitness parameters (can alter these):
const DAWNWINDOW = 3 # Hours
const DUSKWINDOW = 3 # Hours
const DAYTIME = 12   # Hours
#--------------------------------------
DAYS = zeros(Int64, GeneticAlgorithms.ALLDAYS, DAYTIME * 60)
DAWNS = zeros(Int64, GeneticAlgorithms.ALLDAYS, DAWNWINDOW * 60)
DUSKS = zeros(Int64, GeneticAlgorithms.ALLDAYS, DUSKWINDOW * 60)

for t = 1:GeneticAlgorithms.ALLDAYS # Converting to arrays of minutes.
  DAYS[t, :] = (1 + 60 * 24 * (t - 1)):(60 * (DAYTIME + 24 * (t - 1)))
  DAWNS[t, :] = (1 + 60 * 24 * (t - 1)):(60 * (DAWNWINDOW + 24 * (t - 1)))
  DUSKS[t, :] = (1+60*(12-DUSKWINDOW+24*(t-1))):(60*(12+24*(t-1)))
end

type EvolvableNetwork <: GeneticAlgorithms.Entity
  net::Network
  fitness
  EvolvableNetwork() = new(Network(GeneticAlgorithms.ALLMINS,
                                   GeneticAlgorithms.NNODES,
                                   GeneticAlgorithms.MAXLAG,
                                   GeneticAlgorithms.decisionhash, DAYS,
                                   [repression, activation,
                                    noInteraction]), nothing)
  EvolvableNetwork(net) = new(net, nothing)
end

function create_entity(num)
  netw = Network(GeneticAlgorithms.ALLMINS, GeneticAlgorithms.NNODES,
                 GeneticAlgorithms.MAXLAG, GeneticAlgorithms.decisionhash,
                 DAYS, [repression, activation, noInteraction], 50, fitness)
  # netw = create_troein_1D(GeneticAlgorithms.ALLMINS, DAYS)
  EvolvableNetwork(netw)
end

function fitness(ent::EvolvableNetwork)
  fitness(ent.net)
end

#TODO: Make an additional fitness cost to clustering (niching), so that
#      the population remains more diverse.

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
    thisG1fitness = repmat([fitnessG1[d]], 5*d, 1)
    thisG2fitness = repmat([fitnessG2[d]], 5*d, 1)
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
  # Kill off the 15% least fit networks
  #TODO: Change this percentage to a global constant.
  threshold = floor(0.15 * length(pop))
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

#TODO: Make a more sophisticated crossover function that sets a switchpoint
#      number, and makes crossovers of multiple element blocks (rather than
#      each individual trait).

function crossover(group::Array{Any})
  print("x")
  # Initialising an empty network to be the child.
  num_parents = length(group)
  # Set each path according to a random choice between parents.
  childpaths::Array{Array{Int64}} = [Int64[] for i in 1:(GeneticAlgorithms.NNODES^2)]
  childtmats::Array{Array{Float64}} = [Float64[] for i in 1:16]
  for i in 1:length(group[1].net.paths)
    parent = (rand(Uint) % num_parents) + 1
    childpaths[i] = group[parent].net.paths[i]
    childtmats[i] = group[parent].net.transmats[i]
  end
  # Set each environmental path according to a random choice between parents.
  childenvpath::Array{Int64} = zeros(Int64, GeneticAlgorithms.NNODES)
  for i in 1:length(group[1].net.envpath)
    parent = (rand(Uint) % num_parents) + 1
    childenvpath[i] = group[parent].net.envpath[i]
  end
  # Set each lag according to a random choice between parents.
  childlags::Array{Int64} = zeros(Int64, GeneticAlgorithms.NNODES^2)
  for i in 1:length(group[1].net.lags)
    parent = (rand(Uint) % num_parents) + 1
    childlags[i] = group[parent].net.lags[i]
  end
  # Set each gate according to a random choice between parents.
  childgates::Array{Int64} = zeros(Int64, GeneticAlgorithms.NNODES)
  for i in 1:length(group[1].net.gates)
    parent = (rand(Uint) % num_parents) + 1
    childgates[i] = group[parent].net.gates[i]
  end
  childgen = 1 + group[1].net.generation
  childpaths = transpose(reshape(childpaths, GeneticAlgorithms.NNODES,
                                 GeneticAlgorithms.NNODES))
  for i in 1:length(childpaths)
    childpaths[i] = vec(childpaths[i])
  end
  childlags = transpose(reshape(childlags, GeneticAlgorithms.NNODES,
                                GeneticAlgorithms.NNODES))
  #TODO: Create an array for generation, push new generation to the array
  #      each time the network survives for a new generation. To get generation
  #      from GeneticAlgorithms code, something like model.gen_num.
  childnet = Network(childpaths, childtmats, childenvpath, childlags,
                     childgates, childgen)
  childnet.concseries = dynamic_simulation(childnet, GeneticAlgorithms.NNODES,
                                           GeneticAlgorithms.ALLMINS,
                                           GeneticAlgorithms.MAXLAG, DAYS,
                                           GeneticAlgorithms.decisionhash)
  child = EvolvableNetwork(childnet)
end

function mutate(ent)
  print(".")
  # Path sign switch mutations.
  if rand(Float64) < GeneticAlgorithms.MUTATEPATH
    pathind = (rand(Uint) % length(ent.net.paths)) + 1
    ent.net.paths[pathind] = mutate_path(ent.net.paths[pathind])
  end
  # Transition matrix mutations.
  # --- off in non-stochastic simulations.
  # Environmental path mutations
  if rand(Float64) < GeneticAlgorithms.MUTATEENVPATH
    envpathind = (rand(Uint) % length(ent.net.envpath)) + 1
    ent.net.envpath[envpathind] = mutate_envpath(ent.net.envpath[envpathind])
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
  ent.net.concseries = dynamic_simulation(ent.net, GeneticAlgorithms.NNODES,
                                           GeneticAlgorithms.ALLMINS,
                                           GeneticAlgorithms.MAXLAG, DAYS,
                                           GeneticAlgorithms.decisionhash)
  ent
end

function mutate_path(path::Array{Int64})
  # Mutation causes the path to switch according to following options:
  # activator >> repressor
  # activator >> no interaction
  # repressor >> activator
  # repressor >> no interaction
  # no interaction >> activator
  # no interaction >> repressor
  print("p")
  if sum(unique(path)) != 0
  # Activation or repression - stochastic or not
    randselect = rand()
    if randselect <= 0.5
      path = -path
    elseif randselect <= 1
      path = zeros(Int64, GeneticAlgorithms.ALLMINS)
    end
  elseif sum(unique(path)) == 0
  # No interaction
    randselect = rand()
    if randselect <= 0.5
      path = ones(Int64, GeneticAlgorithms.ALLMINS)
    elseif randselect <= 1
      path = -1 * ones(Int64, GeneticAlgorithms.ALLMINS)
    end
  end
  path
end

function mutate_envpath(envpath::Int64)
  print("e")
  envpath = mod(envpath + 1, 2) # This will switch 0 >> 1 or 1 >> 0
end

function mutate_lag(lag::Int64)
  print("l")
  lag = round(cts_neighbr(lag, GeneticAlgorithms.LAG_STD, 0,
                          GeneticAlgorithms.MAXLAG))
end

function cts_neighbr(val::Number, stdev::Number, lower::Number, upper::Number)
  tnorm = Truncated(Normal(val, stdev), lower, upper)
  newval = rand(tnorm)
end

function mutate_gate(gate::Int64)
  print("g")
  # Mutation causes gate to switch (0 = or; 1 = and)
  # either or >> and
  # or and >> or
  gate = mod(gate + 1, 2) # This will switch 0 >> 1 or 1 >> 0
end


end
