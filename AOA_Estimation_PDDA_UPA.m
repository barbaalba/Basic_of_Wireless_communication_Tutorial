clear; clc; close all;
%% parameters
fc = 28e9; % carrier frequency in Hz
c = 3e8; % speed of light
lambda = c/fc; % wavelength propagating waves
N_H = 8; N_V = 8; d_H = 1/2; d_V = 1/2; N = N_H*N_V;
deltaH = d_H*lambda; deltaV = d_V*lambda;

SNR = 10; % received SNR in dB
L = 10; % pilot symbol length
K = 2; % maximum number of users in the system

% grid search (PDDA)
ArrayResponse = @(phi,theta) kron(exp(-2i*pi/lambda*deltaV*sin(theta)*(0:N_V-1).'),exp(-2i*pi/lambda*deltaH*sin(phi)*cos(theta)*(0:N_H-1).')); 
angle_search = -pi/2:pi/180:pi/2; % angle grid
grid_response = zeros(N,length(angle_search),length(angle_search));
for j=1:length(angle_search) % elevation
    for k = 1:length(angle_search) % azimuth
        grid_response(:,k,j) = ArrayResponse(angle_search(k),angle_search(j));
    end
end

%% System model
% channel parameters
az_idx = 30+randperm(120);
el_idx = 30+randperm(120);
azimuth_angles = angle_search(az_idx(1:K));
elevation_angles = angle_search(el_idx(1:K));

A = zeros(N,K);
for k = 1:K
    A(:,k) = ArrayResponse(azimuth_angles(k),elevation_angles(k));
end
s = 1/sqrt(2) * (randn(K,L) + 1i * randn(K,L)); % data
n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % noise

% received signal
y = zeros(N,L);
for i = 1:L
    y(:,i) = A * s(:,i) * sqrt(db2pow(SNR))+ n(:,i); % End-End communication
end

%% PDDA 
y_ref = y(1,:); % all the phases from 1st element (Ref element)
y_rest = y(2:end,:); % the rest of the receive signal except 1st element
p = y_ref*y_rest' / (y_ref*y_ref'); %  propagator vector
corr_vect = [1,p].';

PDDA_spectrum = zeros(length(angle_search),length(angle_search));
for i = 1:length(angle_search) % elevaation
    PDDA_spectrum(:,i) = abs(corr_vect.'*grid_response(:,:,i)).^2;
end

[X,Y] = meshgrid(angle_search,angle_search);
surf(X,Y,PDDA_spectrum,'EdgeColor','none');
hold on;
for k=1:K
    plot3(Y(el_idx(k),az_idx(k)),X(el_idx(k),az_idx(k)),PDDA_spectrum(az_idx(k),el_idx(k)),'LineStyle','none','Marker','o','LineWidth',2)
end
xlabel('Elevation [rad]','FontSize',20,'Interpreter','latex');
ylabel('Azimuth [rad]','FontSize',20,'Interpreter','latex');
zlabel('PDDA Spectrum Value','FontSize',20,'Interpreter','latex');