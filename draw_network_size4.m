function draw_network_size4(NETWORKS)
%DRAW_NETWORK - draws the randomly generated networks for network evo
%experiments.
%   Takes a list of 4-node networks (NETWORKS - one network per row) and draws
%   the interactions between each node.
clear
figure(1); hold on
% Define colourscheme and make globally accessible.
global navy green pink blue pale orange
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
l12 = nonself_path([centre1+(5*radius)/4, centre1+radius/3], ...
                   [centre2-(5*radius)/4, centre1+radius/3], 1, 1);

l21 = nonself_path([centre2-(5*radius)/4, centre1-radius/3], ...
                   [centre1+(5*radius)/4, centre1-radius/3], 1, 1);

l34 = nonself_path([centre1+(5*radius)/4, centre2+radius/3], ...
                   [centre2-(5*radius)/4, centre2+radius/3], 1, 1);

l43 = nonself_path([centre2-(5*radius)/4, centre2-radius/3], ...
                   [centre1+(5*radius)/4, centre2-radius/3], 1, 1);

l13 = nonself_path([centre1+radius/3, centre1+(5*radius)/4], ...
                   [centre1+radius/3, centre2-(5*radius)/4], 1, 1);

l31 = nonself_path([centre1-radius/3, centre2-(5*radius)/4], ...
                   [centre1-radius/3, centre1+(5*radius)/4], 1, 1);

l24 = nonself_path([centre2+radius/3, centre1+(5*radius)/4], ...
                   [centre2+radius/3, centre2-(5*radius)/4], 1, 1);

l42 = nonself_path([centre2-radius/3, centre2-(5*radius)/4], ...
                   [centre2-radius/3, centre1+(5*radius)/4], 1, 1);

l14 = nonself_path([centre1+(3*radius)/2, centre1+(5*radius)/6], ...
                   [centre2-(5*radius)/6, centre2-(3*radius)/2], 1, 1);

l41 = nonself_path([centre2-(3*radius)/2, centre2-(5*radius)/6], ...
                   [centre1+(5*radius)/6, centre1+(3*radius)/2], 1, 1);

l23 = nonself_path([centre2-(3*radius)/2, centre1+(5*radius)/6], ...
                   [centre1+(5*radius)/6, centre2-(3*radius)/2], 1, 1);

l32 = nonself_path([centre1+(3*radius)/2, centre2-(5*radius)/6], ...
                   [centre2-(5*radius)/6, centre1+(3*radius)/2], 1, 1);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [interaction, posMarker, negMarker] = ...
          nonself_path(start, finish, pos, neg)
    interaction = line([start(1), finish(1)], ...
                       [start(2), finish(2)], ...
                       'color', [0.43,0.73,0.59], 'linewidth', 3);
    % Determining line orientation for positive/negative markers.
    dash = ((1/8:1/4:1)'*2*pi); % Angles for negative regulation.
    if start(2) == finish(2)                        % Horizontal
        if start(1) < finish(1)                     % Right
            tri = ((1/6:1/3:1)'*2*pi)-pi/2;
            fill(finish(1)+50*(sin(tri)-1), ...
                 finish(2)+50*cos(tri), [0.43,0.73,0.59]);
            line_x = [finish(1), finish(1)];
            line_y = [finish(2)-50, finish(2)+50];
            line(line_x, line_y, 'color', [0.93,0.35,0.35]);
        elseif start(1) > finish(1)                 % Left
            tri = ((1/6:1/3:1)'*2*pi)+pi/2;
            fill(finish(1)+50*(sin(tri)+1), ...
                 finish(2)+50*cos(tri), [0.43,0.73,0.59]);
            line_x = [finish(1), finish(1)];
            line_y = [finish(2)-50, finish(2)+50];
            line(line_x, line_y, 'color', [0.93,0.35,0.35]);
        else
            error('error with line start/finish co-ordinates')
        end
    elseif start(1) == finish(1)                    % Vertical
        if start(2) < finish(2)
            tri = ((1/6:1/3:1)'*2*pi)+pi;           % Up
            fill(finish(1)+50*sin(tri), ...
                 finish(2)+50*(cos(tri)-1), [0.43,0.73,0.59]);
            line_x = [finish(1)-50, finish(1)+50];
            line_y = [finish(2), finish(2)];
            line(line_x, line_y, 'color', [0.93,0.35,0.35]);
        elseif start(2) > finish(2)
            tri = (1/3:2/3:2)'*pi;                  % Down
            fill(finish(1)+50*sin(tri), ...
                 finish(2)+50*(cos(tri)+1), [0.43,0.73,0.59]);
            line_x = [finish(1)-50, finish(1)+50];
            line_y = [finish(2), finish(2)];
            line(line_x, line_y, 'color', [0.93,0.35,0.35]);
        else error('error with line start/finish co-ordinates')
        end
    elseif (start(1) < finish(1)) && (start(2) < finish(2))
        tri = (((1/6:1/3:1)'*2*pi)-pi/12);          % Up right
        fill(finish(1)+50*(sin(tri)-sqrt(0.5)), ...
             finish(2)+50*(cos(tri)-sqrt(0.5)), [0.43,0.73,0.59]);
        line_x = [finish(1)-50*sqrt(0.5), finish(1)+50*sqrt(0.5)];
        line_y = [finish(2)+50*sqrt(0.5), finish(2)-50*sqrt(0.5)];
        line(line_x, line_y, 'color', [0.93,0.35,0.35]);
    elseif (start(1) < finish(1)) && (start(2) > finish(2))
        tri = (((1/6:1/3:1)'*2*pi)+13*pi/12);       % Down right
        fill(finish(1)+50*(sin(tri)-sqrt(0.5)), ...
             finish(2)+50*(cos(tri)+sqrt(0.5)), [0.43,0.73,0.59]);
        line_x = [finish(1)-50*sqrt(0.5), finish(1)+50*sqrt(0.5)];
        line_y = [finish(2)-50*sqrt(0.5), finish(2)+50*sqrt(0.5)];
        line(line_x, line_y, 'color', [0.93,0.35,0.35]);
    elseif (start(1) > finish(1)) && (start(2) < finish(2))
        tri = ((1/6:1/3:1)'*2*pi)+pi/12;            % Up left
        fill(finish(1)+50*(sin(tri)+sqrt(0.5)), ...
             finish(2)+50*(cos(tri)-sqrt(0.5)), [0.43,0.73,0.59]);
        line_x = [finish(1)-50*sqrt(0.5), finish(1)+50*sqrt(0.5)];
        line_y = [finish(2)-50*sqrt(0.5), finish(2)+50*sqrt(0.5)];
        line(line_x, line_y, 'color', [0.93,0.35,0.35]);
    elseif (start(1) > finish(1)) && (start(2) > finish(2))
        tri = (((1/6:1/3:1)'*2*pi)-13*pi/12);       % Down left
        fill(finish(1)+50*(sin(tri)+sqrt(0.5)), ...
             finish(2)+50*(cos(tri)+sqrt(0.5)), [0.43,0.73,0.59]);
        line_x = [finish(1)-50*sqrt(0.5), finish(1)+50*sqrt(0.5)];
        line_y = [finish(2)+50*sqrt(0.5), finish(2)-50*sqrt(0.5)];
        line(line_x, line_y, 'color', [0.93,0.35,0.35]);
    else
        error('error with line start/finish co-ordinates')
    end
end