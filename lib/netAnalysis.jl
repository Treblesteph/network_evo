import BoolNetwork.Network

#Indices:
  # paths from 1: 1, 5, 9, 13
  # paths from 2: 2, 6, 10, 14
  # paths from 3: 3, 7, 11, 15
  # paths from 4: 4, 8, 12, 16

  # paths to 1: 1, 2, 3, 4
  # paths to 2: 5, 6, 7, 8
  # paths to 3: 9, 10, 11, 12
  # paths to 4: 13, 14, 15, 16

  # for n nodes: paths from k: k, k+n, k+2n, ..., k+(n-1)n

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

  activepaths = get_active_paths(net, params)

  cycles::Array{Array{Int64}}

  for n in 1:params["nnodes"]     # Looping over each node.

    explorer = @task find_cycles_from(n)
    cycles = consume(explorer)

  end
end

# routematrix will be nnodes x nnodes matrix with ones entered into paths
# that have been traversed already.
# routearray will be an array with the list of nodes in the current route

function find_cycles_from(node::Int64,
  routematrix = zeros(Int64, params["nnodes"], params["nnodes"]),
  routearray = Int64[])
  for m in 1:params["nnodes"] # Looping over all outgoing paths.

    # If the path is active, and has not already been traversed:
    if (activepaths[node, m] != (0, 0)) && routematrix[node, m] == 0
      push!(routearray, activepaths[node, m])
      routematrix[node, m] = 1
      find_cycles_from(m, copy(routematrix), copy(routearray))
    end
    if activepaths[node, m] == routearray[1]
      produce(routearray)
    end
  end
end


function get_active_paths(net::Network, params::Dict)

  paths = zeros(Int64, params["nnodes"]^2)

  for n in 1:params["nnodes"]^2
    paths[n] = sum(net.paths[n])
  end

  paths = reshape(paths, params["nnodes"], params["nnodes"])

  allpathroutes = Array((Int64, Int64), params["nnodes"], params["nnodes"])
  for k in 1:params["nnodes"]
    for j in 1:params["nnodes"]
      allpathroutes[k, j] = (k, j)
    end
  end

  activeroutes = copy(allpathroutes)
  activeroutes[find(x -> x == 0, paths)] = (0, 0)

  return activeroutes

end
