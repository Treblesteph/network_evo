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

function runclock(photoperiods::Int64=1, noise::Bool=false,
                  out::Bool=true)

  tic()
  params = set_parameters()
  add_clock_params!(params, photoperiods, noise)
  model = runga(params, EvolveClock; init_pop_size = 50,
                stop_after = 25000, output=out)
  println()
  toc()


  if out

    now = strftime("%F_%H_%M", time())
    concs1 = model.population[1].net.concseries
    concs2 = model.population[2].net.concseries
    concs3 = model.population[3].net.concseries
    concs4 = model.population[4].net.concseries
    concs5 = model.population[5].net.concseries
    meanfitness = model.meanfitness

    save("../runs/out_$(now).jld", "concs1", concs1, "concs2", concs2,
    "concs3", concs3, "concs4", concs4, "concs5", concs5,
    "meanfitness", meanfitness)

    h1 = net2hash(model.population[1].net)

    plotConcs(model.population[1].net, params, now)

    plotFitness(model.topfitness, model.meanfitness, model.gen_num, now)

    #TODO: Can a hash be saved with HDF5? That would be very useful...
    net = prune(model.population[1].net, params)

    draw4node(net, params, model.population[1].fitness, now)
  end

  return model
end
