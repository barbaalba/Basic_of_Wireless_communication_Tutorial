clear;clc; close all;

%% Scenario
% antenna configuration
N = 32; d_H = 1/4;

SNR = 0:5:30; % received SNR in dB
L = 8; % pilot symbol length
k = 1; % maximum number of users in the system
Monte = 10000;
% grid search (MUSIC)
angle_search = -pi/2:pi/180:pi/2; % angle grid
grid_response = ULA_Evaluate(N,angle_search,d_H); % grid response

%% Simulation
error = zeros(length(SNR),Monte);
for snr_idx = 1:length(SNR)
    for sim_idx = 1:Monte   
        % channel parameters
        ang_idx = randperm(length(angle_search));
        azimuth_angles = sort(angle_search(ang_idx(1:k)));
        A = ULA_Evaluate(N,azimuth_angles,d_H); % channel
        % Mutual coupling matrix
        mutual_coupling_power = 0:N-1;
        coupling_coefficient = 2; % change value here to obtain different coupling [2 ... 10]
        c = coupling_coefficient.^(-mutual_coupling_power); 
        for i = 2:length(c)
            c(i) = sqrt(c(i)/2) * (randn + 1i*randn); 
        end
        C = zeros(N,N);
        for i = 1:N
            for j = i:N
                    C(i, j) = c(j - i + 1);
                    C(j, i) = C(i, j); % Enforce strict symmetry
            end
        end
        s = 1/sqrt(2) * (randn(k,L) + 1i * randn(k,L)); % data
        n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % noise
        
        R = zeros(N,N);
        for i = 1:L
            y = C * A * s(:,i) * sqrt(db2pow(SNR(snr_idx)))+ n(:,i); % End-End communication
            R = R + y * y'; % received signal correlation matrix
        end
        
        R = R/L;
        [U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'
        
        U_n = U(:,1:(N-k)); % noise sub_space
        U_s = U(:,end-k+1:end); % signal space 
        
        % Estimate angle
        MUSIC_spectrum = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC
        
        [pkvalue,idx] = findpeaks(MUSIC_spectrum,'SortStr','descend','NPeaks',k);
        
        ang_est = sort(angle_search(idx));
        error(snr_idx,sim_idx) = mean(abs(ang_est - azimuth_angles));
    end
 end

plot(SNR,rad2deg(mean(error,2)),'linewidth',2);
xlabel('SNR','Interpreter','latex','FontSize',20);
ylabel('Error [degree]','FontSize',20,'Interpreter','latex');
grid on;
