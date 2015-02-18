cd("../lib")
import Parameters
import BoolNetwork
include("../lib/runboolclock.jl")
include("../lib/netAnalysis.jl")

params = set_parameters()
add_clock_params!(params, [repression, activation, noInteraction])

x = params["minlag"]

#-------------------- Test case 1 --------------------#
println("\nTest 1...")

acts1 = [x, 0, x, 0, x, 0, 0, 0, 0, x, 0, 0, 0, 0, 0, 0]
reps1 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs1 = [x, x, x, x]
gates1 = [false, false, false, false]

net1 = Network(acts1, reps1, gates1, envs1, params)

count1 = netAnalysis.count_cycles(net1, params)

if count1 == 2
  print(" PASSED!")
else
  print(" FAILED!")
end

# Cycles [[1,1], [1,2,3,1]]

#-------------------- Test case 2 --------------------#
println("\nTest 2...")

acts2 = [0, 0, 0, x, x, 0, 0, x, 0, x, 0, 0, 0, 0, x, 0]
reps2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs2 = [x, x, x, x]
gates2 = [false, false, false, false]

net2 = Network(acts2, reps2, gates2, envs2, params)

count2 = netAnalysis.count_cycles(net2, params)

if count2 == 2
  print(" PASSED!")
else
  print(" FAILED!")
end

# Cycles [[1,2,3,4,1], [2,3,4,2]]

#-------------------- Test case 3 --------------------#
println("\nTest 3...")

acts3 = [0, x, 0, x, 0, 0, 0, x, x, 0, 0, 0, 0, 0, x, x]
reps3 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs3 = [x, x, x, x]
gates3 = [false, false, false, false]

net3 = Network(acts3, reps3, gates3, envs3, params)

count3 = netAnalysis.count_cycles(net3, params)

if count3 == 3
  print(" PASSED!")
else
  print(" FAILED!")
end

# Cycles [[1,3,4,1], [1,3,4,2,1], [4,4]]

#-------------------- Test case 4 --------------------#
println("\nTest 4...")

acts4 = [x, 0, 0, 0, 0, x, 0, x, 0, 0, x, 0, 0, x, 0, x]
reps4 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs4 = [x, x, x, x]
gates4 = [false, false, false, false]

net4 = Network(acts4, reps4, gates4, envs4, params)

count4 = netAnalysis.count_cycles(net4, params)

if count4 == 5
  print(" PASSED!")
else
  print(" FAILED!")
end

# Cycles [[1,1], [2,2], [3,3], [4,4], [2,4,2]]

#-------------------- Test case 5 --------------------#
println("\nTest 5...")

acts5 = [x, 0, 0, 0, 0, x, 0, 0, 0, 0, x, 0, 0, 0, 0, x]
reps5 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs5 = [x, x, x, x]
gates5 = [false, false, false, false]

net5 = Network(acts5, reps5, gates5, envs5, params)

count5 = netAnalysis.count_cycles(net5, params)

if count5 == 4
  print(" PASSED!")
else
  print(" FAILED!")
end

# Cycles [[1,1], [2,2], [3,3], [4,4]]
