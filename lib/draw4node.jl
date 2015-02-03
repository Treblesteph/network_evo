

function draw4node(reps, acts, envs, gates)

  paths = acts + reps

  function drawall()

    compose(context(),
           (context(), drawreps(reps)),
           (context(), drawacts(acts)),
           (context(), drawpaths(acts + reps)),
           (context(), drawenvs(envs)),
           (context(), drawgates(gates)),
           (context(), drawgeneric()))
  end

  img = PNG("../runs/netpic.png", 8inch, 8inch)
  draw(img, drawall())

end

function drawreps(reps)

drawnreps = Array(Context, 16)

repcolour = stroke(LCHab(90, 0, 297))

drawnreps[1] = compose(context(),
                       line([(0.19, 0.28), (0.19, 0.32)]),
                       linewidth(2mm),
                       repcolour) # 1 to 1

drawnreps[2] = compose(context(),
                       line([(0.42, 0.25), (0.42, 0.29)]),
                       linewidth(2mm),
                       repcolour) # 2 to 1

drawnreps[3] = compose(context(),
                       line([(0.415, 0.405), (0.445, 0.375)]),
                       linewidth(2mm),
                       repcolour) # 3 to 1

drawnreps[4] = compose(context(),
                       line([(0.31, 0.42), (0.35, 0.42)]),
                       linewidth(2mm),
                       repcolour) # 4 to 1

drawnreps[5] = compose(context(),
                       line([(0.58, 0.31), (0.58, 0.35)]),
                       linewidth(2mm),
                       repcolour) # 1 to 2

drawnreps[6] = compose(context(),
                       line([(0.81, 0.28), (0.81, 0.32)]),
                       linewidth(2mm),
                       repcolour) # 2 to 2

drawnreps[7] = compose(context(),
                       line([(0.71, 0.42), (0.75, 0.42)]),
                       linewidth(2mm),
                       repcolour) # 3 to 2

drawnreps[8] = compose(context(),
                       line([(0.595, 0.415), (0.625, 0.445)]),
                       linewidth(2mm),
                       repcolour) # 4 to 2

drawnreps[9] = compose(context(),
                       line([(0.555, 0.625), (0.585, 0.595)]),
                       linewidth(2mm),
                       repcolour) # 1 to 3

drawnreps[10] = compose(context(),
                        line([(0.65, 0.58), (0.69, 0.58)]),
                        linewidth(2mm),
                        repcolour) # 2 to 3

drawnreps[11] = compose(context(),
                        line([(0.81, 0.68), (0.81, 0.72)]),
                        linewidth(2mm),
                        repcolour) # 3 to 3

drawnreps[12] = compose(context(),
                        line([(0.58, 0.71), (0.58, 0.75)]),
                        linewidth(2mm),
                        repcolour) # 4 to 3

drawnreps[13] = compose(context(),
                        line([(0.25, 0.58), (0.29, 0.58)]),
                        linewidth(2mm),
                        repcolour) # 1 to 4

drawnreps[14] = compose(context(),
                        line([(0.375, 0.555), (0.405, 0.585)]),
                        linewidth(2mm),
                        repcolour) # 2 to 4

drawnreps[15] = compose(context(),
                        line([(0.42, 0.65), (0.42, 0.69)]),
                        linewidth(2mm),
                        repcolour) # 3 to 4

drawnreps[16] = compose(context(),
                        line([(0.19, 0.68), (0.19, 0.72)]),
                        linewidth(2mm),
                        repcolour) # 4 to 4

  compose(drawnreps[find(x -> x > 0, reps)]...)
end

function drawacts(acts)

  drawnacts = Array(Context, 16)
  actscolour = fill(LCHab(90, 0, 297))

  drawnacts[1] = compose(context(),
                         polygon([(0.2, 0.3), (0.16, 0.32), (0.16, 0.28)]),
                         actscolour) # From 1 to 1.

  drawnacts[2] = compose(context(),
                         polygon([(0.41, 0.27), (0.45, 0.29), (0.45, 0.25)]),
                         actscolour) # From 2 to 1.

  drawnacts[3] = compose(context(),
                         polygon([(0.42, 0.38), (0.43, 0.42), (0.46, 0.39)]),
                         actscolour) # From 3 to 1.

  drawnacts[4] = compose(context(),
                         polygon([(0.33, 0.41), (0.31, 0.45), (0.35, 0.45)]),
                         actscolour) # From 4 to 1.

  drawnacts[5] = compose(context(),
                         polygon([(0.59, 0.33), (0.55, 0.35), (0.55, 0.31)]),
                         actscolour) # From 1 to 2.

  drawnacts[6] = compose(context(),
                         polygon([(0.8, 0.3), (0.84, 0.32), (0.84, 0.28)]),
                         actscolour) # From 2 to 2.

  drawnacts[7] = compose(context(),
                         polygon([(0.73, 0.41), (0.71, 0.45), (0.75, 0.45)]),
                         actscolour) # From 3 to 2.

  drawnacts[8] = compose(context(),
                         polygon([(0.62, 0.42), (0.61, 0.46), (0.58, 0.43)]),
                         actscolour) # From 4 to 2.

  drawnacts[9] = compose(context(),
                         polygon([(0.58, 0.62), (0.57, 0.58), (0.54, 0.61)]),
                         actscolour) # From 1 to 3.

  drawnacts[10] = compose(context(),
                          polygon([(0.67, 0.59), (0.65, 0.55), (0.69, 0.55)]),
                          actscolour) # From 2 to 3.

  drawnacts[11] = compose(context(),
                          polygon([(0.8, 0.7), (0.84, 0.72), (0.84, 0.68)]),
                          actscolour) # From 3 to 3.

  drawnacts[12] = compose(context(),
                          polygon([(0.59, 0.73), (0.55, 0.75), (0.55, 0.71)]),
                          actscolour) # From 4 to 3.

  drawnacts[13] = compose(context(),
                          polygon([(0.27, 0.59), (0.25, 0.55), (0.29, 0.55)]),
                          actscolour) # From 1 to 4.

  drawnacts[14] = compose(context(),
                          polygon([(0.38, 0.58), (0.39, 0.54), (0.42, 0.57)]),
                          actscolour) # From 2 to 4.

  drawnacts[15] = compose(context(),
                          polygon([(0.41, 0.67), (0.45, 0.69), (0.45, 0.65)]),
                          actscolour) # From 3 to 4.

  drawnacts[16] = compose(context(),
                          polygon([(0.2, 0.7), (0.16, 0.72), (0.16, 0.68)]),
                          actscolour) # From 4 to 4.

  compose(drawnacts[find(x -> x > 0, acts)]...)

