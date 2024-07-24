# Basic_of_Wireless_communication_Tutorial

# Equalization
- Zero-Forcing:
  It inverses the channel effect such that the combined effect of the channel and equalizer leads to the identity operation (interference cancellation). However, it does not account for possible noise amplification. It is effective when the channel matrix is full-rank. The noise amplification happens when the channel is in deep fade where the singular value of channel matrix **H** is low, resulting in large element values of the inverted matrix. 
- Matched Filtering:
   Maximize the SNR, but it does not consider the possible interference.
- Minimum Mean Squared Error:
   It is balancing MF and ZF. In high SNR, it converges to ZF; in low interference, it converges to MF.
  
  **NOTE:** Adding noise power inside the inversion operation suppresses the noise if the channel is in deep fade. 
