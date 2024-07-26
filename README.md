# Basic_of_Wireless_communication_Tutorial

# Equalization
- Zero-Forcing:
  It inverses the channel effect such that the combined effect of the channel and equalizer leads to the identity operation (interference cancellation). However, it does not account for possible noise amplification. It is effective when the channel matrix is full-rank. The noise amplification happens when the channel is in deep fade where the singular value of channel matrix **H** is low, resulting in large element values of the inverted matrix. 
- Matched Filtering:
   Maximize the SNR, but it does not consider the possible interference.
- Minimum Mean Squared Error:
   It is balancing MF and ZF. In high SNR, it converges to ZF; in low interference, it converges to MF.
  
  **NOTE:** Adding noise power inside the inversion operation suppresses the noise if the channel is in deep fade.

# Waterfilling
  Function waterfilling.m compute assigned power using bisection while functionwaterfilling.m follows the approach explained in [1, section 3.4]

# Time of Arrival and Synchronization
It simply cross-correlates the Rx signal with the Tx signal and finds the peak of the correlation function. Longer signal duration results in higher precision in estimating the time of arrival. This step is mandatory to synchronize the clocks in the communication system. In multipath_synchornization.m, a chirp signal is used to get an accurate detection of the first arrived path.

# Angle of Arrival 
MUSIC and ESPRIT are two classical algorithms to estimate the angle of arrivals [2]. MUSIC requires to know the number of users/peaks in advance. However, it can be estimated.

# References
[1] Björnson, Emil, and Özlem Tuğfe Demir. "Introduction to multiple antenna communications and reconfigurable surfaces." (2024). 

[2] Ramezani, Parisa, Özlem Tuğfe Demir, and Emil Björnson. "Localization in massive MIMO networks: From near-field to far-field." arXiv preprint arXiv:2402.07644 (2024).
