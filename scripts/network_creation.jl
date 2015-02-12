cd("../lib")
import Parameters
import BoolNetwork
include("../lib/runboolclock.jl")

params = set_parameters()
add_clock_params!(params, [repression, activation, noInteraction])

x = params["minlag"]

acts = [x, 0, x, 0, x, 0, 0, 0, 0, x, 0, 0, 0, 0, 0, 0]
reps = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

envs = [x, x, x, x]
gates = [false, false, false, false]

net = Network(acts, reps, gates, envs, params)
