module EvolveClock

importall Base

import BoolNetwork.runsim,
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

function create_entity(tup::(Int64, Int64, Dict))
  num = tup[1]; gen = tup[2]; params = tup[3]

  # Fixing gene-gene paths on for the first k generations.
  if gen < params["pathson"]
    netw = Network(params["interacttypes"][1:2], 100, fitness, params)
    # Using constructor 8
  else
    netw = Network(params["interacttypes"], 100, fitness, params)
    # Using constructor 8
  end

  EvolvableNetwork(netw)
end

# function create_entity(tup::(Int64, Dict))
#   num = tup[1]; params = tup[2]
#   netw = should_be_a_clock(params)
#   EvolvableNetwork(netw)
# end

function fitness(tup::(EvolvableNetwork, Dict))
  ent = tup[1]; params = tup[2]

  if ent.net.mutated
    return fitness(ent.net, params)
  else
    return ent.net.lastfitness
  end

end

#TODO: Make an additional fitness cost to clustering (niching), so that
#      the population remains more diverse.

function fitness(net::Network, params::Dict)
  n_genepaths = length(find(x -> sum(x) != 0, net.paths))
  n_envpaths = length(find(x -> x > 0, net.envpath))
  n_paths = n_genepaths + n_envpaths

  gene1 = net.concseries[:, 1]
  gene2 = net.concseries[:, 2]

  fitnessG1::Array{Float64} = zeros(params["alldays"] - 1)
  fitnessG2::Array{Float64} = zeros(params["alldays"] - 1)

  dawnFitness::Array{Float64} = zeros(params["alldays"] - 1)
  notDawnFitness::Array{Float64} = zeros(params["alldays"] - 1)
  duskFitness::Array{Float64} = zeros(params["alldays"] - 1)
  notDuskFitness::Array{Float64} = zeros(params["alldays"] - 1)

  # First working out the fitness for each day - excluding the first
  # to give the system time to stabilise.
  for d in 1:params["alldays"] - 1

    dawn = params["gene1fit"][d + 1, :]
    g1dawn = sum(gene1[dawn])
    notdawnstart = 1 + params["gene1fit"][d + 1, end] # End of dawn.
    notdawnend = (d + 1)*24*60 # End of day.
    notdawn = notdawnstart:notdawnend
    g1notdawn = sum(gene1[notdawn])

    dawnFitness[d] = 1 - (g1dawn / length(dawn))
    notDawnFitness[d] = g1notdawn / length(notdawn)

    dusk = params["gene2fit"][d + 1, :]
    g2dusk = sum(gene2[dusk])
    beforeduskstart = params["gene1fit"][d + 1, 1] # Start of day/dawn.
    beforeduskend = params["gene2fit"][d + 1, 1] - 1 # Start of dusk.
    afterduskstart = params["gene2fit"][d + 1, end] + 1 # End of dusk.
    afterduskend = (d + 1)*24*60 # End of day.
    notdusk = [beforeduskstart:beforeduskend, afterduskstart:afterduskend]
    g2notdusk = sum(gene2[notdusk])

    duskFitness[d] = 1 - (g2dusk / length(dusk))
    notDuskFitness[d] = g2notdusk / length(notdusk)

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
  for d in 1:(params["alldays"] - 1)
    thisG1fitness = repmat([fitnessG1[d]], (params["fitnessweight"])*d, 1)
    thisG2fitness = repmat([fitnessG2[d]], (params["fitnessweight"])*d, 1)
    allG1fitness = [allG1fitness, thisG1fitness]
    allG2fitness = [allG2fitness, thisG2fitness]
  end

  score = mean([allG1fitness, allG2fitness]) +
          n_paths / params["pathcostweight"]

  net.lastfitness = score

  return score

end

function troeinfit(net::Network, params::Dict)
  # Four terms make up the fitness, the expression of gene 1 during dawn,
  # gene 2 during dusk, the deterrence of low expression, and the
  # deterrence of superfluous paths that do not contribute to the fitness.
  gene1 = net.concseries[:, 1]
  gene2 = net.concseries[:, 2]

  # fitnessG1::Array{Float64} = zeros(params["alldays"] - 1)
  # fitnessG2::Array{Float64} = zeros(params["alldays"] - 1)

  dayG1::Array{Float64} = zeros(params["alldays"] - 1)
  dayG2::Array{Float64} = zeros(params["alldays"] - 1)
  dayexpmax::Array{Float64} = zeros(params["alldays"] - 1)
  dayfitSuperfluous::Array{Float64} = zeros(params["alldays"] - 1)

  # Looping over all days except the first, to give the system time to settle.

  for d in 1:params["alldays"]-1
    dayexp1 = sum(gene1[(1 + (d - 1) * 24 * 60):(d * 24 * 60)])
    dawnexp1 = sum(gene1[params["gene1fit"][d, :]])

    if dayexp1 == 0
      dayG1[d] = 1
    else
      dayG1[d] = dawnexp1 / dayexp1
    end

    dayexp2 = sum(gene2[(1 + (d - 1) * 24 * 60):(d * 24 * 60)])
    duskexp2 = sum(gene2[params["gene2fit"][d, :]])

    if dayexp2 == 0
      dayG2[d] = 1
    else
      dayG2[d] = duskexp2 / dayexp2
    end

    dayexpmax[d] = 0.01 * (2 - ((dayexp1 + dayexp2) / (60 * 24)))
    # dayfitSuperfluous = 0.001 *

  end

  fitnessG1 = 1 - mean(dayG1)
  fitnessG2 = 1 - mean(dayG2)
  fitnessExp = mean(dayexpmax)

  # Giving dawn/dusk matching more weight than expression level.
  score = fitnessExp + (fitnessG1 + fitnessG2) / 2
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

