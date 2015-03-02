module ClockParameters

using Distributions

import BoolNetwork.repression,
       BoolNetwork.activation,
       BoolNetwork.noInteraction

export add_clock_params!,
       single_pp!,
       multi_pp!,
       single_pp_noise!,
       multi_pp_noise!,
       harvard_forest


function add_clock_params!(params::Dict, envconditions::Function)

  params = envconditions(params)

  params["allhours"] = params["alldays"] * 24
  params["allmins"] = params["allhours"] * 60

  dawnwindow = 3 * 60
  duskwindow = 3 * 60
  dawns = zeros(Int64, params["alldays"], dawnwindow)
  dusks = zeros(Int64, params["alldays"], duskwindow)

  for t = 1:params["alldays"] # Converting to arrays of minutes.
    dawnstart = params["envsignal"][t][1]
    dawnend = dawnstart + dawnwindow - 1
    duskend = params["envsignal"][t][end]
    duskstart = duskend - duskwindow + 1
    dawns[t, :] = dawnstart:dawnend
    dusks[t, :] = duskstart:duskend
  end

  params["interacttypes"] = [repression, activation, noInteraction]

  params["gene1fit"] = dawns
  params["gene2fit"] = dusks
end

function single_pp!(params::Dict)

  lightperiod = 12
  alldays = Int64[4]
  params["alldays"] = alldays[1]
  daytime = lightperiod * 60

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"] # Converting to array of minutes.
    firstminute = 1 + 60*24*(t - 1)
    lastminute = (daytime + 24*60*(t - 1))
    days[t] = firstminute:lastminute
  end

  params["envsignal"] = days

  return params
end

function multi_pp!(params::Dict)

  ndays = 4
  nphotoperiod = 9
  minperiod = 6
  maxperiod = 18
  diff = (maxperiod - minperiod)/(nphotoperiod - 1)
  photoperiods = zeros(Int64, nphotoperiod)
  shuffleindices = [5, 7, 9, 8, 6, 4, 2, 1, 3]

  if length(shuffleindices) != nphotoperiod
    error("Length of shuffled indices should equal the number of
           different photoperiods.")
  end

  for j in 1:nphotoperiod
    photoperiods[shuffleindices[j]] = (minperiod + diff*(j - 1)) * 60
  end

  alldays = Int64[ndays * nphotoperiod]
  params["alldays"] = alldays[1]

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"]
    firstminute = 1 + 60*24*(t - 1)
    pp = ceil(t / ndays)
    lastminute = photoperiods[pp] + 24*60*(t - 1)
    days[t] = firstminute:lastminute
  end

  params["envsignal"] = days

  return params
end


function single_pp_noise!(params::Dict)

  meanlightperiod = 12
  noise = 2

  minlightperiod = meanlightperiod - noise
  maxlightperiod = meanlightperiod + noise
  alldays = Int64[24]
  params["alldays"] = alldays[1]

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"]
    lightperiod = rand(Uniform(minlightperiod, maxlightperiod))
    daytime = round(60 * lightperiod)
    firstminute = 1 + 60*24*(t - 1)
    lastminute = (daytime + 24*60*(t - 1))
    days[t] = firstminute:lastminute
  end

  params["envsignal"] = days

  return params
end

function multi_pp_noise!(params::Dict)

  noise = 2

  ndays = 24
  nphotoperiod = 9
  minperiod = 6
  maxperiod = 18
  diff = (maxperiod - minperiod)/(nphotoperiod - 1)
  photoperiods = zeros(Int64, nphotoperiod)
  shuffleindices = [5, 7, 9, 8, 6, 4, 2, 1, 3]

  if length(shuffleindices) != nphotoperiod
    error("Length of shuffled indices should equal the number of
           different photoperiods.")
  end

  for j in 1:nphotoperiod
    photoperiods[shuffledindices[j]] = (minperiod + diff*(j - 1)) * 60
  end

  alldays = Int64[ndays * nphotoperiod]
  params["alldays"] = alldays[1]

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"]
    pp = ceil(t / ndays)
    minlightperiod = photoperiods[pp] - noise
    maxlightperiod = photoperiods[pp] + noise

    lightperiod = rand(Uniform(minlightperiod, maxlightperiod))
    daytime = round(60 * lightperiod)

    firstminute = 1 + 60*24*(t - 1)
    lastminute = (daytime + 24*60*(t - 1))

    days[t] = firstminute:lastminute    
  end


  return params
end

# function harvard_forest!(params::Dict)
#
#   params["alldays"] = alldays[1]
#
#   return params
# end

end # ClockParameters module
