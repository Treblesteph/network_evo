import NetworkSimulation.runsim, BoolNetwork.Network, EvolveClock.fitness

# Pruning fittest evolved networks in order to check for superfluous
# interactions (that do not contribute to fitness).

function prune(net::Network, params::Dict, counter=1)
  # Change each path to zero and check the fitness. If the change does not
  # decrease the fitness, keep the new network and prune again. Otherwise,
  # keep the old network and prune again.
  if counter <= length(net.paths)
    println(counter)

    pruned::Network = Network(copy(net.paths), copy(net.transmats),
                              copy(net.envpath), copy(net.lags),
                              copy(net.envlag), copy(net.gates))
    pruned.paths[counter] *= 0
    for n = 1:16
      println(pruned.paths[n][1])
    end
    pruned.concseries = runsim(pruned, params["nnodes"], params["allmins"],
                               params["maxlag"], params["envsignal"],
                               params["decisionhash"])

    origfit = fitness(net, params)
    prunefit = fitness(pruned, params)

    println("orig=$origfit prune=$prunefit")

    counter += 1

    if origfit > prunefit
      prune(pruned, params, counter)
    else
      prune(net, params, counter)
    end
  end

  return net
end
