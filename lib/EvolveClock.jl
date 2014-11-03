module EvolveClock

import NetworkSimulation.runsim,
       BoolNetwork.Network,
       GeneticAlgorithms.Entity

export Network,
       EvolvableNetwork,
       net2hash

using Distributions

#-----------

type EvolvableNetwork <: Entity
  net::Network
  fitness
  EvolvableNetwork(net) = new(net, nothing)
end

function create_entity(tup::(Int64, Dict))
  num = tup[1]; params = tup[2]
  netw = Network(params["allmins"], params["nnodes"], params["maxlag"],
                 params["minlag"], params["decisionhash"],
                 params["envsignal"], params["interacttypes"], 50,
                 fitness, params::Dict)
  EvolvableNetwork(netw)
end

# function create_entity(tup::(Int64, Dict))
#   num = tup[1]; params = tup[2]
#   netw = should_be_a_clock(params)
#   EvolvableNetwork(netw)
# end

function fitness(tup::(EvolvableNetwork, Dict))
  ent = tup[1]; params = tup[2]
  fitness(ent.net, params)
end

#TODO: Make an additional fitness cost to clustering (niching), so that
#      the population remains more diverse.

function fitness(net::Network, params::Dict)
  gene1 = net.concseries[:, 1]
  gene2 = net.concseries[:, 2]

  fitnessG1::Array{Float64} = zeros(params["alldays"])
  fitnessG2::Array{Float64} = zeros(params["alldays"])

  dawnFitness::Array{Float64} = zeros(params["alldays"])
  notDawnFitness::Array{Float64} = zeros(params["alldays"])
  duskFitness::Array{Float64} = zeros(params["alldays"])
  notDuskFitness::Array{Float64} = zeros(params["alldays"])

  # First working out the fitness for each day.
  for d in 1:params["alldays"]
    dawnFitness[d] = sum(gene1[params["gene1fit"][d, :]]) /
                     length(params["gene1fit"][d, :])
    notDawnFitness[d] = 1 - (sum(gene1[(1 +
                        params["gene1fit"][d, end]):(d * 24 * 60)]) /
                        length((1 +
                        params["gene1fit"][d, end]):(d * 24 * 60)))
    duskFitness[d] = sum(gene2[params["gene2fit"][d, :]]) /
                     length(params["gene2fit"][d, :])
    notDuskFitness[d] = 1 - (sum(gene2[1 + (d - 1) * 24 *
                        60:(params["gene2fit"][d, 1] - 1)]) /
                        length(1 + (d - 1) * 24 *
                        60:(params["gene2fit"][d, 1] - 1)))
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
  for d in 1:params["alldays"]
    thisG1fitness = repmat([fitnessG1[d]], (params["fitnessweight"])*d, 1)
    thisG2fitness = repmat([fitnessG2[d]], (params["fitnessweight"])*d, 1)
    allG1fitness = [allG1fitness, thisG1fitness]
    allG2fitness = [allG2fitness, thisG2fitness]
  end

  score = 1 - mean([allG1fitness, allG2fitness])
end

function isless(lhs::EvolvableNetwork, rhs::EvolvableNetwork)
  println("calling isless method...")
  abs(lhs.fitness) > abs(rhs.fitness)
end

function group_entities(pop, params)
  threshold = floor(params["percentkilled"] * length(pop))
  pop = pop[1:end-threshold]
  # Stop when the top % of networks have optimal fitness.
  if sum([pop[x].fitness for x in 1:(ceil(length(pop) *
          params["stopconverged"]))]) < params["stopthreshold"]
    return
  end
  # Keeping population that didn't get killed off.
  produce(pop)
  # Selecting groupings that will become parents.
  for i in 1:threshold
    #TODO: Something less stong than an exponential distribution to reduce
    #      the chance of getting stuck in a local minimum. Carl and James
    #      used 1/sqrt(rank).
    ind = round(rand(Truncated(Exponential(params["parentselect"]), 1,
                     length(pop)), 2))
    produce([ind[1], ind[2]])
  end
end

Base.convert(::Type{Network}, T::Type{Network}) = T

