using Compose
using Color

include("netAnalysis.jl")

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

  inputs = netAnalysis.count_light_inputs(net, params)
  cycles = netAnalysis.count_cycles(net, params)

  draw4node(reps, acts, envs, net.gates, filename, fitness, inputs, cycles)
end

function draw4node(reps::Array{Int64}, acts::Array{Int64},
                   envs::Array{Int64}, gates::Array{Bool},
                   filename::String, fitness::Float64,
                   inputs::Int64, cycles::Int64)

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
           (context(), drawgeneric(canvas, c1, c2, rad, fitness,
                                   inputs, cycles)))
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
  textfont = font("Arial")
  textsize = fontsize(12pt)
  textcolour = fill(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  d3 = d2*2
  d4 = d1*7     # x coord for diag lag 3 to 1
  d5 = d1*6     # x coord for diag lag 3 to 1
  d6 = 2*rad    # y coord for diag lag 3 to 1 and 1 to 3

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

  al1x = 5*rad/6              # autolag 1 x coord
  al1y = c1                   # autolag 1 y coord
  al2x = canvas - 6*rad/5     # autolag 2 x coord
  al2y = 41*c2/40             # autolag 2 y coord

  hx = 29*canvas/60           # horiz/vert lag x coord
  hy = rad/40                 # horiz/vert lag y shift up from line
  vertrot1 = Rotation(-1.571) # vert lag left rotation
  vertrot2 = Rotation(1.571)  # vert lag right rotation

  diagrot1 = Rotation(-0.785) # Diagonal lag left rotation
  diagrot2 = Rotation(0.785)  # Diagonal lag right rotation

  drawnpaths[1] = (context(), # From 1 to 1.
                    (context(),
                     curve([(p1, c1), (p1 - d3, p1 - d3)],
                           [(p1 - rad + d1 + d2, c1), (p1 + d2, p1 - rad)],
                           [(p1 - rad, p1 + d2), (c1, p1 - rad + d1 + d2)],
                           [(p1 - d3, p1 - d3), (c1, p1)]),
                     fill(nothing), linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(al1x, al1y, "$(round(paths[1]/60, 2))"),
                     textfont, textsize, textcolour))

  drawnpaths[2] = (context(), # From 2 to 1.
                    (context(),
                     line([(c1 + rad + d2, p4), (p8, p4)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx, p4 - hy, "$(round(paths[2]/60, 2))"),
                     textfont, textsize, textcolour))

  drawnpaths[3] = (context(), # From 3 to 1.
                    (context(),
                     line([(p3 + d1, p2 - d2), (p6 + d2, p6 - d2)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx - d4, p4 - hy + d6, "$(round(paths[3]/60, 2))",
                          hleft, vbottom, diagrot2),
                     textfont, textsize, textcolour))

  drawnpaths[4] = (context(), # From 4 to 1.
                    (context(),
                     line([(p5, c1 + rad + d2), (p5, p8)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx, p5 - hy, "$(round(paths[4]/60, 2))",
                          hleft, vbottom, vertrot1),
                     textfont, textsize, textcolour))

  drawnpaths[5] = (context(), # From 1 to 2.
                    (context(),
                     line([(c1 + rad + d2, p5), (p8, p5)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx, p5 - hy, "$(round(paths[5]/60, 2))"),
                     textfont, textsize, textcolour))

  drawnpaths[6] = (context(), # From 2 to 2.
                    (context(),
                     curve([(p7, c1), (p7 + d3, p1 - d3)],
                           [(p7 + rad - d1 - d2, c1), (p7 - d2, p1 - rad)],
                           [(p7 + rad, p1 + d2), (c2, p1 - rad + d1 + d2)],
                           [(p7 + d3, p1 - d3), (c2, p1)]),
                     fill(nothing), linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(al2x, al1y, "$(round(paths[6]/60 ,2))"),
                     textfont, textsize, textcolour))

  drawnpaths[7] = (context(), # From 3 to 2.
                    (context(),
                     line([(p10, c1 + rad + d2), (p10, p8)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx, p4 - hy, "$(round(paths[7]/60, 2))",
                          hleft, vbottom, vertrot2),
                     textfont, textsize, textcolour))

  drawnpaths[8] = (context(), # From 4 to 2.
                    (context(),
                     line([(p3 + d1, p6 + d2), (p6 + d2, p3 + d1)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx + d5, p5 - hy + d6, "$(round(paths[8]/60, 2))",
                          hleft, vbottom, diagrot1),
                     textfont, textsize, textcolour))

  drawnpaths[9] = (context(), # From 1 to 3.
                    (context(),
                     line([(p2 - d2, p3 + d1), (p6 - d2, p6 + d2)]),
                     linewidth(1mm),
                     pathcolour),
                    (context(),
                     text(hx + d5, p5 - hy + d6, "$(round(paths[9]/60, 2))",
                          hleft, vbottom, diagrot2),
                     textfont, textsize, textcolour))

  drawnpaths[10] = (context(), # From 2 to 3.
                     (context(),
                      line([(p9, p8), (p9, c1 + rad + d2)]),
                      linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(hx, p5 - hy, "$(round(paths[10]/60, 2))",
                           hleft, vbottom, vertrot2),
                      textfont, textsize, textcolour))

  drawnpaths[11] = (context(), # From 3 to 3.
                     (context(),
                      curve([(p7, c2), (p7 + d3, p7 + d3)],
                            [(p7 + rad - d1 - d2, c2), (p7 - d2, p7 + rad)],
                            [(p7 + rad, p7 - d2), (c2, p7 + rad - d1 - d2)],
                            [(p7 + d3, p7 + d3), (c2, p7)]),
                      fill(nothing), linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(al2x, al2y, "$(round(paths[11]/60, 2))"),
                      textfont, textsize, textcolour))

  drawnpaths[12] = (context(), # From 4 to 3.
                     (context(),
                      line([(c1 + rad + d2, p10), (p8, p10)]),
                      linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(hx, p10 - hy, "$(round(paths[12]/60, 2))"),
                      textfont, textsize, textcolour))

  drawnpaths[13] = (context(), # From 1 to 4.
                     (context(),
                      line([(p4, p8), (p4, c1 + rad + d2)]),
                      linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(hx, p4 - hy, "$(round(paths[13]/60, 2))",
                           hleft, vbottom, vertrot1),
                      textfont, textsize, textcolour))

  drawnpaths[14] = (context(), # From 2 to 4.
                     (context(),
                      line([(p2 - d2, p6 - d2), (p6 - d2, p2 - d2)]),
                      linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(hx - d4, p4 - hy + d6, "$(round(paths[14]/60, 2))",
                           hleft, vbottom, diagrot1),
                      textfont, textsize, textcolour))

  drawnpaths[15] = (context(), # From 3 to 4.
                     (context(),
                      line([(c1 + rad + d2, p9), (p8, p9)]),
                      linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(hx, p9 - hy, "$(round(paths[15]/60, 2))"),
                      textfont, textsize, textcolour))

  drawnpaths[16] = (context(), # From 4 to 4.
                     (context(),
                      curve([(p1, c2), (p1 - d3, p7 + d3)],
                            [(p1 - rad + d1 + d2, c2), (p1 + d2, p7 + rad)],
                            [(p1 - rad, p7 - d2), (c1, p7 + rad - d1 - d2)],
                            [(p1 - d3, p7 + d3), (c1, p7)]),
                      fill(nothing), linewidth(1mm),
                      pathcolour),
                     (context(),
                      text(al1x, al2y, "$(round(paths[16]/60, 2))"),
                      textfont, textsize, textcolour))

  compose(context(), drawnpaths[find(x -> x > 0, paths)]...)

end

function drawenvs(envs::Array{Int64}, c1, c2, canvas, rad)

  function drawsun(centre, canvas)
    println(centre)
    c = centre         # centre of sun
    rad2 = canvas/40   # radius of sun
    d = rad2/5        # dist from sun to ray
    l = rad2/2         # length of ray

    k1s = (c[1], c[2] - (rad2 + d)) # north line start coord
    k1e = (c[1], k1s[2] - l) # north line end coord
    k2s = (c[1] + (rad2 + d), c[2]) # east line start coord
    k2e = (k2s[1] + l, c[2]) # east line end coord
    k3s = (c[1], c[2] + (rad2 + d)) # south line start coord
    k3e = (c[1], k3s[2] + l) # south line end coord
    k4s = (c[1] - (rad2 + d), c[2]) # west line start coord
    k4e = (k4s[1] - l, c[2]) # west line end coord
    k5s = (k2s[1] - 2*l/3, k1s[2] + 2*l/3) # NE line start coord
    k5e = (k2e[1] - 4*l/5, k1e[2] + 4*l/5) # NE line end coord
    k6s = (k2s[1] - 2*l/3, k3s[2] - 2*l/3) # SE line start coord
    k6e = (k2e[1] - 4*l/5, k3e[2] - 4*l/5) # SE line end coord
    k7s = (k4s[1] + 2*l/3, k3s[2] - 2*l/3) # SW line start coord
    k7e = (k4e[1] + 4*l/5, k3e[2] - 4*l/5) # SW line end coord
    k8s = (k4s[1] + 2*l/3, k1s[2] + 2*l/3) # NW line start coord
    k8e = (k4e[1] + 4*l/5, k1e[2] + 4*l/5) # NW line end coord

    circcolour = fill(LCHab(90, 0, 297))
    raycolour = stroke(LCHab(90, 0, 297))

    compose(context(),
    (context(), circle(centre..., rad2), circcolour),
    (context(), line([k1s, k1e]), linewidth(1.6mm), raycolour), # N
    (context(), line([k2s, k2e]), linewidth(1.6mm), raycolour), # E
    (context(), line([k3s, k3e]), linewidth(1.6mm), raycolour), # S
    (context(), line([k4s, k4e]), linewidth(1.6mm), raycolour), # W
    (context(), line([k5s, k5e]), linewidth(1.6mm), raycolour), # NE
    (context(), line([k6s, k6e]), linewidth(1.6mm), raycolour), # SE
    (context(), line([k7s, k7e]), linewidth(1.6mm), raycolour), # SW
    (context(), line([k8s, k8e]), linewidth(1.6mm), raycolour)) # NW

  end

  drawnenvs = Array(Context, 4)
  arrowcol = fill(LCHab(90, 0, 297))
  pathcol = stroke(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  d3 = d1*5

  p1 = c1 - (rad + d1) # dist 1 from node to line: 0.19
  p2 = c2 + (rad + d1) # dist 2 from node to line: 0.81

  q1 = c1 - rad + d1 # point of arrow 1: 0.21
  q2 = q1 - d1 # arrow 1: 0.2
  q3 = q1 - 4*d1 # arrow 1: 0.17

  q4 = c2 + rad - d1 # point of arrow 2: 0.79
  q5 = q4 + d1 # arrow 2: 0.8
  q6 = q4 + 4*d1 # arrow 2: 0.83


  drawnenvs[1] = compose(context(),
                        (context(), # gene 1
                         line([(rad, rad), (p1, p1)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(q1, q1),
                                  (q2, q3),
                                  (q3, q2)]),
                         arrowcol),
                        (context(),
                         drawsun([rad/2, rad/2], canvas)))

  drawnenvs[2] = compose(context(),
                        (context(), # gene 2
                         line([(canvas - rad, rad), (p2, p1)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(q4, q1),
                                  (q5, q3),
                                  (q6, q2)]),
                         arrowcol),
                         (context(),
                         drawsun([canvas - rad/2, rad/2], canvas)))

  drawnenvs[3] = compose(context(),
                        (context(), # gene 4
                         line([(canvas - rad, canvas - rad), (p2, p2)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(q4, q4),
                                  (q5, q6),
                                  (q6, q5)]),
                         arrowcol),
                         (context(),
                         drawsun([canvas - rad/2, canvas - rad/2], canvas)))

  drawnenvs[4] = compose(context(),
                        (context(), # gene 3
                         line([(rad, canvas - rad), (p1, p2)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(q1, q4),
                                  (q2, q6),
                                  (q3, q5)]),
                         arrowcol),
                         (context(),
                         drawsun([rad/2, canvas - rad/2], canvas)))

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

function drawgeneric(canvas, c1, c2, rad, fitness::Float64,
                     inputs::Int64, cycles::Int64)
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
         (context(), text([17*canvas/40, 17*canvas/40, 17*canvas/40],
                          [2*rad/3, 3*rad/3, 4*rad/3],
                          ["fitness: $(round(fitness, 4))",
                           "light inputs: $(inputs)",
                           "feedbacks: $(cycles)"]),
                     font("Arial"),
                     fontsize(15pt),
                     textcolour),
         (context(),
          rectangle(0, 0, canvas, canvas), fill(LCHab(17, 14, 259))),)

end
