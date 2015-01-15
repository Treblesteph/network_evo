using JLD, HDF5, DataFrames, Gadfly

DAYS = params["envsignal"]
DAWNS = params["gene1fit"]
DUSKS = params["gene2fit"]
DAYS_START = (DAWNS[:, size(DAWNS,2)] + 1) / 60
DUSKS_END = DUSKS[:, size(DUSKS,2)] / 60
DAYS_END = (DUSKS[:, 1] - 1) / 60
NIGHTS_START = DUSKS_END + 1/60
NIGHTS_END = 24 + DAYS_START - 1/60
DAWNS_START = DAWNS[:, 1] / 60
DAWNS_END = DAWNS[:, size(DAWNS,2)] / 60
DUSKS_START = DUSKS[:, 1] / 60


newdata = load("../runs/old/out_2014-11-30_16_08.jld")
Frame = DataFrame()
Frame[:time] = (1:4*24*60) / 60
Frame[:gene1] = newdata["concs1"][:, 1]
Frame[:gene2] = newdata["concs1"][:, 2]
Frame[:gene3] = newdata["concs1"][:, 3]
Frame[:gene4] = newdata["concs1"][:, 4]

colour1 = "mediumturquoise"
colour2 = "orchid"
colour3 = "dodgerblue"
colour4 = "coral"
colour5 = "palegoldenrod"
colour6 = "cornsilk"
colour7 = "lightgrey"
colour8 = "azure2"

shadingcolours = [colour1, colour2, colour3, colour4,
                  colour5, colour6, colour7, colour8]

STARTS_A = [DAWNS_START, DAYS_START, DUSKS_START, NIGHTS_START]
ENDS_A = [DAWNS_END, DAYS_END, DUSKS_END, NIGHTS_END]
STARTS_R = reshape(STARTS_A, 4, 4)
ENDS_R = reshape(ENDS_A, 4, 4)
STARTS_T = transpose(STARTS_R)
ENDS_T = transpose(ENDS_R)
STARTS = STARTS_T[:]
ENDS = ENDS_T[:]

shadeFrame = DataFrame()
shadeFrame[:starts] = repeat(STARTS, outer=[4])
shadeFrame[:ends] = repeat(ENDS, outer=[4])
shadeFrame[:y] = repeat(ones(size(DAWNS,1)+size(DUSKS,1)+size(DAYS,1)+size(DAYS,1)), outer=[4])
shadeFrame[:row] = repeat([1,2,3,4], inner=[(convert(Int64, length(shadeFrame[:y])/4))])

function plot_for(geneFrame)
    genesFrame2 = stack(geneFrame, 2:ncol(geneFrame))
    rename!(genesFrame2, :value, :gene)
    plot1 = plot(Scale.x_continuous(minvalue=0, maxvalue=96),
         Scale.y_continuous(minvalue=0, maxvalue=1),
    layer(genesFrame2, x = "time", y = "gene",
    color = "variable", ygroup = "variable",
          Geom.subplot_grid(Geom.line)),
    layer(shadeFrame, xmin = "starts", xmax = "ends",
    y = "y", ygroup = "row",
    Geom.subplot_grid(Geom.bar(position=:dodge)),
    color = repeat(["Dawns", "Dusks", "Days", "Nights"], outer=[16])),
          Scale.discrete_color_manual(shadingcolours...))


    draw(PDF("../runs/oldGad.pdf", 12inch, 6inch), plot1)
end

plot_for(Frame)
