using DataFrames
using Gadfly
using Cairo
include("runboolclock.jl")

function get_data(nruns::Int64, nphotpers::Int64, noise::Bool)

  data = DataFrame()
  data[:run] = 1:nruns

  feedbacks = Array(Int64, nruns)
  # circclocks = Array(Int64, nruns)
  inputs = Array(Int64, nruns)

  println("Running up to $(nruns)... ")
  for i in 1:nruns
    print("i")

    model = runclock(nphotpers, noise, false)
    net = model.population[1].net
    net = netAnalysis.analyse!(net, model.params)

    feedbacks[i] = net.analysis["cycles"]
    # circclocks[i] = net.analysis["oscillators"]
    inputs[i] = net.analysis["inputs"]

  end

  data[:feedbacks] = feedbacks
  # data[:circclocks] = circclocks
  data[:inputs] = inputs

  return data

end

function plot_data(data::DataFrame)

  data = stack(data, 2:ncol(data))

  plot1 = plot(data, x = "run", y = "value",
               Geom.subplot_grid(Geom.bar))

end


dat = get_data(10, 1, false)
plot_data(dat)