end

function drawpaths(paths)

  drawnpaths = Array(Any, 16)
  pathcolour = stroke(LCHab(90, 0, 297))

  drawnpaths[1] = (context(),
                          curve([(0.19, 0.30), (0.15, 0.15)],
                                [(0.12, 0.30), (0.21, 0.09)],
                                [(0.09, 0.21), (0.30, 0.12)],
                                [(0.15, 0.15), (0.30, 0.19)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 1 to 1.

  drawnpaths[2] = (context(),
                          line([(0.42, 0.27), (0.58, 0.27)]),
                          linewidth(1mm),
                          pathcolour) # From 2 to 1.

  drawnpaths[3] = (context(),
                          line([(0.43, 0.39), (0.61, 0.57)]),
                          linewidth(1mm),
                          pathcolour) # From 3 to 1.

  drawnpaths[4] = (context(),
                          line([(0.33, 0.42), (0.33, 0.58)]),
                          linewidth(1mm),
                          pathcolour) # From 4 to 1.

  drawnpaths[5] = (context(),
                          line([(0.42, 0.33), (0.58, 0.33)]),
                          linewidth(1mm),
                          pathcolour) # From 1 to 2.

  drawnpaths[6] = (context(),
                          curve([(0.81, 0.3), (0.85, 0.15)],
                                [(0.88, 0.3), (0.79, 0.09)],
                                [(0.91, 0.21), (0.7, 0.12)],
                                [(0.85, 0.15), (0.7, 0.19)]),
                          fill(nothing), linewidth(1mm),
                          pathcolour) # From 2 to 2.

  drawnpaths[7] = (context(),
                          line([(0.73, 0.42), (0.73, 0.58)]),
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
                           line([(0.67, 0.58), (0.67, 0.42)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 3.

  drawnpaths[11] = (context(),
                           curve([(0.19, 0.7), (0.15, 0.85)],
                                 [(0.12, 0.7), (0.21, 0.91)],
                                 [(0.09, 0.79), (0.3, 0.88)],
                                 [(0.15, 0.85), (0.3, 0.81)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 3 to 3.

  drawnpaths[12] = (context(),
                           line([(0.42, 0.73), (0.58, 0.73)]),
                           linewidth(1mm),
                           pathcolour) # From 4 to 3.

  drawnpaths[13] = (context(),
                           line([(0.27, 0.58), (0.27, 0.42)]),
                           linewidth(1mm),
                           pathcolour) # From 1 to 4.

  drawnpaths[14] = (context(),
                           line([(0.39, 0.57), (0.57, 0.39)]),
                           linewidth(1mm),
                           pathcolour) # From 2 to 4.

  drawnpaths[15] = (context(),
                           line([(0.42, 0.67), (0.58, 0.67)]),
                           linewidth(1mm),
                           pathcolour) # From 3 to 4.

  drawnpaths[16] = (context(),
                           curve([(0.81, 0.7), (0.85, 0.85)],
                                 [(0.88, 0.7), (0.79, 0.91)],
                                 [(0.91, 0.79), (0.7, 0.88)],
                                 [(0.85, 0.85), (0.7, 0.81)]),
                           fill(nothing), linewidth(1mm),
                           pathcolour) # From 4 to 4.

  compose(context(), drawnpaths[find(x -> x > 0, paths)]...)

end

function drawenvs(envs)

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

function drawgates(gates)

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

function drawgeneric()
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
          circle(0.3, 0.3, 0.1), fill(LCHab(60, 37, 239))),
         (context(),
          circle(0.7, 0.3, 0.1), fill(LCHab(68, 61, 75))),
         (context(),
          circle(0.7, 0.7, 0.1), fill(LCHab(58, 50, 151))),
         (context(),
          circle(0.3, 0.7, 0.1), fill(LCHab(51, 72, 19))),
         (context(),
          rectangle(0, 0, 1, 1), fill(LCHab(17, 14, 259))))

end
