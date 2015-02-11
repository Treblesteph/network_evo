module TestMultichoose

using FactCheck
include("./multichoose.jl")

facts("Checking simple examples work") do
  #TODO: The matrix constructed here does not actually need to be identical
  #      to the one made in multichoose, they just need to contain the same
  #      rows (in any order). Could use something like all(in(x[i], y))
  expression1 = multichoose(Array[[0, 1], [0, 1]], 0)
  expression2 = multichoose(Array[[0, 1], [0, 1]], 1)
  assertion1 = [0 0; 1 0; 0 1; 1 1]
  @fact expression1 => expression2
  @fact expression1 => assertion1
end

end # TestMultichoose module
