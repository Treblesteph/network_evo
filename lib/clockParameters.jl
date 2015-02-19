module ClockParameters

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
    dawns[t, :] = (1 + 60 * 24 * (t - 1)):(dawnwindow + 24 * 60 * (t - 1))
    dusks[t, :] = (1 + (12 * 60 - duskwindow +
    24 * 60 * (t - 1))):(60 * (12 + 24 * (t - 1)))
  end

  params["interacttypes"] = [repression, activation, noInteraction]
  params["envsignal"] = days
  params["gene1fit"] = dawns
  params["gene2fit"] = dusks
end

function single_pp!(params::Dict)

  lightperiod = 12
  alldays = Int64[4]
  daytime = lightperiod * 60

  days = zeros(Int64, alldays, daytime)

  for t = 1:alldays # Converting to array of minutes.
    days[t, :] = (1 + 60 * 24 * (t - 1)):(daytime + 24 * 60 * (t - 1))
  end

  params["alldays"] = alldays[1]

  return params
end

function multi_pp!(params::Dict)

  nphotoperiod = 9
  minlightperiod = 6
  maxlightperiod = 18

  alldays = Int64[4 * nphotoperiod]

  days = [zeros(Int64, alldays/nphotoperiod, daytime[k]) for k in 1:nphotoperiod]

  params["alldays"] = alldays[1]

  return params
end

function single_pp_noise!(params::Dict)

  params["alldays"] = alldays[1]

  return params
end

function multi_pp_noise!(params::Dict)

  params["alldays"] = alldays[1]

  return params
end

function harvard_forest!(params::Dict)

  params["alldays"] = alldays[1]

  return params
end

end # ClockParameters module
