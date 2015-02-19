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

function runclock()

  tic()
  params = set_parameters()
  add_clock_params!(params, ClockParameters.single_pp!)
  model = runga(params, EvolveClock; init_pop_size = 50, stop_after = 25)
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

  # clockq = EvolveClock.should_be_a_clock(params)
  # troein = EvolveClock.create_troein_1D(params)

  plotConcs(model.population[1].net, params, now)
  # plotConcs(clockq, params, now)

  #plotFitness(model.meantop10, model.gen_num, now)

  #TODO: Can a hash be saved with HDF5? That would be very useful...
  net = prune(model.population[1].net, params)

  draw4node(net, params, now)
end
