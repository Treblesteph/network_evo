module TestMultichoose

using FactCheck
include("./multichoose.jl")

facts("Checking simple examples work") do
  expression1 = multichoose(Array[[0, 1], [0, 1]], 0)
  expression2 = multichoose(Array[[0, 1], [0, 1]], 1)
  assertion1 = [0 0; 1 0; 0 1; 1 1]
  @fact expression1 => expression2
  @fact expression1 => assertion1
end

end
