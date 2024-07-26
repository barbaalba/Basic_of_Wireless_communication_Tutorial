function ULA_response = ULA_Evaluate(N,Azimuth,d)
% To evaluate antenna vector for Uniform Linear Array 
% Inputs: 
%   N: Number of antenna array 
%   Azimuth: Azimuth of Arrival/Departure
%   d: normalized inter-element spacing
% 
% Output:
%   ULA_response: Antenna array response

ULA_response = zeros(N,length(Azimuth));

for n = 1:length(Azimuth)

    ULA_response(:,n) = exp(-1i*2*pi*d*sin(Azimuth(n))*(0:N-1)');

end