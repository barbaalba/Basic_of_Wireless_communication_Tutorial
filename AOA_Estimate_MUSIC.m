% This code is to demonstatrate simple scenaro where MUSIC picks peak
% values. Further readings:
% Balabadrapatruni, Sai Suhas. "Performance evaluation of direction of 
% arrival estimation using Matlab." Signal & Image Processing: An 
% International Journal 3.5 (2012): 57-72.
clear;clc; close all;

%% Scenario
% antenna configuration
N = 64; d_H = 1/2;

SNR = 10; % received SNR in dB
L = 10; % pilot symbol length
k = 6; % maximum number of users in the system

% grid search (MUSIC)
angle_search = -pi/2:pi/N:pi/2; % angle grid
grid_response = ULA_Evaluate(N,angle_search,d_H); % grid response

%% System model
    
% channel parameters
ang_idx = randperm(length(angle_search));
azimuth_angles = angle_search(ang_idx(1:k));
A = ULA_Evaluate(N,azimuth_angles,d_H); % channel
s = 1/sqrt(2) * (randn(k,L) + 1i * randn(k,L)); % data
n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % data

R = zeros(N,N);
for i = 1:L
    y = A * s(:,i) * sqrt(db2pow(SNR))+ n(:,i); % End-End communication
    R = R + y * y'; % received signal correlation matrix
end

R = R/L;
[U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'

U_n = U(:,1:(N-k)); % noise sub_space
U_s = U(:,end-k+1:end); % signal space

MUSIC_spectrum = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC

[pkvalue,idx] = findpeaks(MUSIC_spectrum,'SortStr','descend','NPeaks',k);

figure;
plot(angle_search,pow2db(MUSIC_spectrum),'LineWidth',2);
hold on;
plot(azimuth_angles,pow2db(MUSIC_spectrum(ang_idx(1:k))),'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',2);
plot(angle_search(idx),pow2db(MUSIC_spectrum(idx)),'LineStyle','none','Marker','x','MarkerSize',10,'LineWidth',2);
xlabel('Angles [radian]','FontSize',20,'Interpreter','latex');
ylabel('Spectrum value','FontSize',20,'Interpreter','latex');
ax = gca;
grid on;
ax.FontSize = 20;
hold on;
legend('MUSIC Spectrum','True angle','MUSIC selection','FontSize',20,'interpreter','latex');