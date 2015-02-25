using Compose
using Color
import BoolNetwork.Network

function draw4node(net::Network, params::Dict,
                   fitness::Float64, filename::String)
  act_index = find(x -> findfirst(x, 1) != 0, net.paths)
  rep_index = find(x -> findfirst(x, -1) != 0, net.paths)

  acts = zeros(Int64, params["nnodes"]*params["nnodes"])
  reps = zeros(Int64, params["nnodes"]*params["nnodes"])

  acts[act_index] = net.lags[act_index]
  reps[rep_index] = net.lags[rep_index]

  envs = net.envpath .* net.envlag

  draw4node(reps, acts, envs, net.gates, filename, fitness)
end

function draw4node(reps::Array{Int64}, acts::Array{Int64},
                   envs::Array{Int64}, gates::Array{Bool},
                   filename::String, fitness::Float64)

  canvas = 1        # Side length of square canvas
  c1 = 3*canvas/10  # Lower centre co-ordinate
  c2 = canvas-c1    # Upper centre co-ordinate
  rad = canvas/10   # Node radius

  paths = acts + reps

  function drawall()

    compose(context(),
           (context(), drawreps(reps, c1, c2, canvas, rad)),
           (context(), drawacts(acts, c1, c2, canvas, rad)),
           (context(), drawpaths(acts + reps, c1, c2, canvas, rad)),
           (context(), drawenvs(envs, c1, c2, canvas, rad)),
           (context(), drawgates(gates, c1, c2, canvas, rad)),
           (context(), drawgeneric(canvas, c1, c2, rad, fitness)))
  end

  img = PNG("../runs/netpic_$(filename).png", 8inch, 8inch)
  draw(img, drawall())

end

function drawreps(reps::Array{Int64}, c1, c2, canvas, rad)

drawnreps = Array(Any, 16)

repcolour = stroke(LCHab(90, 0, 297))

d1 = rad/10
d2 = d1*2
d3 = d1/2
d4 = d2*2

p1 = c1 - (rad + d1) # 0.19
p2 = c1 + (rad + d1) # 0.41
p3 = c1 + (rad + d2) # 0.42
p4 = c1 - (d1 + d2) # 0.27
p5 = c1 + (d1 + d2) # 0.33

p6 = c2 - (rad + d1) # 0.59
p7 = c2 + (rad + d1) # 0.81
p8 = c2 - (rad + d2) # 0.58
p9 = c2 - (d1 + d2) # 0.67
p10 = c2 + (d1 + d2) # 0.73

drawnreps[1] = ([(p1, c1 - d2), (p1, c1 + d2)]) # 1 to 1
drawnreps[2] = ([(p3, p4 - d2), (p3, p4 + d2)]) # 2 to 1
drawnreps[3] = ([(p2 + d3, p2 - d3), (p2 + d4 - d3, p2 - d4 + d3)]) # 3 to 1
drawnreps[4] = ([(p5 - d2, p3), (p5 + d2, p3)]) # 4 to 1
drawnreps[5] = ([(p8, p5 - d2), (p8, p5 + d2)]) # 1 to 2
drawnreps[6] = ([(p7, c1 - d2), (p7, c1 + d2)]) # 2 to 2
drawnreps[7] = ([(p10 - d2, p3), (p10 + d2, p3)]) # 3 to 2
drawnreps[8] = ([(p6 + d3, p2 + d3), (p6 + d4 - d3, p2 + d4 - d3)]) # 4 to 2
drawnreps[9] = ([(p6 - d4 + d3, p6 + d4 - d3), (p6 - d3, p6 + d3)]) # 1 to 3
drawnreps[10] = ([(p9 - d2, p8), (p9 + d2, p8)]) # 2 to 3
drawnreps[11] = ([(p7, c2 - d2), (p7, c2 + d2)]) # 3 to 3
drawnreps[12] = ([(p8, p10 - d2), (p8, p10 + d2)]) # 4 to 3
drawnreps[13] = ([(p4 - d2, p8), (p4 + d2, p8)]) # 1 to 4
drawnreps[14] = ([(p2 - d4 + d3, p6 - d4 + d3), (p2 - d3, p6 - d3)]) # 2 to 4
drawnreps[15] = ([(p3, p9 - d2), (p3, p9 + d2)]) # 3 to 4
drawnreps[16] = ([(p1, c2 - d2), (p1, c2 + d2)]) # 4 to 4

  compose(context(),
         (context(), line(drawnreps[find(x -> x > 0, reps)]),
                     linewidth(2mm), repcolour))
