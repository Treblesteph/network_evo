

function draw4node(reps, acts, envs, gates)

  compose(context(),
          (context(), drawacts(acts)),
          (context(), drawreps(reps)),
          (context(), drawpaths(acts, reps))
          (context(), drawenvs(envs)),
          (context(), drawgates(gates)),
          (context(), drawgeneric())
          )

end

function drawacts(acts)

  drawacts[1] = compose(context(),
                        polygon([(0.2, 0.3), (0.16, 0.32), (0.16, 0.28)]),
                        fill(LCHab(8, 258, 290))) # From 1 to 1.

  drawacts[2] = compose(context(),
                        polygon([(0.4, 0.25), (0.44, 0.27), (0.44, 0.23)]),
                        fill(LCHab(8, 258, 290))) # From 2 to 1.

  drawacts[3] = compose(context(),
                        polygon([(0.41, 0.37), (0.43, 0.42), (0.46, 0.39)]),
                        fill(LCHab(8, 258, 290))) # From 3 to 1.

  drawacts[4] = compose(context(),
                        polygon([(0.35, 0.4), (0.33, 0.44), (0.37, 0.44)]),
                        fill(LCHab(8, 258, 290))) # From 4 to 1.

  drawacts[5] = compose(context(),
                        polygon([(0.6, 0.35), (0.56, 0.37), (0.56, 0.33)]),
                        fill(LCHab(8, 258, 290))) # From 1 to 2.

  drawacts[6] = compose(context(),
                        polygon([(0.8, 0.3), (0.84, 0.32), (0.84, 0.28)]),
                        fill(LCHab(8, 258, 290))) # From 2 to 2.

  drawacts[7] = compose(context(),
                        polygon([(0.75, 0.4), (0.73, 0.44), (0.77, 0.44)]),
                        fill(LCHab(8, 258, 290))) # From 3 to 2.

  drawacts[8] = compose(context(),
                        polygon([(0.63, 0.41), (0.61, 0.46), (0.58, 0.43)]),
                        fill(LCHab(8, 258, 290))) # From 4 to 2.

  drawacts[9] = compose(context(),
                        polygon([(0.59, 0.63), (0.57, 0.58), (0.54, 0.61)]),
                        fill(LCHab(8, 258, 290))) # From 1 to 3.

  drawacts[10] = compose(context(),
                         polygon([(0.65, 0.6), (0.63, 0.56), (0.67, 0.56)]),
                         fill(LCHab(8, 258, 290))) # From 2 to 3.

  drawacts[11] = compose(context(),
                         polygon([(0.8, 0.7), (0.84, 0.72), (0.84, 0.68)]),
                         fill(LCHab(8, 258, 290))) # From 3 to 3.

  drawacts[12] = compose(context(),
                         polygon([(0.6, 0.75), (0.56, 0.77), (0.56, 0.73)]),
                         fill(LCHab(8, 258, 290))) # From 4 to 3.

  drawacts[13] = compose(context(),
                         polygon([(0.25, 0.6), (0.23, 0.56), (0.27, 0.56)]),
                         fill(LCHab(8, 258, 290))) # From 1 to 4.

  drawacts[14] = compose(context(),
                         polygon([(0.37, 0.59), (0.39, 0.54), (0.42, 0.57)]),
                         fill(LCHab(8, 258, 290))) # From 2 to 4.

  drawacts[15] = compose(context(),
                         polygon([(0.4, 0.65), (0.44, 0.67), (0.44, 0.63)]),
                         fill(LCHab(8, 258, 290))) # From 3 to 4.

  drawacts[16] = compose(context(),
                         polygon([(0.2, 0.7), (0.16, 0.72), (0.16, 0.68)]),
                         fill(LCHab(8, 258, 290))) # From 4 to 4.


  for i in 1:16
    compose
  end

end

function drawreps(reps)



end

function drawpaths(paths)



end

function drawenvs(envs)



end

function drawgates(gates)



end

function drawgeneric()
  # This function draws the generic background that exists for all networks.
  # It includes the background colour, the four nodes (genes), and their
  # labels.

  compose(context(),
          (context(), polygon([])))

end