function isidentical(net1::Network, net2::Network)

  aredifferent = false

  aredifferent = aredifferent || net1.paths != net2.paths
  aredifferent = aredifferent || net1.transmats != net2.transmats
  aredifferent = aredifferent || net1.envpath != net2.envpath
  aredifferent = aredifferent || net1.lags != net2.lags
  aredifferent = aredifferent || net1.envlag != net2.envlag
  aredifferent = aredifferent || net1.gates != net2.gates

  areequal = !aredifferent
end

function crossover(tup::(Array{Any}, Dict, Bool))
  group = tup[1]; params = tup[2]; output = tup[3]

  # Do not perform crossover if parents are identical

  parent1 = group[1].net
  parent2 = group[2].net

  if (length(group) == 2) && isidentical(parent1, parent2)

    return group[1]

  else
    if output; print("x"); end

    # Initialising an empty network to be the child.
    num_parents = length(group)

    # Set each path according to a random choice between parents.
    childpaths = [Int8[] for i in 1:(params["nnodes"]^2)]
    childtmats = [zeros(Float64, 2, 2) for i in 1:(params["nnodes"]^2)]

    for i in 1:length(group[1].net.paths)
      parent = (rand(Uint) % num_parents) + 1
      childpaths[i] = group[parent].net.paths[i]
      childtmats[i] = group[parent].net.transmats[i]
    end

    # Set each environmental path according to a random choice between parents.
    childenvpath = zeros(Bool, params["nnodes"])
    for i in 1:length(group[1].net.envpath)
      parent = (rand(Uint) % num_parents) + 1
      childenvpath[i] = group[parent].net.envpath[i]
    end

    # Set each environmental lag according to a random choice between parents.
    childenvlag = zeros(Int64, params["nnodes"])
    for i in 1:length(group[1].net.envlag)
      parent = (rand(Uint) % num_parents) + 1
      childenvlag[i] = group[parent].net.envlag[i]
    end

    # Set each lag according to a random choice between parents.
    childlags = zeros(Int64, (params["nnodes"])^2)
    for i in 1:length(group[1].net.lags)
      parent = (rand(Uint) % num_parents) + 1
      childlags[i] = group[parent].net.lags[i]
    end

    # Set each gate according to a random choice between parents.
    childgates = zeros(Bool, params["nnodes"])
    for i in 1:length(group[1].net.gates)
      parent = (rand(Uint) % num_parents) + 1
      childgates[i] = group[parent].net.gates[i]
    end
    childgen = 1 + group[1].net.generation

    childnet = Network(childpaths, childtmats, childenvpath, childlags,
                       childenvlag, childgates, childgen)

    # Using constructor 4
    childnet.concseries = runsim(childnet, params)
    child = EvolvableNetwork(childnet)
  end
end

function mutate(tup::(EvolvableNetwork, Int64, Dict, Bool))
  ent = tup[1]; generationnum = tup[2]; params = tup[3]; output = tup[4]
  if output; print("."); end
  mutated = false
  # Keep all paths on during first k generations.
  if generationnum >= params["pathson"]
    # Path sign switch mutations.
    if rand(Float64) < params["mutatepath"]
      pathind = (rand(Uint) % length(ent.net.paths)) + 1
      mutate_path!(ent.net.paths, pathind, params, output)
      mutated = true
    end
  end
  # Transition matrix mutations.
  # --- off in non-stochastic simulations.
  # Environmental path mutations
  if rand(Float64) < params["mutateenvpath"]
    envpathind = (rand(Uint) % length(ent.net.envpath)) + 1
    ent.net.envpath[envpathind] =
        mutate_envpath!(ent.net.envpath, envpathind, params, output)
    mutated = true
  end
  # Lag duration mutations.
  if rand(Float64) < params["mutatelag"]
    lagind = (rand(Uint) % length(ent.net.lags)) + 1
    mutated = mutated || mutate_lag!(ent.net.lags, lagind, ent.net.paths,
                                     params, output)
  end
  # Environmental lag mutations
  if rand(Float64) < params["mutateenvlag"]
    envlagind = (rand(Uint) % length(ent.net.envlag)) + 1
    mutated = mutated || mutate_envlag!(ent.net.envlag, envlagind,
                                        ent.net.envpath, params, output)
  end
  # Gate type switch mutations.
  if rand(Float64) < params["mutategate"]
    gateind = (rand(Uint) % length(ent.net.gates)) + 1
    mutated = mutated || mutate_gate!(ent.net.gates, gateind,
                                      params, ent.net.paths, output)
  end

  ent.net.mutated = mutated

  if mutated
    ent.net.concseries = runsim(ent.net, params)
  end
  ent
