clear; clc; close all;
N = 16; % number of antennas
d_H = 1/2; % Normalized inter-element spacing

grid_angles = -pi/2:pi/180:pi/2;
grid_responses = exp(1i * 2 * pi * d_H * (0:N-1)' * sin(grid_angles));

AoA = -pi/4;
response_vector = exp(1i * 2 * pi * d_H * (0:N-1)' * sin(AoA));

gain = abs(1/sqrt(N) * grid_responses' * response_vector).^2;

polarplot(grid_angles+pi/2,pow2db(gain));
thetalim([0, 180]);
rlim([-3,pow2db(N)+1]);
ax = gca;
ax.ThetaTick = [0, 30, 60, 90, 120, 150, 180];
ax.TickLabelInterpreter = "latex";
ax.ThetaTickLabel = {'$-\frac{\pi}{2}$','$-\frac{\pi}{3}$','$-\frac{\pi}{6}$','$0$','$\frac{\pi}{6}$','$\frac{\pi}{3}$','$\frac{\pi}{2}$'};
ax.FontSize = 20;