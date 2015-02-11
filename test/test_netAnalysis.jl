module testNetAnalysis

using FactCheck
include("netAnalysis.jl")
import parameters

# Tests for find_cycles_from

facts("Checking that find_cycles_from works") do

  params = set_parameters()

  testnethashes = [{"net" => Network([0,0,5,0,5,0,0,0,0,5,0,0,0,0,0,0],
                                     [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                     [0,0,0,0],
                                     [0,0,0,0],
                                     params),
                    "params" => params,
                    "ncycles" => 1,
                    "behaviour" => "Testing for a simple network with one
                                    route including activation paths from
                                    1 to 2 to 3 and back to 1 - this should
                                    be counted as one cycle."},
                   {"net" => Network([5,0,0,5,0,0,0,0,5,0,0,0,0,0,5,0],
                                     [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
                                     [0,0,0,0],
                                     [0,0,0,0],
                                     params),
                    "params" => params,
                    "ncycles" => 2,
                    "behaviour" => "Testing for a simple network with one
                                    positive feedback loop (on gene 1),
                                    and another cyclic (of activations)
                                    from 1 to 3 to 4 and back to 1."}]

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

    @fact ncycles => testhashes[n]["ncycles"]

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

      @fact cycles => testhashes[n]["cyclesout"]
    end
  end
end




test_find_cycles(testhashes)

test_count_cycles(testnethashes)

end # testNetAnalysis module
