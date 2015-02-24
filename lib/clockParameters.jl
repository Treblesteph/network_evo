module ClockParameters

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
  minlightperiod = 6
  maxlightperiod = 18
  diff = (maxlightperiod - minlightperiod)/(nphotoperiod - 1)
  daytime = zeros(Int64, nphotoperiod)
  for j in 1:nphotoperiod
    daytime[j] = (minlightperiod + diff*(j - 1)) * 60
  end

  alldays = Int64[ndays * nphotoperiod]
  params["alldays"] = alldays[1]

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"]
    firstminute = 1 + 60*24*(t - 1)
    photoperiod = ceil(t / ndays)
    lastminute = daytime[photoperiod] + 24*60*(t - 1)
    days[t] = firstminute:lastminute
  end

  params["envsignal"] = days

  return params
end


function single_pp_noise!(params::Dict)

  minlightperiod = 10
  maxlightperiod = 14
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
#
# function multi_pp_noise!(params::Dict)
#
#   params["alldays"] = alldays[1]
#
#   return params
# end
#
# function harvard_forest!(params::Dict)
#
#   params["alldays"] = alldays[1]
#
#   return params
# end

end # ClockParameters module
