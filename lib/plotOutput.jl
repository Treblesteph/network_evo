using DataFrames
using Gadfly

function plotConcs(params::Dict, net, filename)

  concframe = DataFrame()
  concframe[:time] = (1:4 * 24 * 60) / 60
  concframe[:gene1] = net.concseries[:, 1]
  concframe[:gene2] = net.concseries[:, 2]
  concframe[:gene3] = net.concseries[:, 3]
  concframe[:gene4] = net.concseries[:, 4]

  g1colour = "mediumturquoise"
  g2colour = "orchid"
  g3colour = "dodgerblue"
  g4colour = "coral"
  dawncolour = "palegoldenrod"
  daycolour = "cornsilk"
  duskcolour = "lightgrey"
  nightcolour = "azure2"

  colourscheme = [g1colour, g2colour, g3colour, g4colour,
                 dawncolour, daycolour, duskcolour, nightcolour]

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
  startsreshape = reshape(startswrongorder, 4, 4)
  endsreshape = reshape(endswrongorder, 4, 4)
  startstranspose = transpose(startsreshape)
  endstranspose = transpose(endsreshape)
  starts = startstranspose[:]
  ends = endstranspose[:]

  shadeframe = DataFrame()
  shadeframe[:starts] = repeat(starts, outer = [4])
  shadeframe[:ends] = repeat(ends, outer = [4])
  shadeframe[:y] = repeat(ones(size(dawns, 1) +
                               size(dusks, 1) +
                               size(days, 1) +
                               size(days, 1)), outer = [4])
  shadeframe[:row] = repeat([1, 2, 3, 4], inner = [(convert(Int64,
                            length(shadeframe[:y]) / 4))])

  concframe = stack(concframe, 2:ncol(concframe))
  rename!(concframe, :value, :gene)
  plot1 = plot(Scale.x_continuous(minvalue = 0, maxvalue = 96),
               Scale.y_continuous(minvalue = 0, maxvalue = 1),
          layer(concframe, x = "time", y = "gene",
                color = "variable", ygroup = "variable",
                Geom.subplot_grid(Geom.line)),
          layer(shadeframe, xmin = "starts", xmax = "ends",
                y = "y", ygroup = "row",
                Geom.subplot_grid(Geom.bar(position=:dodge)),
                color = repeat(["dawns", "dusks", "days", "nights"],
                                outer = [16])),
                Scale.discrete_color_manual(colourscheme...))

  draw(PDF("../runs/plot$(filename).pdf", 12inch, 6inch), plot1)
end

function plotFitness(fitnesses, xmax, filename)
  maxfit = max(fitnesses...)

  plot1 = plot(x = 1:xmax, y = fitnesses[1:xmax], Geom.line,
               Scale.x_continuous(minvalue = 0, maxvalue = xmax),
               Scale.y_continuous(minvalue = 0, maxvalue = maxfit))
  draw(PDF("../runs/fitness$(filename).pdf", 12inch, 6inch), plot1)

end
