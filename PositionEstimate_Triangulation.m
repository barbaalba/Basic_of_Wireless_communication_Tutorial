clear; clc; close all;
fc = 28e9; % Carrier frequency
N = 64; % Number of antennas
d_H = 1/2; % Normalized inter-element spacing 
snr = db2pow(0); % SNR at the recievr
pilot_length = 10;

% 2D coordinates for the Access Points (AP)
AP1 = [0, 0]; % Access Point 1 coordinates
AP2 = [100, 0]; % Access Point 2 coordinates

% Actual position of the user in the 2D space
userPos = [45, 45];

% Simulate the reception of pilot signals at each AP
% Assuming pilot signal is a known constant for simplicity
pilotSignal = 1; 

% Define the speed of signal propagation (e.g., speed of light)
c = 3e8;

% Calculate the distances from the user to each AP
d1 = norm(userPos - AP1);
d2 = norm(userPos - AP2);

% Calculate the Time of Arrival (TOA) for the pilot signal at each AP
TOA1 = d1 / c;
TOA2 = d2 / c;

% Evaluate true angle of arrivals with respect to X-axis
AoA1 = atan2(userPos(2) - AP1(2), userPos(1) - AP1(1));
AoA2 = atan2(userPos(2) - AP2(2), userPos(1) - AP2(1));

% Convert AoA to degrees
AoA1_deg = rad2deg(AoA1);
AoA2_deg = rad2deg(AoA2);

% Display the angles of arrival
disp(['AoA at AP1: ', num2str(AoA1_deg), ' degrees']);
disp(['AoA at AP2: ', num2str(AoA2_deg), ' degrees']);

% channel from user to two APs
h1 = exp(-1i*2*pi*fc*TOA1) * exp(1i*(0:N-1)'*2*pi*d_H*cos(AoA1));
h2 = exp(-1i*2*pi*fc*TOA2) * exp(1i*(0:N-1)'*2*pi*d_H*cos(AoA2));

% noise vector for received signals at two APs
n1 = sqrt(0.5/snr) * (randn(N,pilot_length) + 1i* randn(N,pilot_length));
n2 = sqrt(0.5/snr) * (randn(N,pilot_length) + 1i* randn(N,pilot_length));

% transmit pilot symbols and evaluate correlation matrix
R1 = zeros(N,N);
R2 = zeros(N,N);
for p = 1:pilot_length
    % receive signal at two APs
    y1 = h1 + n1(:,p);
    y2 = h2 + n2(:,p);
    R1 = R1 + y1*y1';
    R2 = R2 + y2*y2';
end
R1 = R1/pilot_length;
R2 = R2/pilot_length;

% Estiamte AOA using MUSIC
% grid search (MUSIC)
angle_search = 0:pi/N:pi; % angle grid
grid_response = exp(1i*2*pi*d_H*(0:N-1)' * cos(angle_search)); % grid response

[U1,D1] = eig(R1); % eigen decomposition (D is ascending order) R = U*D*U'
[U2,D2] = eig(R2); % eigen decomposition (D is ascending order) R = U*D*U'

U_n1 = U1(:,1:(N-1)); % noise sub_space
U_s1 = U1(:,end); % signal space

U_n2 = U2(:,1:(N-1)); % noise sub_space
U_s2 = U2(:,end); % signal space

MUSIC_spectrum1 = abs(diag(1./(grid_response'*(U_n1*U_n1')*grid_response))); % MUSIC
MUSIC_spectrum2 = abs(diag(1./(grid_response'*(U_n2*U_n2')*grid_response))); % MUSIC

[pkvalue1,idx1] = findpeaks(MUSIC_spectrum1,'SortStr','descend','NPeaks',1);
[pkvalue2,idx2] = findpeaks(MUSIC_spectrum2,'SortStr','descend','NPeaks',1);

AOA1_estimated = angle_search(idx1);
AOA2_estimated = angle_search(idx2);

% Convert AoA to degrees
AoA1_estimated_deg = rad2deg(AOA1_estimated);
AoA2_estimated_deg = rad2deg(AOA2_estimated);

% Display the angles of arrival
disp(['Estimated AoA at AP1: ', num2str(AoA1_estimated_deg), ' degrees']);
disp(['Estimated AoA at AP2: ', num2str(AoA2_estimated_deg), ' degrees']);

% Estimating the user position using estimated AoAs using triangulation
% Define the direction vectors from each AP using the AoAs
dirVec1 = [cos(AOA1_estimated), sin(AOA1_estimated)];
dirVec2 = [cos(AOA2_estimated), sin(AOA2_estimated)];

% Set up a system of linear equations based on the direction vectors and AP positions
A = [dirVec1(1), -dirVec2(1); dirVec1(2), -dirVec2(2)];
b = [AP2(1) - AP1(1); AP2(2) - AP1(2)];

% Solve for the intersection point (user position)
t = A \ b;
estUserPos = AP1 + t(1) * dirVec1;

% Display the estimated user position
disp(['Estimated User Position: (', num2str(estUserPos(1)), ', ', num2str(estUserPos(2)), ')']);
disp(['Actual User Position: (', num2str(userPos(1)), ', ', num2str(userPos(2)), ')']);

% Plotting the results
figure;
hold on;
plot(AP1(1), AP1(2), 'bo', 'MarkerSize', 10, 'DisplayName', 'AP1');
plot(AP2(1), AP2(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'AP2');
plot(userPos(1), userPos(2), 'g*', 'MarkerSize', 10, 'DisplayName', 'Actual User Position');
plot(estUserPos(1), estUserPos(2), 'k+', 'MarkerSize', 10, 'DisplayName', 'Estimated User Position');
quiver(AP1(1), AP1(2), dirVec1(1), dirVec1(2), 5, 'b', 'DisplayName', 'AoA from AP1');
quiver(AP2(1), AP2(2), dirVec2(1), dirVec2(2), 5, 'r', 'DisplayName', 'AoA from AP2');
legend;
xlabel('X Coordinate');
ylabel('Y Coordinate');
title('User Position Estimation using AoA from Two APs');
grid on;
hold off;

disp(['localization error (m): ', num2str(norm(estUserPos - userPos))]);