import BoolNetwork.Network
importall Base

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

  activepaths = get_active_paths(net, params["nnodes"])

  cycles = Array{Int64}[]

  routematrix = zeros(Int64, params["nnodes"], params["nnodes"])
  routearray = Int64[]

  for n in 1:params["nnodes"]     # Looping over each node.

    explorer = @task find_cycles_from(n, routematrix, routearray,
                                      params["nnodes"], activepaths)

    while !istaskdone(explorer)
      cycle = consume(explorer)
      cycle != nothing && push!(cycles, cycle)
    end

  end
  println("cycles before pruning:\n$cycles")
  cycles = prunecycles!(cycles)
  println("cycles after pruning:\n$cycles")
  return length(cycles)
end

# routematrix will be nnodes x nnodes matrix with ones entered into paths
# that have been traversed already.
# routearray will be an array with the list of nodes in the current route

function find_cycles_from(node::Int64, routematrix, routearray,
                          nnodes, activepaths)
  for m in 1:nnodes # Looping over all outgoing paths.

    # If the path is active, and has not already been traversed:
    if (activepaths[node, m] != (0, 0)) && routematrix[node, m] == 0
      thisroutearr = copy(routearray)
      push!(thisroutearr, activepaths[node, m]...)
      thisroutemat = copy(routematrix)
      thisroutemat[node, m] = 1
      println("route matrix:\n$thisroutemat")
      find_cycles_from(m, thisroutemat, thisroutearr, nnodes, activepaths)
    end
    if length(routearray) > 0 && activepaths[node, m][2] == routearray[1]
      if routearray[1] == routearray[end]
        produce(routearray)
      else
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

function prunecycles!(cycles::Array{Array{Int64}})
  # TODO: Make new method for isless that compares arrays by their length.
  sort!(cycles, ; rev = true)
  for i in 1:length(cycles) - 1
    for j in (i + 1):length(cycles)
      k = 1
      for k in 1:length(cycles[i])
        if find(x -> x == cycles[i][k]) == []
          break




  for i in 1:length(cycles)
    for j in 1:length(cycles)
      if findin(cycles[i], cycles[j])
      indices = findin(cycles[i], cycles[j])
      # See whether the indices are consecutive numbers:
      if all(t -> indices[t] == indices[t + 1] - 1, 1:(length(indices) - 1))
        cycles[findfirst(r -> r == cycles[j], cycles)] = [0]
      end
    end
  end
  println("cycles before splice: $cycles")
  deleteat!(cycles, find(r -> r == [0], cycles))
  return cycles

end

# Array of hashes of size 3 for tests:
  # activepaths
  # cycles output
  # description of behaviour - what is it testing for?
    # test that a simple non-cycle path does not get detected as a cycle
    # test that a simple cycle does get detected as a cycle

testhash = [{"activepaths" => [(0,0) (1,2) (0,0) (0,0);
                               (0,0) (0,0) (2,3) (0,0);
                               (0,0) (0,0) (0,0) (0,0);
                               (0,0) (0,0) (0,0) (0,0)],
             "cyclesout" => [],
             "behaviour" => "Tests that a simple non-cyclic path does
                             not get detected as a cycle."},
            {"activepaths" => [(0,0) (1,2) (0,0) (0,0);
                               (0,0) (0,0) (2,3) (0,0);
                               (3,1) (0,0) (0,0) (0,0);
                               (0,0) (0,0) (0,0) (0,0)],
             "cyclesout" => [[1, 2, 2, 3, 3, 1]],
             "behaviour" => "Tests that one simple cyclic path does
                             get detected as a cycle."},
            {"activepaths" => [(1,1) (1,2) (0,0) (0,0);
                               (0,0) (0,0) (2,3) (0,0);
                               (3,1) (0,0) (0,0) (0,0);
                               (0,0) (0,0) (0,0) (0,0)],
             "cyclesout" => [[1, 1], [1, 2, 3, 3, 1]],
             "behaviour" => "Tests that an autoregulation and a simple
                             cyclic path do not get overcounted."}]

function test_find_cycles(testhash::Array{Dict})

  cycles = Array{Int64}[]

  routematrix = zeros(Int64, 4, 4)
  routearray = Int64[]

  activepaths = [(1,1) (1,2) (0,0) (0,0);
                 (0,0) (0,0) (2,3) (0,0);
                 (3,1) (0,0) (0,0) (0,0);
                 (0,0) (0,0) (0,0) (0,0)]

  explorer = @task find_cycles_from(1, routematrix, routearray,
                                    4, activepaths)

  while !istaskdone(explorer)
    cycle = consume(explorer)
    cycle != nothing && push!(cycles, cycle)
  end
  println("cycles:\n$cycles")
end

test_find_cycles()
