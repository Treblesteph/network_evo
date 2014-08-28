include("clock_evo_globals.jl")
using Gadfly
using DataFrames
using Cairo

# Plot gene 1 for all population in different plots.
function plot_conc(concseries::Array{Array{Int64, 2}, 1})
  concplot = [plot(x = [1:size(concseries[n],1)], y = concseries[n][:, 1],
                   Geom.line) for n in 1:POPSIZE]
  for n = 1:POPSIZE
    draw(PNG("concplot$(n).png", 12inch, 3inch), concplot[n])
  end
end

# Plot all 4 genes for one network on one plot, along with the dawn and
# dusk windows shaded.
function plot_with_dawn_dusk(concseries::Array{Int64})
  dawnshading = zeros(ALLMINS)
  dawnshading[DAWNROWS] = 1
  duskshading = zeros(ALLMINS)
  duskshading[DUSKROWS] = 1
  plot(layer(x = [1:size(concseries, 1)]/60, y = concseries[:, 1], Geom.line),
       layer(x = [1:size(concseries, 1)]/60, y = concseries[:, 2], Geom.line),
       layer(x = [1:size(concseries, 1)]/60, y = concseries[:, 3], Geom.line),
       layer(x = [1:size(concseries, 1)]/60, y = concseries[:, 4], Geom.line),
       layer(x = [1:size(concseries, 1)]/60, y = dawnshading, Geom.bar),
       layer(x = [1:size(concseries, 1)]/60, y = duskshading, Geom.bar))
end
