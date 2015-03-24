cd("../lib")
import Parameters
import BoolNetwork
include("../lib/runboolclock.jl")

params = set_parameters()
add_clock_params!(params, 9, true)

x = params["minlag"]

acts = [round(0*60), round(0*60), round(12.95*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(0*60)]

reps = [round(0*60), round(0*60), round(0*60), round(0*60),
        round(0*60), round(0*60), round(0*60), round(11.13*60),
        round(0*60), round(0*60), round(3.2*60), round(6.9*60),
        round(0*60), round(0*60), round(0*60), round(0*60)]

envs = [round(0*60), round(0.08*60), round(10.8*60), round(8.52*60)]

gates = [false, true, false, false]

net = Network(convert(Array{Int64}, acts), convert(Array{Int64}, reps),
              gates, convert(Array{Int64}, envs), params)