end

function drawacts(acts::Array{Int64}, c1, c2, canvas, rad)

  drawnacts = Array(Any, 16)
  actscolour = fill(LCHab(90, 0, 297))

  d1 = rad/10 # 0.01
  d2 = d1*2   # 0.02
  d3 = d2*2   # 0.04

  p1 = c1 + (rad + d1) # 0.41
  p2 = c1 + (rad + d2) # 0.42
  p3 = c1 - (d1 + d2) # 0.27
  p4 = c1 + (d1 + d2) # 0.33

  p5 = c2 - (rad + d1) # 0.59
  p6 = c2 - (rad + d2) # 0.58
  p7 = c2 - (d1 + d2) # 0.67
  p8 = c2 + (d1 + d2) # 0.73

  drawnacts[1] = ([(c1 - rad, c1),
                   (c1 - rad - d3, c1 + d2),
                   (c1 - rad - d3, c1 - d2)]) # From 1 to 1.
  drawnacts[2] = ([(p1, p3),
                   (p1 + d3, p3 + d2),
                   (p1 + d3, p3 - d2)]) # From 2 to 1.
  drawnacts[3] = ([(c1 + rad + d2, p2 - d3),
                   (p2 + d1, c1 + rad + d2),
                   (p2 + d3, p1 - d2)]) # From 3 to 1.
  drawnacts[4] = ([(p4, p1),
                   (p4 - d2, p1 + d3),
                   (p4 + d2, p1 + d3)]) # From 4 to 1.
  drawnacts[5] = ([(p5, p4),
                   (p5 - d3, p4 + d2),
                   (p5 - d3, p4 - d2)]) # From 1 to 2.
  drawnacts[6] = ([(c2 + rad, c1),
                   (c2 + rad + d3, c1 + d2),
                   (c2 + rad + d3, c1 - d2)]) # From 2 to 2.
  drawnacts[7] = ([(p8, p1),
                   (p8 - d2, p1 + d3),
                   (p8 + d2, p1 + d3)]) # From 3 to 2.
  drawnacts[8] = ([(p6 + d3, c1 + rad + d2),
                   (p5 + d2, p2 + d3),
                   (p6, p2 + d1)]) # From 4 to 2.
  drawnacts[9] = ([(p6, p6 + d3),
                   (p5 - d2, p6),
                   (p6 - d3, p5 + d2)]) # From 1 to 3.
  drawnacts[10] = ([(p7, p5),
                    (p7 - d2, p5 - d3),
                    (p7 + d2, p5 - d3)]) # From 2 to 3.
  drawnacts[11] = ([(c2 + rad, c2),
                    (c2 + rad + d3, c2 + d2),
                    (c2 + rad + d3, c2 - d2)]) # From 3 to 3.
  drawnacts[12] = ([(p5, p8),
                    (p5 - d3, p8 + d2),
                    (p5 - d3, p8 - d2)]) # From 4 to 3.
  drawnacts[13] = ([(p3, p5),
                    (p3 - d2, p5 - d3),
                    (p3 + d2, p5 - d3)]) # From 1 to 4.
  drawnacts[14] = ([(p2 - d3, p6),
                    (p1 - d2, p6 - d3),
                    (c1 + rad + d2, p5 - d2)]) # From 2 to 4.
  drawnacts[15] = ([(p1, p7),
                    (p1 + d3, p7 + d2),
                    (p1 + d3, p7 - d2)]) # From 3 to 4.
  drawnacts[16] = ([(c1 - rad, c2),
                  (c1 - rad - d3, c2 + d2),
                  (c1 - rad - d3, c2 - d2)]) # From 4 to 4.

  compose(context(),
         (context(), polygon(drawnacts[find(x -> x > 0, acts)]), actscolour))

end

