using Compose, Color

function testdraw()

compose(context(),
    (context(), text(0.275, 0.35, "and"),
                font("Arial"),
                fontsize(18pt),
                fill(LCHab(8, 258, 290))),
    (context(), text(0.275, 0.75, " or"),
                font("Arial"),
                fontsize(18pt),
                fill(LCHab(8, 258, 290))),
    (context(), text(0.675, 0.35, " or"),
                font("Arial"),
                fontsize(18pt),
                fill(LCHab(8, 258, 290))),
    (context(), text(0.675, 0.75, " and"),
                font("Arial"),
                fontsize(18pt),
                fill(LCHab(8, 258, 290))),
    (context(), line([(0.19, 0.28), (0.19, 0.32)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 1 to 1
    (context(), line([(0.42, 0.25), (0.42, 0.29)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 2 to 1
    (context(), line([(0.415, 0.405), (0.445, 0.375)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 3 to 1
    (context(), line([(0.31, 0.42), (0.35, 0.42)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 4 to 1
    (context(), line([(0.58, 0.31), (0.58, 0.35)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 1 to 2
    (context(), line([(0.81, 0.28), (0.81, 0.32)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 2 to 2
    (context(), line([(0.71, 0.42), (0.75, 0.42)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 3 to 2
    (context(), line([(0.595, 0.415), (0.625, 0.445)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 4 to 2
    (context(), line([(0.555, 0.625), (0.585, 0.595)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 1 to 3
    (context(), line([(0.65, 0.58), (0.69, 0.58)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 2 to 3
    (context(), line([(0.19, 0.68), (0.19, 0.72)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 3 to 3
    (context(), line([(0.58, 0.71), (0.58, 0.75)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 4 to 3
    (context(), line([(0.25, 0.58), (0.29, 0.58)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 1 to 4
    (context(), line([(0.375, 0.555), (0.405, 0.585)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 2 to 4
    (context(), line([(0.42, 0.65), (0.42, 0.69)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 3 to 4
    (context(), line([(0.81, 0.68), (0.81, 0.72)]),
                linewidth(1mm), stroke(LCHab(8, 258, 30))), # 4 to 4
    (context(), polygon([(0.42, 0.38), (0.43, 0.42), (0.46, 0.39)]),
                fill(LCHab(8, 258, 290))), # 3 to 1*
    (context(), polygon([(0.58, 0.62), (0.57, 0.58), (0.54, 0.61)]),
                fill(LCHab(8, 258, 290))), # 1 to 3*
    (context(), polygon([(0.2, 0.3), (0.16, 0.32), (0.16, 0.28)]),
                fill(LCHab(8, 258, 290))), # 1 to 1*
    (context(), polygon([(0.8, 0.3), (0.84, 0.32), (0.84, 0.28)]),
                fill(LCHab(8, 258, 290))), # 2 to 2*
    (context(), polygon([(0.41, 0.27), (0.45, 0.29), (0.45, 0.25)]),
                fill(LCHab(8, 258, 290))), # 2 to 1*
    (context(), polygon([(0.59, 0.33), (0.55, 0.35), (0.55, 0.31)]),
                fill(LCHab(8, 258, 290))), # 1 to 2*
    (context(), polygon([(0.33, 0.41), (0.31, 0.45), (0.35, 0.45)]),
                fill(LCHab(8, 258, 290))), # 4 to 1*
    (context(), polygon([(0.73, 0.41), (0.71, 0.45), (0.75, 0.45)]),
                fill(LCHab(8, 258, 290))), # 3 to 2
    (context(), polygon([(0.27, 0.59), (0.25, 0.55), (0.29, 0.55)]),
                fill(LCHab(8, 258, 290))), # 1 to 4
    (context(), polygon([(0.67, 0.59), (0.65, 0.55), (0.69, 0.55)]),
                fill(LCHab(8, 258, 290))), # 2 to 3
    (context(), polygon([(0.8, 0.7), (0.84, 0.72), (0.84, 0.68)]),
                fill(LCHab(8, 258, 290))), # 3 to 3
    (context(), polygon([(0.2, 0.7), (0.16, 0.72), (0.16, 0.68)]),
                fill(LCHab(8, 258, 290))), # 4 to 4
    (context(), polygon([(0.41, 0.67), (0.45, 0.69), (0.45, 0.65)]),
                fill(LCHab(8, 258, 290))), # 3 to 4
    (context(), polygon([(0.59, 0.73), (0.55, 0.75), (0.55, 0.71)]),
                fill(LCHab(8, 258, 290))), # 4 to 3
    (context(), polygon([(0.62, 0.42), (0.61, 0.46), (0.58, 0.43)]),
                fill(LCHab(8, 258, 290))), # 4 to 2
    (context(), polygon([(0.38, 0.58), (0.39, 0.54), (0.42, 0.57)]),
                fill(LCHab(8, 258, 290))), # 2 to 4
    (context(), curve([(0.19, 0.3), (0.15, 0.15)],
                      [(0.12, 0.3), (0.21, 0.09)],
                      [(0.09, 0.21), (0.3, 0.12)],
                      [(0.15, 0.15), (0.3, 0.19)]),
                fill(nothing), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))), # 1 to 1
    (context(), curve([(0.81, 0.3), (0.85, 0.15)],
                      [(0.88, 0.3), (0.79, 0.09)],
                      [(0.91, 0.21), (0.7, 0.12)],
                      [(0.85, 0.15), (0.7, 0.19)]),
                fill(nothing), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))), # 2 to 2
    (context(), curve([(0.19, 0.7), (0.15, 0.85)],
                      [(0.12, 0.7), (0.21, 0.91)],
                      [(0.09, 0.79), (0.3, 0.88)],
                      [(0.15, 0.85), (0.3, 0.81)]),
                fill(nothing), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))), # 3 to 3
    (context(), curve([(0.81, 0.7), (0.85, 0.85)],
                      [(0.88, 0.7), (0.79, 0.91)],
                      [(0.91, 0.79), (0.7, 0.88)],
                      [(0.85, 0.85), (0.7, 0.81)]),
                fill(nothing), linewidth(1mm),
                Compose.stroke(LCHab(8, 258, 290))), # 4 to 4
    (context(), line([(0.42, 0.27), (0.58, 0.27)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 2 to 1
    (context(), line([(0.43, 0.39), (0.61, 0.57)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 3 to 1
    (context(), line([(0.42, 0.33), (0.58, 0.33)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 1 to 2
    (context(), line([(0.39, 0.43), (0.57, 0.61)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 1 to 3
    (context(), line([(0.43, 0.61), (0.61, 0.43)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 4 to 2
    (context(), line([(0.39, 0.57), (0.57, 0.39)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 2 to 4
    (context(), line([(0.42, 0.67), (0.58, 0.67)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 3 to 4
    (context(), line([(0.42, 0.73), (0.58, 0.73)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 4 to 3
    (context(), line([(0.33, 0.42), (0.33, 0.58)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 4 to 1
    (context(), line([(0.27, 0.58), (0.27, 0.42)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 1 to 4
    (context(), line([(0.67, 0.58), (0.67, 0.42)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 2 to 3
    (context(), line([(0.73, 0.42), (0.73, 0.58)]),
                linewidth(1mm), stroke(LCHab(8, 258, 290))), # 3 to 2
    (context(), line([(0.33, 0.05), (0.33, 0.19)]),
                linewidth(1mm),
                stroke(LCHab(8, 258, 290))),
    (context(), line([(0.67, 0.05), (0.67, 0.19)]),
                linewidth(1mm),
                stroke(LCHab(8, 258, 290))),
    (context(), line([(0.33, 0.95), (0.33, 0.81)]),
                linewidth(1mm),
                stroke(LCHab(8, 258, 290))),
    (context(), line([(0.67, 0.95), (0.67, 0.81)]),
                linewidth(1mm),
                stroke(LCHab(8, 258, 290))),
    (context(), polygon([(0.33, 0.2), (0.31, 0.16), (0.35, 0.16)]),
                fill(LCHab(8, 258, 290))),
    (context(), polygon([(0.67, 0.2), (0.65, 0.16), (0.69, 0.16)]),
                fill(LCHab(8, 258, 290))),
    (context(), polygon([(0.33, 0.8), (0.31, 0.84), (0.35, 0.84)]),
                fill(LCHab(8, 258, 290))),
    (context(), polygon([(0.67, 0.8), (0.65, 0.84), (0.69, 0.84)]),
                fill(LCHab(8, 258, 290))),
    (context(), text([0.28, 0.68, 0.68, 0.28],
                     [0.32, 0.32, 0.72, 0.72],
                     ["A", "B", "C", "D"]),
                font("Arial"),
                fontsize(38pt),
                fill(LCHab(8, 258, 290))),
    (context(), circle(0.3, 0.3, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.7, 0.7, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.7, 0.3, 0.1), fill(LCHab(88, 84, 219))),
    (context(), circle(0.3, 0.7, 0.1), fill(LCHab(88, 84, 219))),
    (context(), Compose.rectangle(0, 0, 1, 1),
                fill(LCHab(68, 144, 182))))

end

img = PNG("testdraw.png", 8inch, 8inch)
draw(img, testdraw())
