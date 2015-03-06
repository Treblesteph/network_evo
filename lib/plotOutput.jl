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

  nphotoperiods = convert(Int64, params["alldays"]/params["daysperpp"])

  colourscheme = setColours()

  concframe = setConcFrame(net, params)

  shadeframe = setShadeFrame(net, params)

  for pp in 1:nphotoperiods

    plot1 = plot(Scale.x_continuous(minvalue = 0,
                                    maxvalue = 24*params["daysperpp"]),
                 Scale.y_continuous(minvalue = 0, maxvalue = 1),
                 Geom.subplot_grid(
                   layer(concframe, x = "time", y = "gene",
                         color = "variable", ygroup = "variable",
                         Geom.line),
                   layer(shadeframe, xmin = "starts", xmax = "ends",
                         y = "y", ygroup = "row",
                         Geom.bar(position=:dodge),
                         color = repeat(["dawns", "dusks", "days", "nights"],
                                        outer = [params["alldays"]*
                                                 params["nnodes"]])),
                   Scale.color_discrete_manual(colourscheme...)))

    draw(PDF("../runs/plot$(filename)_pp$(pp).pdf", 16inch, 6inch), plot1)
  end
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

function plotFitness(fitnesses, xmax, filename::String)
  maxfit = max(fitnesses...)

  plot1 = plot(x = 1:xmax, y = fitnesses[1:xmax], Geom.line,
               Scale.x_continuous(minvalue = 0, maxvalue = xmax),
               Scale.y_continuous(minvalue = 0, maxvalue = maxfit))
  draw(PDF("../runs/fitness$(filename).pdf", 12inch, 6inch), plot1)

end
