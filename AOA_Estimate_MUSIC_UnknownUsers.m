% This code is implementing MUSIC with unknown number of sources
% Further Resource:
% - M. Wax and T. Kailath, "Detection of signals by information theoretic 
%   criteria," in IEEE Transactions on Acoustics, Speech, and Signal 
%   Processing, vol. 33, no. 2, pp. 387-392, April 1985
% - E. Fishler, M. Grosmann and H. Messer, "Detection of signals by 
% information theoretic criteria: general asymptotic performance analysis,"
% in IEEE Transactions on Signal Processing, vol. 50, no. 5, pp. 1027-1036,
% May 2002, doi: 10.1109/78.995060.
clear;clc; close all;

%% Scenario
% antenna configuration
N = 32; d_H = 1/2;

SNR = 10; % received SNR in dB
L = 20; % pilot symbol length
K = 3; % maximum number of users in the system

% grid search (MUSIC)
angle_search = -pi/2:pi/N:pi/2; % angle grid
grid_response = ULA_Evaluate(N,angle_search,d_H); % grid response

%% System model
    
% channel parameters
ang_idx = randperm(length(angle_search));
azimuth_angles = angle_search(ang_idx(1:K));
A = ULA_Evaluate(N,azimuth_angles,d_H); % channel
s = 1/sqrt(2) * (randn(K,L) + 1i * randn(K,L)); % data
n = 1/sqrt(2) * (randn(N,L) + 1i * randn(N,L)); % data

R = zeros(N,N);
for i = 1:L
    y = A * s(:,i) * sqrt(db2pow(SNR))+ n(:,i); % End-End communication
    R = R + y * y'; % received signal correlation matrix
end

R = R/L;
[U,D] = eig(R); % eigen decomposition (D is ascending order) R = U*D*U'
[~,sort_ind] = sort(diag(D),'descend'); 
D = D(sort_ind,sort_ind); % descending ordereed eignevalues
U = U(:,sort_ind);
D = diag(D);
% estimate number of users
MDL = zeros(1,N/2);
for k = 1:N/2
    numerator = prod(D(k+1:end));
    denominator = (sum(D(k+1:end))/(N-k))^(N-k);
    MDL(k) = -L * log(numerator/denominator) + 0.5*k*(2*N-k)*log(L);
end
[~,K_est] = min(MDL);
disp(['Number of estimated user is:',num2str(K_est)]);
U_n = U(:,K_est+1:end); % noise sub_space
U_s = U(:,1:K_est); % signal space

MUSIC_spectrum = abs(diag(1./(grid_response'*(U_n*U_n')*grid_response))); % MUSIC

[pkvalue,idx] = findpeaks(MUSIC_spectrum,'SortStr','descend','NPeaks',K_est);

figure;
plot(angle_search,pow2db(MUSIC_spectrum),'LineWidth',2);
hold on;
plot(azimuth_angles,pow2db(MUSIC_spectrum(ang_idx(1:K_est))),'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',2);
plot(angle_search(idx),pow2db(MUSIC_spectrum(idx)),'LineStyle','none','Marker','x','MarkerSize',10,'LineWidth',2);
xlabel('Angles [radian]','FontSize',20,'Interpreter','latex');
ylabel('Spectrum value','FontSize',20,'Interpreter','latex');
ax = gca;
grid on;
ax.FontSize = 20;
hold on;
legend('MUSIC Spectrum','True angle','MUSIC selection','FontSize',20,'interpreter','latex');