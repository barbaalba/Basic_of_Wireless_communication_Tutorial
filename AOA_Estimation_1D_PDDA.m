clear;clc;close all;
%% Scenario
% antenna configuration
N = 32; d_H = 1/2;

SNR = 10; % received SNR in dB
L = 10; % pilot symbol length
k = 2; % maximum number of users in the system

% grid search (MUSIC)
angle_search = -pi/2:pi/360:pi/2; % angle grid
grid_response = ULA_Evaluate(N,angle_search,d_H); % grid response

%% System model
% channel parameters
ang_idx = randperm(length(angle_search));
azimuth_angles = angle_search(ang_idx(1:k));
A = ULA_Evaluate(N,azimuth_angles,d_H); % channel
s = 1/sqrt(2) * (randn(k,L) + 1i * randn(k,L)); % data
n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % noise

y = zeros(N,L);
for i = 1:L
    y(:,i) = A * s(:,i) * sqrt(db2pow(SNR))+ n(:,i); % End-End communication
end

%% PDDA 
y_ref = y(1,:); % all the phases from 1st element (Ref element)
y_rest = y(2:end,:); % the rest of the receive signal except 1st element
p = y_ref*y_rest' / (y_ref*y_ref'); %  propagator vector
corr_vect = [1,p].';

PDDA_spectrum = abs(corr_vect.'*grid_response).^2;

% Process spectrum for sharper peaks
max_val = max(PDDA_spectrum);
PDDA_spectrum = max_val - PDDA_spectrum;
PDDA_spectrum = 1./(PDDA_spectrum+eps);
[pkvalue,idx] = findpeaks(PDDA_spectrum,'SortStr','descend','NPeaks',k);

figure;
plot(angle_search,pow2db(PDDA_spectrum),'LineWidth',2);
hold on;
plot(azimuth_angles,pow2db(PDDA_spectrum(ang_idx(1:k))),'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',2);
plot(angle_search(idx),pow2db(PDDA_spectrum(idx)),'LineStyle','none','Marker','x','MarkerSize',10,'LineWidth',2);
xlabel('Angles [radian]','FontSize',20,'Interpreter','latex');
ylabel('Spectrum value','FontSize',20,'Interpreter','latex');
ax = gca;
grid on;
ax.FontSize = 20;
ax.TickLabelInterpreter = "latex";
hold on;
legend('PDDA Spectrum Value [dB]','True angle','PDDA selection','FontSize',20,'interpreter','latex');