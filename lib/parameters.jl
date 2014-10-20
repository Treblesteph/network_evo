module Parameters

import NetworkSimulation.make_decision_mat

function set_parameters()
  alldays::Array{Int64} = [4]
  popsize::Array{Int64} = [100]
  nnodes::Array{Int64} = [4]
  maxlag::Array{Int64} = [60*24]
  #TODO: Should there also be a MINLAG? Can transcription and translation
  #      be effectively instantaneous? If not, what should the MINLAG be?
  #      Bionumbers? This would mean that the relationship between
  #      response time (MINLAG), and frequency of environmental switching
  #      can be analysed. Meaning we can ask when non-sensing systems
  #      become preferable to sensing systems.

  #--- Mutation rates
  mutatepath::Array{Float64} = [0.02]
  mutatetmat::Array{Float64} = [0.00]
  mutateenvpath::Array{Float64} = [0.04]
  mutatelag::Array{Float64} = [0.95]
  mutategate::Array{Float64} = [0.02]

  # Percent of population killed off and replaced
  # (through reproduction) each generation.
  percentkilled::Array{Float64} = [0.15]
  tmat_std::Array{Float64} = [0.00]
  lag_std::Array{Int64} = [60]
  # Percent of individuals that are required to be at
  # optimal fitness in order to stop evolution.
  stopconverged::Array{Float64} = [0.5]
  # Threshold for defining optimal fitness.
  stopthreshold::Array{Float64} = [0.00001]
  # Degree to which the worst day accounts for most of the fitness score.
  fitnessweight::Array{Number} = [10]
  # Exponential distribution scaling coefficient the determines
  # the shape of the parental selection distribution, i.e. how
  # much more likely it is that the fitter networks will be parents.
  parentselect::Array{Int64} = [2]

  allhours::Array{Int64} = [alldays * 24]
  allmins::Array{Int64} = [allhours * 60]

  decisionhash::Dict{Array{Int64}, Int64} = make_decision_mat(nnodes[1])

  parameters::Dict{String, Any} = {"alldays" => alldays[1],
                                   "popsize" => popsize[1],
                                   "nnodes" => nnodes[1],
                                   "maxlag" => maxlag[1],
                                   "mutatepath" => mutatepath[1],
                                   "mutatetmat" => mutatetmat[1],
                                   "mutateenvpath" => mutateenvpath[1],
                                   "mutatelag" => mutatelag[1],
                                   "mutategate" => mutategate[1],
                                   "percentkilled" => percentkilled[1],
                                   "tmat_std" => tmat_std[1],
                                   "lag_std" => lag_std[1],
                                   "stopconverged" => stopconverged[1],
                                   "stopthreshold" => stopthreshold[1],
                                   "fitnessweight" => fitnessweight[1],
                                   "parentselect" => parentselect[1],
                                   "allhours" => allhours[1],
                                   "allmins" => allmins[1],
                                   "decisionhash" => decisionhash}
end

end # Parameters