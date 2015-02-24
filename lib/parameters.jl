module Parameters

import BoolNetwork.make_decision_mat

export set_parameters

function set_parameters()
  popsize = Int64[50]
  nnodes = Int64[4]
  maxlag = Int64[60*14]
  minlag = Int64[5]

  #--- Mutation rates
  mutatepath = Float64[0.08]
  mutatetmat = Float64[0.00]
  mutateenvpath = Float64[0.04]
  mutatelag = Float64[0.2]
  mutateenvlag = Float64[0.2]
  mutategate = Float64[0.04]

  tmat_std = Float64[0.00]
  lag_std = Int64[100]
  envlag_std = Int64[100]

  # Generation threshold, under which all gene-gene paths are fixed on.
  pathson = Int64[250]

  # Percent of population killed off and replaced
  # (through reproduction) each generation.
  percentkilled = Float64[0.1]

  # Genetic algorithm stopping conditions:

  # Percent of individuals that are required to be at
  # optimal fitness in order to stop evolution.
  stopconverged = Float64[0.1]
  # Threshold for defining optimal fitness.
  stopthreshold = Float64[1e-4]
  # Terminate after stopruns if no improvement in fitness for stopconsec
  # consecutive generations.
  stopruns = Int64[7000]
  stopconsec = Int64[1000]

  # Degree to which the worst day accounts for most of the fitness score.
  fitnessweight = Number[10]

  # Weight of the cost of paths (to make simplest possible networks evolve).
  pathcostweight = Int64[500]

  # Exponential distribution scaling coefficient the determines
  # the shape of the parental selection distribution, i.e. how
  # much more likely it is that the fitter networks will be parents.
  parentselect = Int64[2]

  # Default value of genes when there is no net input to them.
  defaulton = Bool[0]



  decisionhash::Dict{Array{Int64}, Bool} = make_decision_mat(nnodes[1], defaulton[1])

  parameters::Dict{String, Any} = {"popsize" => popsize[1],
                                   "nnodes" => nnodes[1],
                                   "maxlag" => maxlag[1],
                                   "minlag" => minlag[1],
                                   "mutatepath" => mutatepath[1],
                                   "mutatetmat" => mutatetmat[1],
                                   "mutateenvpath" => mutateenvpath[1],
                                   "mutatelag" => mutatelag[1],
                                   "mutateenvlag" => mutateenvlag[1],
                                   "mutategate" => mutategate[1],
                                   "pathson" => pathson[1],
                                   "percentkilled" => percentkilled[1],
                                   "tmat_std" => tmat_std[1],
                                   "lag_std" => lag_std[1],
                                   "envlag_std" => envlag_std[1],
                                   "stopconverged" => stopconverged[1],
                                   "stopthreshold" => stopthreshold[1],
                                   "stopruns" => stopruns[1],
                                   "stopconsec" => stopconsec[1],
                                   "fitnessweight" => fitnessweight[1],
                                   "pathcostweight" => pathcostweight[1],
                                   "parentselect" => parentselect[1],
                                   "defaulton" => defaulton[1],
                                   "decisionhash" => decisionhash}
end

end # Parameters
