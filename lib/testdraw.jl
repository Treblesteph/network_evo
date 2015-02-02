using Compose, Color

function testdraw()

compose(context(),
    (context(), polygon([(0.41, 0.37), (0.43, 0.42), (0.46, 0.39)]),
                fill(LCHab(8, 258, 290))), # 3 to 1*
    (context(), polygon([(0.59, 0.63), (0.57, 0.58), (0.54, 0.61)]),
                fill(LCHab(8, 258, 290))), # 1 to 3*
    (context(), polygon([(0.2, 0.3), (0.16, 0.32), (0.16, 0.28)]),
                fill(LCHab(8, 258, 290))), # 1 to 1*
    (context(), polygon([(0.8, 0.3), (0.84, 0.32), (0.84, 0.28)]),
                fill(LCHab(8, 258, 290))), # 2 to 2*
    (context(), polygon([(0.4, 0.25), (0.44, 0.27), (0.44, 0.23)]),
                fill(LCHab(8, 258, 290))), # 2 to 1*
    (context(), polygon([(0.6, 0.35), (0.56, 0.37), (0.56, 0.33)]),
                fill(LCHab(8, 258, 290))), # 1 to 2*
    (context(), polygon([(0.35, 0.4), (0.33, 0.44), (0.37, 0.44)]),
                fill(LCHab(8, 258, 290))), # 4 to 1*
    (context(), polygon([(0.75, 0.4), (0.73, 0.44), (0.77, 0.44)]),
                fill(LCHab(8, 258, 290))), # 3 to 2
    (context(), polygon([(0.25, 0.6), (0.23, 0.56), (0.27, 0.56)]),
                fill(LCHab(8, 258, 290))), # 1 to 4
    (context(), polygon([(0.65, 0.6), (0.63, 0.56), (0.67, 0.56)]),
                fill(LCHab(8, 258, 290))), # 2 to 3
    (context(), polygon([(0.8, 0.7), (0.84, 0.72), (0.84, 0.68)]),
                fill(LCHab(8, 258, 290))), # 3 to 3
    (context(), polygon([(0.2, 0.7), (0.16, 0.72), (0.16, 0.68)]),
                fill(LCHab(8, 258, 290))), # 4 to 4
    (context(), polygon([(0.4, 0.65), (0.44, 0.67), (0.44, 0.63)]),
                fill(LCHab(8, 258, 290))), # 3 to 4
    (context(), polygon([(0.6, 0.75), (0.56, 0.77), (0.56, 0.73)]),
                fill(LCHab(8, 258, 290))), # 4 to 3
    (context(), polygon([(0.63, 0.41), (0.61, 0.46), (0.58, 0.43)]),
                fill(LCHab(8, 258, 290))), # 4 to 2
    (context(), polygon([(0.37, 0.59), (0.39, 0.54), (0.42, 0.57)]),
                fill(LCHab(8, 258, 290))), # 2 to 4
    (context(), curve([(0.19, 0.3), (0.15, 0.15)],
                [(0.12, 0.3), (0.21, 0.09)],
                [(0.09, 0.21), (0.3, 0.12)],
                [(0.15, 0.15), (0.3, 0.19)]),
                fill(nothing), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))),
    (context(), circle(0.3, 0.3, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.7, 0.7, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.7, 0.3, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.3, 0.7, 0.1), fill(LCHab(88, 84, 219))),
    (context(), line([(0.4, 0.4), (0.6, 0.6)]), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))),
    (context(), Compose.rectangle(0, 0, 1, 1),
                fill(LCHab(68, 144, 182))))

end

img = PNG("testdraw.png", 8inch, 8inch)
draw(img, testdraw())