end

function mutate_path!{T<:Array, N}(paths::Array{T, N}, index::Uint64,
                      params::Dict, output::Bool)
  # Mutation causes the path to switch according to following options:
  # activator >> repressor
  # activator >> no interaction
  # repressor >> activator
  # repressor >> no interaction
  # no interaction >> activator
  # no interaction >> repressor
  path = paths[index]
  if output; print("p"); end
  if sum(unique(path)) != 0
  # Activation or repression - stochastic or not
    randselect = rand()
    if randselect <= 0.5
      path = -path
    elseif randselect <= 1
      path = zeros(Int8, params["allmins"])
    end
  elseif sum(unique(path)) == 0
  # No interaction
    randselect = rand()
    if randselect <= 0.5
      path = ones(Int8, params["allmins"])
    elseif randselect <= 1
      path = -1 * ones(Int8, params["allmins"])
    end
  end
  paths[index] = path
end

function mutate_envpath!{T<:Bool}(envpaths::Array{T, 1}, index::Uint64,
                         params::Dict, output::Bool)
  envpath = envpaths[index]

  if output; print("e"); end
  envpath = mod(envpath + 1, 2) # This will switch 0 >> 1 or 1 >> 0

  envpaths[index] = envpath
end

function mutate_lag!{T<:Int64}(lags::Array{T, 1}, index::Uint64,
                     paths::Array{Array{Int8}}, params::Dict, output::Bool)
  lag = lags[index]
  path = paths[index]

  if output; print("l"); end
  lag = round(cts_neighbr(lag, params["lag_std"],
                          params["minlag"], params["maxlag"]))

  lags[index] = lag
  path_effect(path)
end

function mutate_envlag!{T<:Int64}(envlags::Array{T}, index::Uint64,
                        envpaths::Array{Bool}, params::Dict, output::Bool)
  envlag = envlags[index]
  envpath = envpaths[index]

  if output; print("d"); end
  envlag = round(cts_neighbr(envlag, params["envlag_std"],
                             params["minlag"], params["maxlag"]))
  envlags[index] = envlag
  envpath_effect(envpath)
end

function cts_neighbr(val::Number, stdev::Number, lower::Number, upper::Number)
  tnorm = Truncated(Normal(val, stdev), lower, upper)
  newval = rand(tnorm)
end

function path_effect(path::Array{Int8})
  sum(path) != 0
end

function envpath_effect(envpath::Bool)
  envpath
end

function mutate_gate!{T<:Bool}(gates::Array{T}, index::Uint64, params::Dict,
                               paths, output::Bool)
  gate = gates[index]
  if output; print("g"); end
  # Mutation causes gate to switch (0 = or; 1 = and)
  # either or >> and
  # or and >> or
  gate = mod(gate + 1, 2) # This will switch 0 >> 1 or 1 >> 0
  gates[index] = gate

  gate_effect(index, paths, params["nnodes"])
end

function gate_effect(gateindex::Uint64, paths::Array{Array{Int8}}, nnode)
  effect = false
  # Effect if gene has more than one input
    # Input path indices: gene 1: 1:4
    #                     gene 2: 5:8
    #                     gene 3: 9:12
    #                     gene 4: 13:16
  inputindices = 1 + ((gateindex - 1) * nnode) : gateindex * nnode

  incomingpaths = 0

  for n in 1:nnode
    if sum(paths[inputindices[n]]) != 0
      incomingpaths += 1
    end
  end

  if incomingpaths > 1
    effect = true
  end

  # Effect if gene is 1 or 2

  if (gateindex == 1) || (gateindex == 2)
    effect = true
  end

  # Effect if gene is not 1 or 2 but has outgoing paths

    # Output path indices: gene 1: 1, 5, 9, 13
    #                      gene 2: 2, 6, 10, 14
    #                      gene 3: 3, 7, 11, 15
    #                      gene 4: 4, 8, 12, 16

  outputindices = gateindex : nnode : gateindex + ((nnode - 1) * nnode)

  for n in 1:nnode
    if sum(paths[outputindices[n]]) != 0
      effect = true
    end
  end

  return effect
end

end # EvolveClock
