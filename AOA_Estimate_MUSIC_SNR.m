% This code is to demonstatrate simple scenaro where MUSIC picks peak
% values. Further readings:
% Balabadrapatruni, Sai Suhas. "Performance evaluation of direction of 
% arrival estimation using Matlab." Signal & Image Processing: An 
% International Journal 3.5 (2012): 57-72.
clear;clc; close all;

%% Scenario
% antenna configuration
N = 32; d_H = 1/2;

SNR = -30:3:21; % received SNR in dB
L = 8; % pilot symbol length
k = 1; % maximum number of users in the system

Monte = 2e4;
% grid search (MUSIC)
angle_search = -pi/2:pi/360:pi/2; % angle grid
grid_response = ULA_Evaluate(N,angle_search,d_H); % grid response

%% System model
error = zeros(Monte,length(SNR));
for snr_idx = 1:length(SNR)
    for monte_idx = 1:Monte
        % channel parameters
        ang_idx = randperm(length(angle_search));
        azimuth_angles = sort(angle_search(ang_idx(1:k)));
        A = ULA_Evaluate(N,azimuth_angles,d_H); % channel
        s = 1/sqrt(2) * (randn(k,L) + 1i * randn(k,L)); % data
        n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % noise

        R = zeros(N,N);
        for i = 1:L
            y = A * s(:,i) * sqrt(db2pow(SNR(snr_idx)))+ n(:,i); % End-End communication
            R = R + y * y'; % received signal correlation matrix
        end

        R = R/L;
        [U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'
        
        U_n = U(:,1:(N-k)); % noise sub_space
        U_s = U(:,end-k+1:end); % signal space
        
        MUSIC_spectrum = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC
        
        [pkvalue,idx] = findpeaks(MUSIC_spectrum,'SortStr','descend','NPeaks',k);
        est_angles = sort(angle_search(idx));
        error(monte_idx,snr_idx) = mean(abs(rad2deg(est_angles) - rad2deg(azimuth_angles)));
    end
end
figure;
plot(SNR,mean(error),'LineWidth',2);
xlabel('SNR [dB]','FontSize',20,'Interpreter','latex');
ylabel('Error [degree]','FontSize',20,'Interpreter','latex');
ax = gca;
grid on;
ax.FontSize = 20;