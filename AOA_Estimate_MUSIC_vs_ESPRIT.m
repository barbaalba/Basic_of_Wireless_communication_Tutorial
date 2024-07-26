%% This code is written to analyze the performance of MUSIC and ESPRIT 
% algorithm in resolving angular location of the users
% For further reading on the algorithm one can refer to the book chapter:
% Ramezani, Parisa, Özlem Tuğfe Demir, and Emil Björnson. "Localization 
% in Massive MIMO Networks: From Near-Field to Far-Field." arXiv preprint 
% arXiv:2402.07644 (2024).
clear; clc; close all;
%% Scenario
% antenna configuration
N = 128; d_H = 1/2;

SNR_db = 10; % SNR in dB
SNR = db2pow(SNR_db);
L = 10; % pilot symbol length
k = 10; % maximum number of users in the system

pltconf = false; % to plot 

% grid search (MUSIC)
angle_search = -pi/3:2*pi/(3*N):pi/3; % angle grid
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
    y = A * s(:,i) * sqrt(SNR) + n(:,i); % End-End communication
    R = R + y * y'/SNR; % received signal correlation matrix
end 
        
R = R/L;
[U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'

U_n = U(:,1:(N-k)); % noise sub_space
U_s = U(:,end-k+1:end); % signal space

%% MUSIC
MUSIC_spectrum = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC
[pkvalue,idx] = findpeaks(MUSIC_spectrum,'SortStr','descend','NPeaks',k);

figure;
plot(angle_search,pow2db(MUSIC_spectrum),'LineWidth',2);
hold on;
plot(azimuth_angles,pow2db(MUSIC_spectrum(ang_idx(1:k))),'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',2);
plot(angle_search(idx),pow2db(MUSIC_spectrum(idx)),'LineStyle','none','Marker','x','MarkerSize',10,'Color','k','LineWidth',2);
xlabel('Angles [radian]','FontSize',20,'Interpreter','latex');
ylabel('Spectrum value [dB]','FontSize',20,'Interpreter','latex');
ax = gca;
grid on;
ax.FontSize = 20;
ax.TickLabelInterpreter = 'latex';
legend('MUSIC Spectrum','True value','Estimated value','FontSize',20,'interpreter','latex');

%% ESPRIT
% divide signal space in two sub arrays
U_s1 = U_s(1:end-1,:);
U_s2 = U_s(2:end,:); 
        
Phi = (U_s1'*U_s1)\U_s1' * U_s2;

miu = angle(eig(Phi));
        
angle_estimate_ESPRIT = asin(-miu / (2*pi*d_H)).';
      
figure;
plot(1:k,sort(azimuth_angles),'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',2);
hold on; 
plot(1:k,sort(angle_estimate_ESPRIT),'LineStyle','none','Marker','*','MarkerSize',10,'LineWidth',2);
xlabel('Angle index','FontSize',20,'Interpreter','latex');
ylabel('Angle value [radian]','FontSize',20,'Interpreter','latex');
ax = gca;
ax.FontSize = 20;
ax.TickLabelInterpreter = 'latex';
legend('True value','Estimated value','FontSize',20,'interpreter','latex');
grid on;