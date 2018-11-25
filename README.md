# Simulation-of-OFDM
5th Semester Project: This Matlab code uses QAM Modulation scheme to transmit data over a noisy channel and Recieves using QAM Demodulation Scheme
Transmitter:
1.Input is Generated as a random binary bits. 
2.The binary bits are grouped into set of four bits and converted to decimal values.
3.The decimal values are modulated according to QAM-16 scheme.
4.Magnitude and Phase values are calculated.
5.IIFT of this data is calculated to employ Hermitian Symmetry
6.Cyclic Prefix is applied to avoid inter-symbol interference

Channel: AWGN of 15dB is added to the Transmitted data

Reciever: 
1. Remove Cyclic prefix
2. Caculate FFT
3. Demodulate using QAM-demodulation
4.Convert Decimal Values to Binary bits
5.Calculate Error in Reception
