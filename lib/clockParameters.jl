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

function add_envsignal!(params::Dict, nphotoperiod::Int64, noise::Bool)

  if noise
    dev = 2
    params["daysperpp"] = 6 * params["daysperpp"]
  else
    dev = 0
    params["daysperpp"] = params["daysperpp"]
  end

  minperiod = 6
  maxperiod = 18
  meanperiod = (minperiod + maxperiod)/2

  if nphotoperiod == 1

    photoperiods = [meanperiod]

  else

    photoperiods = zeros(Int64, nphotoperiod)
    diff = (maxperiod - minperiod)/(nphotoperiod - 1)
    shuffleindices = [5, 7, 9, 8, 6, 4, 2, 1, 3]

    if length(shuffleindices) != nphotoperiod
      error("Length of shuffled indices should equal the number of
             different photoperiods.")
    end

    for j in 1:nphotoperiod
      photoperiods[shuffleindices[j]] = round(minperiod + diff*(j - 1))
    end
  end

  alldays = Int64[params["daysperpp"] * nphotoperiod]
  params["alldays"] = alldays[1]

  days = [Int64[] for k in 1:params["alldays"]]

  for t = 1:params["alldays"]
    firstminute = 1 + 60*24*(t - 1)

    pp = ceil(t / params["daysperpp"])

    minlightperiod = photoperiods[pp] - dev
    maxlightperiod = photoperiods[pp] + dev

    if minlightperiod < maxlightperiod
      lightperiod = rand(Uniform(minlightperiod, maxlightperiod))
    else
      lightperiod = minlightperiod
    end

    daytime = round(60 * lightperiod)

    lastminute = convert(Int64, (daytime + 24*60*(t - 1)))
    days[t] = firstminute:lastminute
  end

  params["envsignal"] = days

  return params
end

function add_clock_params!(params::Dict, nphotoperiod=1, noise=false)

  params = add_envsignal!(params, nphotoperiod, noise)

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

# function harvard_forest!(params::Dict)
#
#   params["alldays"] = alldays[1]
#
#   return params
# end

end # ClockParameters module
