using GeneticAlgorithms
include("plotOutput.jl")
import EvolveClock
using HDF5, JLD
import NetworkSimulation.make_decision_mat,
       Parameters.set_parameters,
       BoolNetwork.repression,
       BoolNetwork.activation,
       BoolNetwork.noInteraction,
       BoolNetwork.net2hash

function add_clock_params!(params::Dict, interactions::Array)
  interactiontypes = [repression, activation, noInteraction]
  params["interacttypes"] = interactiontypes

  dawnwindow = 3 * 60
  duskwindow = 3 * 60
  daytime = 12 * 60

  days = zeros(Int64, params["alldays"], daytime)
  dawns = zeros(Int64, params["alldays"], dawnwindow)
  dusks = zeros(Int64, params["alldays"], duskwindow)

  for t = 1:params["alldays"] # Converting to arrays of minutes.
    days[t, :] = (1 + 60 * 24 * (t - 1)):(daytime + 24 * 60 * (t - 1))
    dawns[t, :] = (1 + 60 * 24 * (t - 1)):(dawnwindow + 24 * 60 * (t - 1))
    dusks[t, :] = (1 + (12 * 60 - duskwindow +
                   24 * 60 * (t - 1))):(60 * (12 + 24 * (t - 1)))
  end

  params["envsignal"] = days
  params["gene1fit"] = dawns
  params["gene2fit"] = dusks
end

tic()
params = set_parameters()
add_clock_params!(params, [repression, activation, noInteraction])
model = runga(params, EvolveClock; init_pop_size = 100, stop_after = 10000)
println()
toc()
now = strftime("%F_%H_%M", time())
concs1 = model.population[1].net.concseries
concs2 = model.population[2].net.concseries
concs3 = model.population[3].net.concseries
concs4 = model.population[4].net.concseries
concs5 = model.population[5].net.concseries
all_fitnesses = model.all_fitnesses
save("../runs/out_$(now).jld", "concs1", concs1, "concs2", concs2,
     "concs3", concs3, "concs4", concs4, "concs5", concs5,
     "all_fitnesses", all_fitnesses)

h1 = net2hash(model.population[1].net)

clockq = EvolveClock.should_be_a_clock(params)
troein = EvolveClock.create_troein_1D(params)

plotConcs(params, model.population[1].net)
# plotConcs(params, clockq)

#TODO: Can a hash be saved with HDF5? That would be very useful...