#TODO: Make a more sophisticated crossover function that sets a switchpoint
#      number, and makes crossovers of multiple element blocks (rather than
#      each individual trait).

function crossover(tup::(Array{Any}, Dict))
  group = tup[1]; params = tup[2]
  print("x")
  # Initialising an empty network to be the child.
  num_parents = length(group)
  # Set each path according to a random choice between parents.
  childpaths::Array{Array{Int64}} = [Int64[] for i in 1:(params["nnodes"]^2)]
  childtmats::Array{Array{Float64}} = [Float64[] for i in 1:16]
  for i in 1:length(group[1].net.paths)
    parent = (rand(Uint) % num_parents) + 1
    childpaths[i] = group[parent].net.paths[i]
    childtmats[i] = group[parent].net.transmats[i]
  end
  # Set each environmental path according to a random choice between parents.
  childenvpath::Array{Int64} = zeros(Int64, params["nnodes"])
  for i in 1:length(group[1].net.envpath)
    parent = (rand(Uint) % num_parents) + 1
    childenvpath[i] = group[parent].net.envpath[i]
  end
  # Set each lag according to a random choice between parents.
  childlags::Array{Int64} = zeros(Int64, (params["nnodes"])^2)
  for i in 1:length(group[1].net.lags)
    parent = (rand(Uint) % num_parents) + 1
    childlags[i] = group[parent].net.lags[i]
  end
  # Set each gate according to a random choice between parents.
  childgates::Array{Int64} = zeros(Int64, params["nnodes"])
  for i in 1:length(group[1].net.gates)
    parent = (rand(Uint) % num_parents) + 1
    childgates[i] = group[parent].net.gates[i]
  end
  childgen = 1 + group[1].net.generation
  childpaths = transpose(reshape(childpaths, params["nnodes"],
                                 params["nnodes"]))
  for i in 1:length(childpaths)
    childpaths[i] = vec(childpaths[i])
  end
  childlags = transpose(reshape(childlags, params["nnodes"],
                                params["nnodes"]))
  #TODO: Create an array for generation, push new generation to the array
  #      each time the network survives for a new generation. To get generation
  #      from GeneticAlgorithms code, something like model.gen_num.
  childnet = Network(childpaths, childtmats, childenvpath, childlags,
                     childgates, childgen)
  childnet.concseries = runsim(childnet, params["nnodes"], params["allmins"],
                               params["maxlag"], params["envsignal"], params["decisionhash"])
  child = EvolvableNetwork(childnet)
end

function mutate(tup::(EvolvableNetwork, Dict))
  ent = tup[1]; params = tup[2]
  print(".")
  # Path sign switch mutations.
  if rand(Float64) < params["mutatepath"]
    pathind = (rand(Uint) % length(ent.net.paths)) + 1
    ent.net.paths[pathind] = mutate_path(ent.net.paths[pathind], params)
  end
  # Transition matrix mutations.
  # --- off in non-stochastic simulations.
  # Environmental path mutations
  if rand(Float64) < params["mutateenvpath"]
    envpathind = (rand(Uint) % length(ent.net.envpath)) + 1
    ent.net.envpath[envpathind] =
        mutate_envpath(ent.net.envpath[envpathind], params)
  end
  # Lag duration mutations.
  if rand(Float64) < params["mutatelag"]
    lagind = (rand(Uint) % length(ent.net.lags)) + 1
    ent.net.lags[lagind] = mutate_lag(ent.net.lags[lagind], params)
  end
  # Gate type switch mutations.
  if rand(Float64) < params["mutategate"]
    gateind = (rand(Uint) % length(ent.net.gates)) + 1
    ent.net.gates[gateind] = mutate_gate(ent.net.gates[gateind], params)
  end
  ent.net.concseries = runsim(ent.net, params["nnodes"], params["allmins"],
                              params["maxlag"], params["envsignal"],
                              params["decisionhash"])
  ent
end

function mutate_path(path::Array{Int64}, params::Dict)
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
      path = zeros(Int64, params["allmins"])
    end
  elseif sum(unique(path)) == 0
  # No interaction
    randselect = rand()
    if randselect <= 0.5
      path = ones(Int64, params["allmins"])
    elseif randselect <= 1
      path = -1 * ones(Int64, params["allmins"])
    end
  end
  path
