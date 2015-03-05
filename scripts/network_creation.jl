cd("../lib")
import Parameters
import BoolNetwork
include("../lib/runboolclock.jl")

params = set_parameters()
add_clock_params!(params, 9, false)

x = params["minlag"]

acts = [0, 0, round(9.98*60), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
reps = [0, 0, 0, 0, 0, 0, round(6.98*60), 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs = [0, round(0.08*60), round(13.98*60), 0]
gates = [true, false, true, true]

net = Network(convert(Array{Int64}, acts), convert(Array{Int64}, reps),
              gates, convert(Array{Int64}, envs), params)
