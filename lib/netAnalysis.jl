module netAnalysis

using BoolNetwork

importall Base

# Check for presence of each path from node 1
  # start with lowest (i.e. immediate feedback)
  # should be some sort of recursive function that eventually always looks for the lowest index path

# Sum of length 1 loops
# Sum of length 2 loops / 2
# ...
# Sum of length j loops / j -this is because they will be counted from each of their containing nodes

# Definition of a feedback loop:
  # continuous path from node k, back to node k
  # no path traversed more than once
  # must not contain any sub-cycle (may be easiest to prune supercycles at the end)
  # must not be congruent to any other cycle (divide count for cycle length m by m
  #                                           or not enumerate in the first place)

# Terminate conditions
  # if chain[1] == chain[end]
  # or only unexplored paths in row are (0,0)

function count_light_inputs(net::Network, params::Dict)

  inputs::Int64 = sum(net.envpaths)

end

function count_cycles(net::Network, params::Dict)
  cycles = get_cycles(net, params)
  ncycles = length(cycles)
end

function get_cycles(net::Network, params::Dict)

  activepaths = get_active_paths(net, params["nnodes"])

  cycles = Array{Int64}[]

  traversed = zeros(Int64, params["nnodes"], params["nnodes"])
  routearray = Int64[]

  for n in 1:params["nnodes"]     # Looping over each node.

    # Setting the traversed so that paths cannot go to genes lower than
    # node that we are finding cycles from. This should only happen if we
    # are on the top level (i.e. not in a recursive call) since it is due
    # to double-counting of cycles from different nodes (e.g. 1-2-2-3-3-1
    # and 2-3-3-1-1-2).
    for j in 1:(n - 1)
      traversed[:, j] = 1
      traversed[j, :] = 1
    end

    # Setting cycle to start on current node.
    routearray = [n]

    explorer = @task find_cycles_from(n, traversed, routearray,
                                      params["nnodes"], activepaths)

    while !istaskdone(explorer)
      cycle = consume(explorer)
      cycle != nothing && push!(cycles, cycle)
    end

  end
  println("cycles before prune:\n$cycles")
  cycles = pruneroutes!(cycles)
  println("cycles after prune:\n$cycles")
  return cycles
end

function countrepsacts(net::Network, cycle::Array{Int64}, nnodes)

  cyclepaths = [Int64[] for i in 1:(length(cycle) - 1)]
  for i in 1:(length(cycle) - 1)
    cyclepaths[i] = [cycle[i:(i + 1)]]
  end

  actindex = find(x -> findfirst(x, 1) != 0, net.paths)
  repindex = find(x -> findfirst(x, -1) != 0, net.paths)

  activepaths = get_active_paths(net, nnodes)

  actpaths = [Int64[] for i in 1:length(actindex)]
  reppaths = [Int64[] for i in 1:length(repindex)]

  for i in 1:length(actindex)
    actpaths[i] = [activepaths[i]...]
  end

  for i in 1:length(repindex)
    reppaths[i] = [activepaths[i]...]
  end

end

# traversed will be nnodes x nnodes matrix with ones entered into paths
# that have been traversed already.
# routearray will be an array with the list of nodes in the current route

function find_cycles_from(node::Int64, traversed, routearray,
                          nnodes, activepaths)

  for m in 1:nnodes # Looping over all outgoing paths.

    # If the path is active, and has not already been traversed, and if
    # the first element is not equal to the last (i.e. not already a cycle):
    if (activepaths[node, m] != (0, 0)) &&
       (traversed[node, m] == 0) &&
       ((routearray[1] != routearray[end]) || length(routearray) == 1)
      thisroutearr = copy(routearray)
      push!(thisroutearr, activepaths[node, m][2])
      thistraversed = copy(traversed)
      thistraversed[node, m] = 1
      find_cycles_from(m, thistraversed, thisroutearr, nnodes, activepaths)
    end
    if length(routearray) > 0 && activepaths[node, m][2] == routearray[1]
      if (routearray[1] == routearray[end]) || (length(routearray) != 1)
        produce([routearray, activepaths[node, m][2]])
      end
    end
  end
end


function get_active_paths(net::Network, nnodes)

  paths = zeros(Int64, nnodes^2)

  for n in 1:nnodes^2
    paths[n] = sum(net.paths[n])
  end

  paths = reshape(paths, nnodes, nnodes)

  allpathroutes = Array((Int64, Int64), nnodes, nnodes)
  for k in 1:nnodes
    for j in 1:nnodes
      allpathroutes[k, j] = (k, j)
    end
  end

  activeroutes = copy(allpathroutes)
  activeroutes[find(x -> x == 0, paths)] = (0, 0)

  return activeroutes

end

function isless(lhs::Array, rhs::Array)
  length(lhs) < length(rhs)
end

function pruneroutes!(routes)

  routes = sort!(routes)

  for r in 1:(length(routes) - 1)
    if routes[r] != [0]
      len = length(routes[r])

      for i in (r+1):(length(routes))
        subsets = [Int64[] for ii in 1:(length(routes[i]) - len + 1)]
        for k in 1:(length(routes[i]) - len + 1)
          subsets[k] = [routes[i][k:(k + len - 1)]]
        end
        if any(x -> x == routes[r], subsets)
          routes[i] = [0]
        end
      end
    end
  end

  deleteat!(routes, find(p -> p == [0], routes))
  return routes

end

end # netAnalysis module
