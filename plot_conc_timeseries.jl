include("run_all.jl");

using Gadfly
using DataFrames
using Cairo

function plot_conc(concseries::Array{Array{Int64, 2}, 1})
  concplot = [plot(x = [1:size(concseries[n],1)], y = concseries[n][:, 1],
                   Geom.line) for n in 1:popsize]
  for n = 1:popsize
    draw(PNG("concplot$(n).png", 12inch, 3inch), concplot[n])
  end
end
