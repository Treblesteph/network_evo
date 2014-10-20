
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
  centrepoints = set_centres(NNODES)
  compose(context(),
          context(), polygon)
end


function set_centres(NNODES::Int64, sidelength::Number)
  centres = [Point(0, 0), for n in 1:NNODES]
  centres[2][1] = sidelength
end
