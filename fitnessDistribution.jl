# Checking the distribution of fitness across a large number of randomly
# generated networks.
using Gadfly
using Cairo

require("evolveclock.jl")
require("generate_networks.jl")

NNETS = 100

println("making population...")
population = pmap(create_network, [1:NNETS])
println(size(population))
println("evaluating population...")
scores = pmap(fitness, population)

plot(x = scores, Geom.histogram)
