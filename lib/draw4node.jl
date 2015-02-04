

function draw4node(reps, acts, envs, gates)

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
           (context(), drawgeneric(canvas, c1, c2, rad)))
  end

  img = PNG("../runs/netpic.png", 8inch, 8inch)
  draw(img, drawall())

end

function drawreps(reps, c1, c2, canvas, rad)

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

function drawacts(acts, c1, c2, canvas, rad)

  drawnacts = Array(Any, 16)
  actscolour = fill(LCHab(90, 0, 297))

  d1 = rad/10 # 0.01
  d2 = d1*2   # 0.02
  d3 = d2*2   # 0.04

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

  drawnacts[1] = ([(c1 - rad, c1),
                   (c1 - rad - d3, c1 + d2),
                   (c1 - rad - d3, c1 - d2)]) # From 1 to 1.
  drawnacts[2] = ([(p2, p4),
                   (p2 + d3, p4 + d2),
                   (p2 + d3, p4 - d2)]) # From 2 to 1.
  drawnacts[3] = ([(c1 + rad + d2, p3 - d3),
                   (p3 + d1, c1 + rad + d2),
                   (p3 + d3, p2 - d2)]) # From 3 to 1.
  drawnacts[4] = ([(p5, p2),
                   (p5 - d2, p2 + d3),
                   (p5 + d2, p2 + d3)]) # From 4 to 1.
  drawnacts[5] = ([(p6, p5),
                   (p6 - d3, p5 + d2),
                   (p6 - d3, p5 - d2)]) # From 1 to 2.
  drawnacts[6] = ([(c2 + rad, c1),
                   (c2 + rad + d3, c1 + d2),
                   (c2 + rad + d3, c1 - d2)]) # From 2 to 2.
  drawnacts[7] = ([(p10, p2),
                   (p10 - d2, p2 + d3),
                   (p10 + d2, p2 + d3)]) # From 3 to 2.
  drawnacts[8] = ([(p8 + d3, c1 + rad + d2),
                   (p6 + d2, p3 + d3),
                   (p8, p3 + d1)]) # From 4 to 2.
  drawnacts[9] = ([(p8, p8 + d3),
                   (p6 - d2, p8),
                   (p8 - d3, p6 + d2)]) # From 1 to 3.
  drawnacts[10] = ([(p9, p6),
                    (p9 - d2, p6 - d3),
                    (p9 + d2, p6 - d3)]) # From 2 to 3.
  drawnacts[11] = ([(c2 + rad, c2),
                    (c2 + rad + d3, c2 + d2),
                    (c2 + rad + d3, c2 - d2)]) # From 3 to 3.
  drawnacts[12] = ([(p6, p10),
                    (p6 - d3, p10 + d2),
                    (p6 - d3, p10 - d2)]) # From 4 to 3.
  drawnacts[13] = ([(p4, p6),
                    (p4 - d2, p6 - d3),
                    (p4 + d2, p6 - d3)]) # From 1 to 4.
  drawnacts[14] = ([(p3 - d3, p8),
                    (p2 - d2, p8 - d3),
                    (c1 + rad + d2, p6 - d2)]) # From 2 to 4.
  drawnacts[15] = ([(p2, p9),
                    (p2 + d3, p9 + d2),
                    (p2 + d3, p9 - d2)]) # From 3 to 4.
  drawnacts[16] = ([(c1 - rad, c2),
                  (c1 - rad - d3, c2 + d2),
                  (c1 - rad - d3, c2 - d2)]) # From 4 to 4.

  compose(context(),
         (context(), polygon(drawnacts[find(x -> x > 0, acts)]), actscolour))

end