end

function mutate_envpath(envpath::Int64, params::Dict)
  print("e")
  envpath = mod(envpath + 1, 2) # This will switch 0 >> 1 or 1 >> 0
end

function mutate_lag(lag::Int64, params::Dict)
  print("l")
  lag = round(cts_neighbr(lag, params["lag_std"],
                          params["minlag"], params["maxlag"]))
end

function cts_neighbr(val::Number, stdev::Number, lower::Number, upper::Number)
  tnorm = Truncated(Normal(val, stdev), lower, upper)
  newval = rand(tnorm)
end

function mutate_gate(gate::Int64, params::Dict)
  print("g")
  # Mutation causes gate to switch (0 = or; 1 = and)
  # either or >> and
  # or and >> or
  gate = mod(gate + 1, 2) # This will switch 0 >> 1 or 1 >> 0
end

function create_troein_1D(params::Dict)
  # Creating a boolean representation of the network shown in figure 1D of
  # Troein, Locke et al., 2009.
  # Activation from gene 3 to 4 (lag 2.61hr)
  # Repression from gene 3 to 1 (lag 2.61hr)
  # Repression from gene 4 to 2 (lag 14hr)
  # Light sensing in genes 1, 2, & 3
  # All gates set as "or"

  # First making a network with no interactions.
  interactions = [params["interacttypes"][3]]
  net = Network(params["allmins"], 4, 14*60, 5, params["decisionhash"],
                params["envsignal"], interactions)

  # Now overwriting the interactions, paths, envrionmental paths, and gates.
  net.paths[3] -= 1; net.paths[15] += 1; net.paths[8] -= 1;
  net.envpath = [1, 1, 1, 0]
  net.lags[3] = 157; net.lags[15] = 157; net.lags[8] = 840;
  net.gates = zeros(Int64, 4)

  net.concseries = runsim(net, 4, params["allmins"], 60*24,
                          params["envsignal"], params["decisionhash"])
  return net
end

function should_be_a_clock(params::Dict)

  # Creating a network that should pulse gene 1 on at dawn, and gene 2
  # on at dusk.

  # First making a network with no interactions.
  interactions = [params["interacttypes"][3]]
  net = Network(params["allmins"], 4, 24*60, 5, params["decisionhash"],
                params["envsignal"], interactions)

  # Now overwriting the interactions, paths, envrionmental paths, and gates.
  net.paths[1] -= 1; net.lags[1] = 3*60  # From gene 1 to gene 1
  net.paths[2]; net.lags[2]              # From gene 1 to gene 2
  net.paths[3]; net.lags[3]              # From gene 1 to gene 3
  net.paths[4]; net.lags[4]              # From gene 1 to gene 4
  net.paths[5] -= 1; net.lags[5] = 5     # From gene 2 to gene 1
  net.paths[6] -= 1; net.lags[6] = 24*60 # From gene 2 to gene 2
  net.paths[7] -= 1; net.lags[7] = 5     # From gene 2 to gene 3
  net.paths[8] -= 1; net.lags[8] = 24*60 # From gene 2 to gene 4
  net.paths[9] -= 1; net.lags[9] = 3*60  # From gene 3 to gene 1
  net.paths[10]; net.lags[10]            # From gene 3 to gene 2
  net.paths[11]; net.lags[11]            # From gene 3 to gene 3
  net.paths[12]; net.lags[12]            # From gene 3 to gene 4
  net.paths[13] -= 1; net.lags[13] = 3*60# From gene 4 to gene 1
  net.paths[14]; net.lags[14]            # From gene 4 to gene 2
  net.paths[15]; net.lags[15]            # From gene 4 to gene 3
  net.paths[16]; net.lags[16]            # From gene 4 to gene 4

  net.envpath = [0, 0, 0, 0]
  net.gates = zeros(Int64, 4)

  net.concseries = runsim(net, 4, params["allmins"], 60*24,
                          params["envsignal"], params["decisionhash"])
  return net
end


end # EvolveClock
