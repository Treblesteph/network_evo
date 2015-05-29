using GeneticAlgorithms
include("plotOutput.jl")
include("draw4node.jl")
include("prune.jl")
import EvolveClock
using HDF5, JLD
import BoolNetwork.make_decision_mat,
       Parameters.set_parameters,
       BoolNetwork.repression,
       BoolNetwork.activation,
       BoolNetwork.noInteraction,
       BoolNetwork.net2hash,
       ClockParameters.add_clock_params!

function profileclock(photoperiods::Int64=1, noise::Bool=false,
                      out::Bool=true)

  tic()
  params = set_parameters()
  add_clock_params!(params, photoperiods, noise)
  model = runga(params, EvolveClock; init_pop_size = 60,
                stop_after = 1, output=false)
  @profile runga(params, EvolveClock; init_pop_size = 60,
                 stop_after = 1, output=false)

  Profile.print()

  return model
end
