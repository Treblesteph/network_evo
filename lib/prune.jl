import BoolNetwork.runsim, BoolNetwork.Network, EvolveClock.fitness

# Pruning fittest evolved networks in order to check for superfluous
# interactions (that do not contribute to fitness).

function prune(net::Network, params::Dict, counter=1)
  # Change each path to zero and check the fitness. If the change does not
  # decrease the fitness, keep the new network and prune again. Otherwise,
  # keep the old network and prune again.
  if counter <= length(net.paths)
    println("counter:$(counter). Paths:")

    paths::Array{Array{Int8, 1}, 1} = copy(net.paths)
    transmats::Array{Array{Float64, 2}, 1} = copy(net.transmats)
    envpath::Array{Bool, 1} = copy(net.envpath)
    lags::Array{Int64, 1} = copy(net.lags)
    envlag::Array{Int64, 1} = copy(net.envlag)
    gates::Array{Bool, 1} = copy(net.gates)

    pruned::Network = Network(paths, transmats, envpath, lags,
                              envlag, gates)
    # Using constructor 3
    pruned.paths[counter] *= 0
    for n = 1:16
      print("$(pruned.paths[n][1]), ")
    end

    net.concseries = runsim(net, params)

    pruned.concseries = runsim(pruned, params)

    origfit = fitness(net, params)
    prunefit = fitness(pruned, params)

    println("orig=$origfit pruned=$prunefit")

    counter += 1

    if origfit >= prunefit
      return prune(pruned, params, counter)
    else
      return prune(net, params, counter)
    end
  else
    return net
  end
end
