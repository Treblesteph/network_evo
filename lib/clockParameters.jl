

function add_clock_params!(params::Dict, envconditions::Function)
  dawnwindow = 3 * 60
  duskwindow = 3 * 60

  params = envconditions(params)

  params["interacttypes"] = [repression, activation, noInteraction]
  params["envsignal"] = days
  params["gene1fit"] = dawns
  params["gene2fit"] = dusks
end

function single_pp(params::Dict)

  lightperiod = 12
  alldays = Int64[4]
  daytime = lightperiod * 60

  days = zeros(Int64, alldays, daytime)

  for t = 1:alldays # Converting to array of minutes.
    days[t, :] = (1 + 60 * 24 * (t - 1)):(daytime + 24 * 60 * (t - 1))
  end

  params["alldays"] = alldays[1]
  params["allhours"] = alldays[1] * 24
  params["allmins"] = alldays[1] * 24 * 60
  return params
end

function multi_pp(params::Dict)

  nphotoperiod = 9
  minlightperiod = 6
  maxlightperiod = 18

  alldays = Int64[4 * nphotoperiod]

  days = [zeros(Int64, alldays/nphotoperiod, daytime[k]) for k in 1:nphotoperiod]

  params["alldays"] = alldays[1]
  params["allhours"] = alldays[1] * 24
  params["allmins"] = alldays[1] * 24 * 60
  return params
end

function single_pp_noise(params::Dict)

  params["alldays"] = alldays[1]
  params["allhours"] = alldays[1] * 24
  params["allmins"] = alldays[1] * 24 * 60
  return params
end

function multi_pp_noise(params::Dict)

  params["alldays"] = alldays[1]
  params["allhours"] = alldays[1] * 24
  params["allmins"] = alldays[1] * 24 * 60
  return params
end

function harvard_forest(params::Dict)

  params["alldays"] = alldays[1]
  params["allhours"] = alldays[1] * 24
  params["allmins"] = alldays[1] * 24 * 60
  return params
end
