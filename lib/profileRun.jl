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
model = runga(params, EvolveClock; init_pop_size = 6, stop_after = 1)
@profile runga(params, EvolveClock; init_pop_size = 60, stop_after = 1)

Profile.print()
