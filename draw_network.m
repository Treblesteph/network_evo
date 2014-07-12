function draw_network()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
clear
figure(1); hold on
% Define colourscheme
navy = [0.09,0.18,0.25];
green = [0.43,0.73,0.59];
pink = [0.93,0.35,0.35];
blue = [0.37,0.65,0.82];
pale = [0.98,0.88,0.7];
orange = [0.93,0.51,0.38];
% Set square image edge length
imageSize = 2000;
[colsInImage, rowsInImage] = meshgrid(1:imageSize, 1:imageSize);
% Define circle (gene) locations
centre1 = imageSize/4; centre2 = imageSize-centre1; radius = imageSize/10;
% Make logical matrix for circle pixels
circle1 = (rowsInImage - centre1).^2 + (colsInImage - centre1).^2 <= radius.^2;
circle2 = (rowsInImage - centre1).^2 + (colsInImage - centre2).^2 <= radius.^2;
circle3 = (rowsInImage - centre2).^2 + (colsInImage - centre1).^2 <= radius.^2;
circle4 = (rowsInImage - centre2).^2 + (colsInImage - centre2).^2 <= radius.^2;
circles = circle1 | circle2 | circle3 | circle4;
% Draw circles
image(circles)
colormap([navy;pink])
axis equal
set(gca, 'visible', 'off');
% Adding gene numbers
text(centre1-radius/3,centre1, '1', 'color', navy, 'fontsize', 40)
text(centre2-radius/3,centre1, '2', 'color', navy, 'fontsize', 40)
text(centre1-radius/3,centre2, '3', 'color', navy, 'fontsize', 40)
text(centre2-radius/3,centre2, '4', 'color', navy, 'fontsize', 40)
% Adding interactions
% Between 1 and 2
l12 = line([centre1+(5*radius)/4,centre2-(5*radius)/4], ...
     [centre1+radius/3,centre1+radius/3], 'color', green, 'linewidth', 3);
l21 = line([centre1+(5*radius)/4,centre2-(5*radius)/4], ...
     [centre1-radius/3,centre1-radius/3], 'color', green, 'linewidth', 3);
% Between 3 and 4
l34 = line([centre1+(5*radius)/4,centre2-(5*radius)/4], ...
     [centre2+radius/3,centre2+radius/3], 'color', green, 'linewidth', 3);
l43 = line([centre1+(5*radius)/4,centre2-(5*radius)/4], ...
     [centre2-radius/3,centre2-radius/3], 'color', green, 'linewidth', 3);
% Between 1 and 3
l13 = line([centre1+radius/3,centre1+radius/3], ...
     [centre1+(5*radius)/4,centre2-(5*radius)/4], 'color', green, 'linewidth', 3);
l31 = line([centre1-radius/3,centre1-radius/3], ...
     [centre1+(5*radius)/4,centre2-(5*radius)/4], 'color', green, 'linewidth', 3);
% Between 2 and 4
l24 = line([centre2+radius/3,centre2+radius/3], ...
     [centre1+(5*radius)/4,centre2-(5*radius)/4], 'color', green, 'linewidth', 3);
l42 = line([centre2-radius/3,centre2-radius/3], ...
     [centre1+(5*radius)/4,centre2-(5*radius)/4], 'color', green, 'linewidth', 3);
% Between 1 and 4
l14 = line([centre1+(3*radius)/2,centre2-(5*radius)/6], ...
     [centre1+(5*radius)/6,centre2-(3*radius)/2], 'color', green, 'linewidth', 3);
l41 = line([centre1+(5*radius)/6,centre2-(3*radius)/2], ...
     [centre1+(3*radius)/2,centre2-(5*radius)/6], 'color', green, 'linewidth', 3);
% Between 2 and 3
l23 = line([centre2-(3*radius)/2,centre1+(5*radius)/6], ...
     [centre1+(5*radius)/6,centre2-(3*radius)/2], 'color', green, 'linewidth', 3);
l32 = line([centre2-(5*radius)/6,centre1+(3*radius)/2], ...
     [centre1+(3*radius)/2,centre2-(5*radius)/6], 'color', green, 'linewidth', 3);
% Between 1 and 1
theta11 = linspace(0, -1.5*pi, 100);
x11 = radius*cos(theta11) + centre1-radius;
y11 = radius*sin(theta11) + centre1-radius;
l11 = plot(x11, y11, 'color', green, 'linewidth', 3);
% Between 2 and 2
theta11 = linspace(pi/2, -pi, 100);
x11 = radius*cos(theta11) + centre2+radius;
y11 = radius*sin(theta11) + centre1-radius;
l22 = plot(x11, y11, 'color', green, 'linewidth', 3);
% Between 3 and 3
theta11 = linspace(0, 1.5*pi, 100);
x11 = radius*cos(theta11) + centre1-radius;
y11 = radius*sin(theta11) + centre2+radius;
l33 = plot(x11, y11, 'color', green, 'linewidth', 3);
% Between 4 and 4
theta11 = linspace(pi, -pi/2, 100);
x11 = radius*cos(theta11) + centre2+radius;
y11 = radius*sin(theta11) + centre2+radius;
l44 = plot(x11, y11, 'color', green, 'linewidth', 3);

figure(2)
hold on
% Set square image edge length
imageSize = 2000;
[colsInImage, rowsInImage] = meshgrid(1:imageSize, 1:imageSize);
% Define circle (gene) locations
centre1 = imageSize/4; centre2 = imageSize-centre1; radius = imageSize/10;
% Make logical matrix for circle pixels
circle1 = (rowsInImage - centre1).^2 + (colsInImage - centre1).^2 <= radius.^2;
circle2 = (rowsInImage - centre1).^2 + (colsInImage - centre2).^2 <= radius.^2;
circle3 = (rowsInImage - centre2).^2 + (colsInImage - centre1).^2 <= radius.^2;
circle4 = (rowsInImage - centre2).^2 + (colsInImage - centre2).^2 <= radius.^2;
circles = circle1 | circle2 | circle3 | circle4;
% Draw circles
image(circles)
colormap([navy;pink])
axis equal
set(gca, 'visible', 'off');
% Adding gene numbers
text(centre1-radius/3,centre1, '1', 'color', navy, 'fontsize', 40)
text(centre2-radius/3,centre1, '2', 'color', navy, 'fontsize', 40)
text(centre1-radius/3,centre2, '3', 'color', navy, 'fontsize', 40)
text(centre2-radius/3,centre2, '4', 'color', navy, 'fontsize', 40)
% Adding interactions
plot(l11)

end