function drawpaths(paths::Array{Int64}, c1, c2, canvas, rad)

  drawnpaths = Array(Any, 16)
  pathcolour = stroke(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  d3 = d2*2

  p1 = c1 - (rad + d1) # 0.19
  p2 = c1 + (rad + d1) # 0.41
  p3 = c1 + (rad + d2) # 0.42
  p4 = c1 - (d1 + d2) # 0.27
  p5 = c1 + (d1 + d2) # 0.33

  p6 = c2 - (rad + d1) # 0.59
  p7 = c2 + (rad + d1) # 0.81
  p8 = c2 - (rad + d2) # 0.58
  p9 = c2 - (d1 + d2) # 0.67
  p10 = c2 + (d1 + d2) # 0.73

  drawnpaths[1] = (context(),
                          curve([(p1, c1), (p1 - d3, p1 - d3)],
                                [(p1 - rad + d1 + d2, c1), (p1 + d2, p1 - rad)],
                                [(p1 - rad, p1 + d2), (c1, p1 - rad + d1 + d2)],
                                [(p1 - d3, p1 - d3), (c1, p1)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 1 to 1.

  drawnpaths[2] = (context(),
                          line([(c1 + rad + d2, p4), (p8, p4)]),
                          linewidth(1mm),
                          pathcolour) # From 2 to 1.

  drawnpaths[3] = (context(),
                          line([(p3 + d1, p2 - d2), (p6 + d2, p6 - d2)]),
                          linewidth(1mm),
                          pathcolour) # From 3 to 1.

  drawnpaths[4] = (context(),
                          line([(p5, c1 + rad + d2), (p5, p8)]),
                          linewidth(1mm),
                          pathcolour) # From 4 to 1.

  drawnpaths[5] = (context(),
                          line([(c1 + rad + d2, p5), (p8, p5)]),
                          linewidth(1mm),
                          pathcolour) # From 1 to 2.

  drawnpaths[6] = (context(),
                          curve([(p7, c1), (p7 + d3, p1 - d3)],
                                [(p7 + rad - d1 - d2, c1), (p7 - d2, p1 - rad)],
                                [(p7 + rad, p1 + d2), (c2, p1 - rad + d1 + d2)],
                                [(p7 + d3, p1 - d3), (c2, p1)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 2 to 2.

  drawnpaths[7] = (context(),
                          line([(p10, c1 + rad + d2), (p10, p8)]),
                          linewidth(1mm),
                          pathcolour) # From 3 to 2.

  drawnpaths[8] = (context(),
                          line([(p3 + d1, p6 + d2), (p6 + d2, p3 + d1)]),
                          linewidth(1mm),
                          pathcolour) # From 4 to 2.

  drawnpaths[9] = (context(),
                          line([(p2 - d2, p3 + d1), (p6 - d2, p6 + d2)]),
                          linewidth(1mm),
                          pathcolour) # From 1 to 3.

  drawnpaths[10] = (context(),
                           line([(p9, p8), (p9, c1 + rad + d2)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 3.

  drawnpaths[11] = (context(),
                           curve([(p7, c2), (p7 + d3, p7 + d3)],
                                 [(p7 + rad - d1 - d2, c2), (p7 - d2, p7 + rad)],
                                 [(p7 + rad, p7 - d2), (c2, p7 + rad - d1 - d2)],
                                 [(p7 + d3, p7 + d3), (c2, p7)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 3 to 3.

  drawnpaths[12] = (context(),
                           line([(c1 + rad + d2, p10), (p8, p10)]),
                           linewidth(1mm),
                           pathcolour) # From 4 to 3.

  drawnpaths[13] = (context(),
                           line([(p4, p8), (p4, c1 + rad + d2)]),
                           linewidth(1mm),
                           pathcolour) # From 1 to 4.

  drawnpaths[14] = (context(),
                           line([(p2 - d2, p6 - d2), (p6 - d2, p2 - d2)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 4.

  drawnpaths[15] = (context(),
                           line([(c1 + rad + d2, p9), (p8, p9)]),
                           linewidth(1mm),
                           pathcolour) # From 3 to 4.

  drawnpaths[16] = (context(),
                           curve([(p1, c2), (p1 - d3, p7 + d3)],
                                 [(p1 - rad + d1 + d2, c2), (p1 + d2, p7 + rad)],
                                 [(p1 - rad, p7 - d2), (c1, p7 + rad - d1 - d2)],
                                 [(p1 - d3, p7 + d3), (c1, p7)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 4 to 4.

  compose(context(), drawnpaths[find(x -> x > 0, paths)]...)

end

function drawenvs(envs::Array{Int64}, c1, c2, canvas, rad)

  drawnenvs = Array(Context, 4)
  arrowcol = fill(LCHab(90, 0, 297))
  pathcol = stroke(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  d3 = d1*5

  p1 = c1 - (rad + d1) # 0.19
  p2 = c1 + (rad + d1) # 0.41
  p3 = c1 + (rad + d2) # 0.42
  p4 = c1 - (d1 + d2) # 0.27
  p5 = c1 + (d1 + d2) # 0.33

  p6 = c2 - (rad + d1) # 0.59
  p7 = c2 + (rad + d1) # 0.81
  p8 = c2 - (rad + d2) # 0.58
  p9 = c2 - (d1 + d2) # 0.67
  p10 = c2 + (d1 + d2) # 0.73

  drawnenvs[1] = compose(context(),
                        (context(), # gene 1
                         line([(p5, d3), (p5, p1)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(p5, c1 - rad),
                                  (p5 - d2, p1 - d1 - d2),
                                  (p5 + d2, p1 - d1 - d2)]),
                         arrowcol))

  drawnenvs[2] = compose(context(),
                        (context(), # gene 2
                         line([(p9, d3), (p9, p1)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(p9, c1 - rad),
                                  (p9 - d2, p1 - d1 - d2),
                                  (p9 + d2, p1 - d1 - d2)]),
                         arrowcol))

  drawnenvs[3] = compose(context(),
                        (context(), # gene 4
                         line([(p9, canvas - d3), (p9, p7)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(p9, c2 + rad),
                                  (p9 - d2, p7 + d1 + d2),
                                  (p9 + d2, p7 + d1 + d2)]),
                         arrowcol))

  drawnenvs[4] = compose(context(),
                        (context(), # gene 3
                         line([(p5, canvas - d3), (p5, p7)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(p5, c2 + rad),
                                  (p5 - d2, p7 + d1 + d2),
                                  (p5 + d2, p7 + d1 + d2)]),
                         arrowcol))

  compose(drawnenvs[find(x -> x > 0, envs)]...)

end

function drawgates(gates::Array{Bool}, c1, c2, canvas, rad)

  gatehash::Dict{Bool, String} = {1 => "and", 0 => " or"}

  textcolour = fill(LCHab(90, 0, 297))

  function gatetxt(x)
    gatehash[x]
  end

  d1 = rad/10
  d2 = d1*2
  d3 = d1/2
  d4 = d1*5

  compose(context(),
         (context(),
          text([c1 - d2 - d3, c2 - d2 - d3, c2 - d2 - d3, c1 - d2 - d3],
               [c1 + d4, c1 + d4, c2 + d4, c2 + d4],
               map(gatetxt, gates)),
          font("Arial"),
          fontsize(18pt),
          textcolour))

end

function drawgeneric(canvas, c1, c2, rad, fitness)
  # This function draws the generic background that exists for all networks.
  # It includes the background colour, the four nodes (genes), and their
  # labels.
  textcolour = fill(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2

  compose(context(),
         (context(), text([c1 - d2, c2 - d2, c2 - d2, c1 - d2],
                          [c1 + d2, c1 + d2, c2 + d2, c2 + d2],
                          ["A", "B", "C", "D"]),
                     font("Arial"),
                     fontsize(38pt),
                     textcolour),
         (context(),
          circle([c1, c2, c2, c1], [c1, c1, c2, c2], [rad, rad, rad, rad]),
          fill([LCHab(60, 37, 239),
                LCHab(68, 61, 75),
                LCHab(58, 50, 151),
                LCHab(51, 72, 19)])),
         (context(),
          rectangle(0, 0, canvas, canvas), fill(LCHab(17, 14, 259))),
         (context(), text(canvas/3, rad/2, "fitness: $fitness"),
                     font("Arial"),
                     fontsize(32pt),
                     textcolour))

end
