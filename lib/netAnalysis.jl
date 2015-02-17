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

function count_cycles(net::Network, params::Dict)

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

    println("traversed before find_cycles\n$traversed")

    explorer = @task find_cycles_from(n, traversed, routearray,
                                      params["nnodes"], activepaths)

    while !istaskdone(explorer)
      cycle = consume(explorer)
      cycle != nothing && push!(cycles, cycle)
    end

  end
  println("cycles:\n$cycles")
  return length(cycles)
end

# traversed will be nnodes x nnodes matrix with ones entered into paths
# that have been traversed already.
# routearray will be an array with the list of nodes in the current route

function find_cycles_from(node::Int64, traversed, routearray,
                          nnodes, activepaths)

  for m in 1:nnodes # Looping over all outgoing paths.

    # If the path is active, and has not already been traversed,
    # and if either routearray is empty, or the first element is
    # not equal to the last (i.e. not already a cycle):
    if (activepaths[node, m] != (0, 0)) &&
       (traversed[node, m] == 0) &&
       (routearray == [] ||
       routearray[1] != routearray[end])
      thisroutearr = copy(routearray)
      push!(thisroutearr, activepaths[node, m]...)
      thistraversed = copy(traversed)
      thistraversed[node, m] = 1
      println("traversed matrix:\n$thistraversed")
      find_cycles_from(m, thistraversed, thisroutearr, nnodes, activepaths)
    end
    if length(routearray) > 0 && activepaths[node, m][2] == routearray[1]
      if routearray[1] == routearray[end]
        println("case 1")
        produce(routearray)
      else
        println("case 2")
        produce([routearray, activepaths[node, m]...])
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


end # netAnalysis module
