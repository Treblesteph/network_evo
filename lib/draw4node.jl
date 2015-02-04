

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
p1 = c1 - (d1 + d2)
p2 = c1 + (d1 + d2)

drawnreps[1] = ([(c1 - (rad + d1), c1 - d2), (c1 - (rad + d1), c1 + d2)]) # 1 to 1
drawnreps[2] = ([(c1 + rad + d2, 0.25), (c1 + rad + d2, 0.29)]) # 2 to 1
drawnreps[3] = ([(0.415, 0.405), (0.445, 0.375)]) # 3 to 1
drawnreps[4] = ([(0.31, c1 + rad + d2), (0.35, c1 + rad + d2)]) # 4 to 1
drawnreps[5] = ([(c2 - (rad + d2), 0.31), (c2 - (rad + d2), 0.35)]) # 1 to 2
drawnreps[6] = ([(c2 + rad + d1, c1 - d2), (c2 + rad + d1, c1 + d2)]) # 2 to 2
drawnreps[7] = ([(0.71, c1 + rad + d2), (0.75, c1 + rad + d2)]) # 3 to 2
drawnreps[8] = ([(0.595, 0.415), (0.625, 0.445)]) # 4 to 2
drawnreps[9] = ([(0.555, 0.625), (0.585, 0.595)]) # 1 to 3
drawnreps[10] = ([(0.65, c2 - (rad + d2)), (0.69, c2 - (rad + d2))]) # 2 to 3
drawnreps[11] = ([(c2 + rad + d1, 0.68), (c2 + rad + d1, 0.72)]) # 3 to 3
drawnreps[12] = ([(c2 - (rad + d2), 0.71), (c2 - (rad + d2), 0.75)]) # 4 to 3
drawnreps[13] = ([(0.25, c2 - (rad + d2)), (0.29, c2 - (rad + d2))]) # 1 to 4
drawnreps[14] = ([(0.375, 0.555), (0.405, 0.585)]) # 2 to 4
drawnreps[15] = ([(c1 + rad + d2, 0.65), (c1 + rad + d2, 0.69)]) # 3 to 4
drawnreps[16] = ([(c1 - (rad + d1), 0.68), (c1 - (rad + d1), 0.72)]) # 4 to 4

  compose(context(),
         (context(), line(drawnreps[find(x -> x > 0, reps)]),
                     linewidth(2mm), repcolour))
end

function drawacts(acts, c1, c2, canvas, rad)

  drawnacts = Array(Any, 16)
  actscolour = fill(LCHab(90, 0, 297))

  d1 = rad/10
  d2 = d1*2
  p1 = c1 - (d1 + d2)
  p2 = c1 + (d1 + d2)

  drawnacts[1] = ([(0.2, 0.3), (0.16, c1 + d2), (0.16, c1 - d2)]) # From 1 to 1.
  drawnacts[2] = ([(0.41, 0.27), (0.45, 0.29), (0.45, 0.25)]) # From 2 to 1.
  drawnacts[3] = ([(c1 + rad + d2, 0.38), (0.43, c1 + rad + d2), (0.46, 0.39)]) # From 3 to 1.
  drawnacts[4] = ([(0.33, 0.41), (0.31, 0.45), (0.35, 0.45)]) # From 4 to 1.
  drawnacts[5] = ([(0.59, 0.33), (0.55, 0.35), (0.55, 0.31)]) # From 1 to 2.
  drawnacts[6] = ([(0.8, 0.3), (0.84, c1 + d2), (0.84, c1 - d2)]) # From 2 to 2.
  drawnacts[7] = ([(0.73, 0.41), (0.71, 0.45), (0.75, 0.45)]) # From 3 to 2.
  drawnacts[8] = ([(0.62, c1 + rad + d2), (0.61, 0.46), (0.58, 0.43)]) # From 4 to 2.
  drawnacts[9] = ([(0.58, 0.62), (0.57, 0.58), (0.54, 0.61)]) # From 1 to 3.
  drawnacts[10] = ([(0.67, 0.59), (0.65, 0.55), (0.69, 0.55)]) # From 2 to 3.
  drawnacts[11] = ([(0.8, 0.7), (0.84, 0.72), (0.84, 0.68)]) # From 3 to 3.
  drawnacts[12] = ([(0.59, 0.73), (0.55, 0.75), (0.55, 0.71)]) # From 4 to 3.
  drawnacts[13] = ([(0.27, 0.59), (0.25, 0.55), (0.29, 0.55)]) # From 1 to 4.
  drawnacts[14] = ([(0.38, 0.58), (0.39, 0.54), (c1 + rad + d2, 0.57)]) # From 2 to 4.
  drawnacts[15] = ([(0.41, 0.67), (0.45, 0.69), (0.45, 0.65)]) # From 3 to 4.
  drawnacts[16] = ([(0.2, 0.7), (0.16, 0.72), (0.16, 0.68)]) # From 4 to 4.

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
