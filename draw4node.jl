
type Point
  xcoord::Number
  ycoord::Number
end

type Node
  midpoint::Point
  radius::Number
end

type Arrow
  kind::Int64
  midpoint::Point
  direction::Number
end

type Path
  start::Point
  stop::Point
  marker::Arrow
end

function draw_nodes(NNODES)
# Draws NNODES nodes with their centres on the vortices of a
# regular NNODES-gon.
end


function draw_
