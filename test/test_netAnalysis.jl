# Tests for find_cycles_from

testnethashes = [{"net" =>
                  "params" =>
                  "ncycles" => }
                 {"net" =>
                  "params" =>
                  "ncycles" => }]

testhashes = [{"activepaths" => [(0,0) (1,2) (0,0) (0,0);
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

function test_count_cycles(testhashes::Array{Dict})

  for n in 1:length(testhashes)

    ncycles = countcycles(testhashes[n]["net"], testhashes[n]["params"])

    @assert ncycles == testhashes[n]["ncycles"]

  end

end


function test_find_cycles(testhashes::Array{Dict})

  for n in 1:length(testhashes)

    cycles = Array{Int64}[]

    routematrix = zeros(Int64, 4, 4)
    routearray = Int64[]

    testhashes[n]["activepaths"]

    explorer = @task find_cycles_from(1, routematrix, routearray,
                                      4, activepaths)

    while !istaskdone(explorer)
      cycle = consume(explorer)
      cycle != nothing && push!(cycles, cycle)
    end
    println("cycles:\n$cycles")

    @assert cycles == testhashes[n]["cyclesout"]

  end
end




test_find_cycles(testhashes)

test_count_cycles(testnethashes)
