# Pruning fittest evolved networks in order to check for superfluous
# interactions (that do not contribute to fitness).

function prune(net::Network, params::Dict)
  prunednets::Array{Network} = []
  sizehint(prunednets, length(net.paths))
  stillfits::Array{Network} = []
  for p in 1:length(net.paths)
    tempnet = copy(net)
    tempnet.paths[p] = zeros(Int64, length(params["allmins"]))
    prunednets[p] = copy(tempnet)
  end

end
