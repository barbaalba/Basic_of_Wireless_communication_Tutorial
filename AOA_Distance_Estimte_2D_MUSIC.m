%% NOT COMPLETE - It supports only one user%%
clear; clc; close all;
% parameters
fc = 28e9; % carrier frequency in Hz
c = 3e8; % speed of light
lambda = c/fc; % wavelength propagating waves
M = 256; % number of antennas ULA
d = 1/2; % normalized inter-element spacing
D = sqrt(lambda^2/4 + (M*lambda*d)^2); % diagonal length of array aperture
d_FA = 2*D^2/lambda; % Fraunhofer distance for an array in meter
d_F = 2*(2*(lambda*d)^2)/lambda;
d_NF = d_FA/10; % the upper threshold to be in near-field region
d_bjo = 2*D; % the lower threshold to be in near-field region with constant amplitude
disp(['Lower bound distance: ', num2str(d_bjo)]);
disp(['Upperbount distance: ', num2str(d_NF)]);
SNR = db2pow(20); % SNR
L = 100; % pilot length
k = 1; % number of users

% generate a user at random location in near-field of an array
r_k = unifrnd(d_bjo,d_NF,1,k);
varphi = unifrnd(0,pi,1,k);
disp(['User is located at distance ', num2str(r_k), ' from the array']);
disp(['User is located at angular direction of ', num2str(varphi)]);
% Evaluate precise user location
x_k = r_k.*cos(varphi);
y_k = r_k.*sin(varphi);

% approximate ULA array response according to (9.44) in  Ramezani, 
% Parisa, Özlem Tuğfe Demir, and Emil Björnson. "Localization in massive 
% MIMO networks: From near-field to far-field."
ArrayResponse = @(phi,r) exp(1i*( 2*pi*d*cos(phi).*(0:M-1)' - ...
    pi*lambda*d^2/r*sin(phi).^2 .* ((0:M-1)'.^2)) ); 

A = ArrayResponse(varphi,r_k); % The channel from the user to the array
s = 1/sqrt(2) * (randn(k,L) + 1i * randn(k,L)); % data
% Evaluate the correaltion matrix from L pilot signals. We assumed pilot
% signal to be 1 for all pilot symbols
R = zeros(M,M);
for l = 1:L
    y = sqrt(SNR) * A * s(:,l) + sqrt(1/2) * (randn(M,1) + 1i*randn(M,1));
    R = R + y*y';
end
R = R/L;

[U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'
U_n = U(:,1:(M-k)); % noise sub_space

% Exhaustive search over azimuth and distance 
angle_search = 0:pi/180:pi;
distance_search = linspace(d_bjo,d_NF,1000);
MUSIC_spectrum = zeros(length(angle_search),length(distance_search));
for l = 1:length(distance_search)
    grid_response = ArrayResponse(angle_search,distance_search(l));
    MUSIC_spectrum(:,l) = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC
end
% plot the spectrum for different azimuth and distance
[X,Y] = meshgrid(distance_search,angle_search);
surfc(X,Y,MUSIC_spectrum,'EdgeColor','none');
xlabel('Distance [m]','FontSize',20,'Interpreter','latex');
ylabel('AoA [rad]','FontSize',20,'Interpreter','latex');
zlabel('$f(\mathbf{\psi})$','FontSize',20,'Interpreter','latex');

[~,idx] = max(MUSIC_spectrum,[],"all");
[row,col] = ind2sub([length(angle_search),length(distance_search)],idx);
disp(['Estimted AoA: ',num2str(angle_search(row))]);
disp(['Estimated distance: ',num2str(distance_search(col))]);

x_est = distance_search(col) .* cos(angle_search(row));
y_est = distance_search(col) .* sin(angle_search(row));

loc_error = sqrt((x_est - x_k).^2 + (y_est-y_k).^2);
disp(['Localization error: ',num2str(loc_error),' [m]']);