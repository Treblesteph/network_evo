using DataFrames
using Gadfly

import BoolNetwork.Network

function setShadeFrame(net::Network, params::Dict)

  days = params["envsignal"]
  dawns = params["gene1fit"]
  dusks = params["gene2fit"]

  daysstarts = (dawns[:, size(dawns, 2)] + 1) / 60
  dusksends = dusks[:, size(dusks, 2)] / 60
  daysends = (dusks[:, 1] - 1) / 60
  nightsstarts = dusksends + 1 / 60
  nightsends = 24 + daysstarts - 1 / 60
  dawnsstarts = dawns[:, 1] / 60
  dawnsends = dawns[:, size(dawns, 2)] / 60
  dusksstarts = dusks[:, 1] / 60

  startswrongorder = [dawnsstarts, daysstarts, dusksstarts, nightsstarts]
  endswrongorder = [dawnsends, daysends, dusksends, nightsends]
  startsreshape = reshape(startswrongorder, params["alldays"], params["nnodes"])
  endsreshape = reshape(endswrongorder, params["alldays"], params["nnodes"])
  startstranspose = transpose(startsreshape)
  endstranspose = transpose(endsreshape)
  starts = startstranspose[:]
  ends = endstranspose[:]

  shadeframe = DataFrame()
  shadeframe[:starts] = repeat(starts, outer = [params["nnodes"]])
  shadeframe[:ends] = repeat(ends, outer = [params["nnodes"]])
  shadeframe[:y] = repeat(ones(size(dawns, 1) +
                               size(dusks, 1) +
                               length(days) +
                               length(days)), outer = [params["nnodes"]])
  shadeframe[:row] = repeat([1:params["nnodes"]], inner = [(convert(Int64,
                            length(shadeframe[:y]) / params["nnodes"]))])

  return shadeframe

end

function setColours()

  g1colour = "mediumturquoise"
  # g2colour = "orchid"
  # g3colour = "dodgerblue"
  # g4colour = "coral"
  dawncolour = "palegoldenrod"
  daycolour = "cornsilk"
  duskcolour = "lightgrey"
  nightcolour = "azure2"

  colourscheme = [g1colour, dawncolour, daycolour, duskcolour, nightcolour]

end

function setConcFrame(net::Network, params::Dict)
  concframe = DataFrame()

  concframe[:time] = (1:params["alldays"] * 24 * 60) / 60
  concframe[:gene] = net.concseries[:, 1]
  concframe[:gene2] = net.concseries[:, 2]
  concframe[:gene3] = net.concseries[:, 3]
  concframe[:gene4] = net.concseries[:, 4]

  concframe = stack(concframe, 2:ncol(concframe))
  rename!(concframe, :value, :gene)
  return concframe
end

function plotConcs(net::Network, params::Dict, filename::String)

  colourscheme = setColours()

  concframe = setConcFrame(net, params)

  shadeframe = setShadeFrame(net, params)

  plot1 = plot(Scale.x_continuous(minvalue = 0,
                                  maxvalue = 24*params["alldays"]),
               Scale.y_continuous(minvalue = 0, maxvalue = 1),
               Geom.subplot_grid(
                layer(concframe, x = "time", y = "gene",
                      color = "variable", ygroup = "variable",
                      Geom.line),
                layer(shadeframe, xmin = "starts", xmax = "ends",
                      y = "y", ygroup = "row",
                      Geom.bar(position=:dodge),
                      color = repeat(["dawns", "dusks", "days", "nights"],
                                     outer = [params["alldays"]*params["nnodes"]])),
                Scale.color_discrete_manual(colourscheme...)))

  figwidth = 2 * params["alldays"]
  draw(PDF("../runs/plot$(filename).pdf", figwidth * 1inch, 12inch), plot1)
end

function plotConcs(net::Network, params::Dict)

  colourscheme = setColours()

  concframe = setConcFrame(net, params)

  shadeframe = setShadeFrame(net, params)

  plot(Scale.x_continuous(minvalue = 0, maxvalue = 24*params["alldays"]),
       Scale.y_continuous(minvalue = 0, maxvalue = 1),
       Geom.subplot_grid(
        layer(concframe, x = "time", y = "gene",
              color = "variable", ygroup = "variable", Geom.line),
        layer(shadeframe, xmin = "starts", xmax = "ends",
              y = "y", ygroup = "row",
              Geom.bar(position=:dodge),
              color = repeat(["dawns", "dusks", "days", "nights"],
                             outer = [params["alldays"]*params["nnodes"]])),
        Scale.color_discrete_manual(colourscheme...)))

end

function plotFitness(topfitness, meanfitness, xmax, filename::String)
                     maxfit = max(topfitness...)

  fitnessframe = DataFrame()
  fitnessframe[:timepoint] = 1:xmax
  fitnessframe[:topfit] = topfitness[1:xmax]
  fitnessframe[:meanfit] = meanfitness[1:xmax]

  fitnessframe = stack(fitnessframe, 2:ncol(fitnessframe))

  plot1 = plot(Scale.x_continuous(minvalue = 0, maxvalue = xmax),
               Scale.y_continuous(minvalue = 0, maxvalue = maxfit),
               fitnessframe, x = "timepoint", y = "value",
               color = "variable", Geom.line)
  draw(PDF("../runs/fitness$(filename).pdf", 240inch, 12inch), plot1)

end
