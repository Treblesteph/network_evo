cd("../lib")
import Parameters
import BoolNetwork
include("../lib/runboolclock.jl")

params = set_parameters()
add_clock_params!(params, 9, false)

x = params["minlag"]

acts = [round(0*60), round(0*60), round(9.98*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60)]

reps = [round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(6.98*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60)]

envs = [round(0*60), round(0.08*60), round(13.98*60), round(0*60)]

gates = [true, false, true, true]

net = Network(convert(Array{Int64}, acts), convert(Array{Int64}, reps),
              gates, convert(Array{Int64}, envs), params)