function drawpaths(paths, c1, c2, canvas, rad)

  drawnpaths = Array(Any, 16)
  pathcolour = stroke(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  p1 = c1 - (d1 + d2)
  p2 = c1 + (d1 + d2)

  drawnpaths[1] = (context(),
                          curve([(0.19, c1), (0.15, 0.15)],
                                [(0.12, c1), (0.21, 0.09)],
                                [(0.09, 0.21), (c1, 0.12)],
                                [(0.15, 0.15), (c1, 0.19)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 1 to 1.

  drawnpaths[2] = (context(),
                          line([(c1 + rad + d2, 0.27), (0.58, 0.27)]),
                          linewidth(1mm),
                          pathcolour) # From 2 to 1.

  drawnpaths[3] = (context(),
                          line([(0.43, 0.39), (0.61, 0.57)]),
                          linewidth(1mm),
                          pathcolour) # From 3 to 1.

  drawnpaths[4] = (context(),
                          line([(0.33, c1 + rad + d2), (0.33, 0.58)]),
                          linewidth(1mm),
                          pathcolour) # From 4 to 1.

  drawnpaths[5] = (context(),
                          line([(c1 + rad + d2, 0.33), (0.58, 0.33)]),
                          linewidth(1mm),
                          pathcolour) # From 1 to 2.

  drawnpaths[6] = (context(),
                          curve([(0.81, c1), (0.85, 0.15)],
                                [(0.88, c1), (0.79, 0.09)],
                                [(0.91, 0.21), (c2, 0.12)],
                                [(0.85, 0.15), (c2, 0.19)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 2 to 2.

  drawnpaths[7] = (context(),
                          line([(0.73, c1 + rad + d2), (0.73, 0.58)]),
                          linewidth(1mm),
                          pathcolour) # From 3 to 2.

  drawnpaths[8] = (context(),
                          line([(0.43, 0.61), (0.61, 0.43)]),
                          linewidth(1mm),
                          pathcolour) # From 4 to 2.

  drawnpaths[9] = (context(),
                          line([(0.39, 0.43), (0.57, 0.61)]),
                          linewidth(1mm),
                          pathcolour) # From 1 to 3.

  drawnpaths[10] = (context(),
                           line([(0.67, 0.58), (0.67, c1 + rad + d2)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 3.

  drawnpaths[11] = (context(),
                           curve([(0.19, c2), (0.15, 0.85)],
                                 [(0.12, c2), (0.21, 0.91)],
                                 [(0.09, 0.79), (c1, 0.88)],
                                 [(0.15, 0.85), (c1, 0.81)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 3 to 3.

  drawnpaths[12] = (context(),
                           line([(c1 + rad + d2, 0.73), (0.58, 0.73)]),
                           linewidth(1mm),
                           pathcolour) # From 4 to 3.

  drawnpaths[13] = (context(),
                           line([(0.27, 0.58), (0.27, c1 + rad + d2)]),
                           linewidth(1mm),
                           pathcolour) # From 1 to 4.

  drawnpaths[14] = (context(),
                           line([(0.39, 0.57), (0.57, 0.39)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 4.

  drawnpaths[15] = (context(),
                           line([(c1 + rad + d2, 0.67), (0.58, 0.67)]),
                           linewidth(1mm),
                           pathcolour) # From 3 to 4.

  drawnpaths[16] = (context(),
                           curve([(0.81, c2), (0.85, 0.85)],
                                 [(0.88, c2), (0.79, 0.91)],
                                 [(0.91, 0.79), (c2, 0.88)],
                                 [(0.85, 0.85), (c2, 0.81)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 4 to 4.

  compose(context(), drawnpaths[find(x -> x > 0, paths)]...)

end

function drawenvs(envs, c1, c2, canvas, rad)

  drawnenvs = Array(Context, 4)
  arrowcol = fill(LCHab(90, 0, 297))
  pathcol = stroke(LCHab(90, 0, 297))

  drawnenvs[1] = compose(context(),
                        (context(), # gene 1
                         line([(0.33, 0.05), (0.33, 0.19)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(0.33, 0.2), (0.31, 0.16), (0.35, 0.16)]),
                         arrowcol))

  drawnenvs[2] = compose(context(),
                        (context(), # gene 2
                         line([(0.67, 0.05), (0.67, 0.19)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(0.67, 0.2), (0.65, 0.16), (0.69, 0.16)]),
                         arrowcol))

  drawnenvs[3] = compose(context(),
                        (context(), # gene 3
                         line([(0.33, 0.95), (0.33, 0.81)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(0.33, 0.8), (0.31, 0.84), (0.35, 0.84)]),
                         arrowcol))

  drawnenvs[4] = compose(context(),
                        (context(), # gene 4
                         line([(0.67, 0.95), (0.67, 0.81)]),
                         linewidth(1mm),
                         pathcol),
                        (context(),
                         polygon([(0.67, 0.8), (0.65, 0.84), (0.69, 0.84)]),
                         arrowcol))

  compose(drawnenvs[find(x -> x > 0, envs)]...)

end

function drawgates(gates, c1, c2, canvas, rad)

  gatehash::Dict{Bool, String} = {1 => "and", 0 => " or"}

  textcolour = fill(LCHab(90, 0, 297))

  function gatetxt(x)
    gatehash[x]
  end

  compose(context(),
         (context(),
          text([0.275, 0.675, 0.675, 0.275],
               [0.35, 0.35, 0.75, 0.75],
               map(gatetxt, gates)),
          font("Arial"),
          fontsize(18pt),
          textcolour))

end

function drawgeneric(canvas, c1, c2, rad)
  # This function draws the generic background that exists for all networks.
  # It includes the background colour, the four nodes (genes), and their
  # labels.
  textcolour = fill(LCHab(90, 0, 297))

  compose(context(),
         (context(), text([0.28, 0.68, 0.68, 0.28],
                          [0.32, 0.32, 0.72, 0.72],
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
          rectangle(0, 0, canvas, canvas), fill(LCHab(17, 14, 259))))

end
