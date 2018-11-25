%OFDM Simulation for Transmitter and reciever 
%*Author: Akshatha K V 1RV16EC018*
%% Transmitter

%Input bits generated randomly
n = 64;
disp('Length of Input Bit Stream ');
disp(n);
ip_bit_stream = randi([0 1], 1,n); %Generate n psuedorandom bits

figure(1);
stem(ip_bit_stream);
grid on; 
xlabel('Data Points');
ylabel('Amplitude');
title('Input Data ');


%regrouping into 4 bits in each symbol (16 QAM)
ip_stream = [];
i = 1;
while i < n
    temp = ip_bit_stream(i:i+3);
    x = bi2de(temp);
    ip_stream = [ip_stream x];
    i=i+4;
end

figure(10); % Create new figure window.
stem(ip_stream);
title('Random Symbols');
xlabel('Symbol Index');
ylabel('Integer Value');

disp('Modulating...');
tx = qammod(ip_stream,16);
disp('No. of QAM symbols generated: ');
disp(length(tx));


mag = abs(tx);
ang = angle(tx);

figure(2);
stem(mag);
xlabel('Complex Symbols');
ylabel('Magnitude');
title('QAM Modulation');

figure(3);
stem(ang);
xlabel('Complex Symbols');
ylabel('Angle');
title('QAM Modulation');

%I/P IFFT size and number of carriers
%IFFT_Size: n
%Number of Subcarriers: number of QAM Symbols
%Cyclic Prefix: n/4
ifft_size = 64;
carrier_count = 16;
guard_time = 64;

disp('IFFT Size: ');
disp(ifft_size);
disp('Number of Subcarriers: ');
disp(carrier_count);

%Determine spacing between carriers
spacing = 0;
while (carrier_count*spacing) <= (ifft_size/2 - 2)
 spacing = spacing + 1;
end
 spacing = spacing - 1;

%Space carriers out into IFFT bins
midFreq = ifft_size/4;
first_carrier = midFreq - round((carrier_count-1)*spacing/2);
last_carrier = midFreq + floor((carrier_count-1)*spacing/2);
carriers = [first_carrier:spacing:last_carrier] + 1;
conj_carriers = ifft_size - carriers + 2; %To maintain hermitian symmetry

%Pad zeros to make each OFDM frame have all carriers given (in matrix)
no_of_frames = ceil(length(tx)/carrier_count);
if length(tx)/carrier_count ~= no_of_frames
 padding = zeros(1, no_of_frames*carrier_count);
 padding(1:length(tx)) = tx;
 tx = padding;
end



%Serial to parallel
data_tx_matrix = reshape(tx, carrier_count, no_of_frames)';

%Put onto carriers
spectrum_tx = zeros(no_of_frames, ifft_size);
spectrum_tx(:,carriers) = data_tx_matrix;
spectrum_tx(:,conj_carriers) = conj(data_tx_matrix);

%IFFT
signal_tx = (ifft(spectrum_tx'))';

rows = size(signal_tx,1);
cols = size(signal_tx,2);

r = real(signal_tx);
i = imag(signal_tx);

figure(4);
stem(r);
xlabel('Discrete Time Domain');
ylabel('Real Part');
title('After IFFT Block');

figure(5);
stem(i);
xlabel('Discrete Time Domain');
ylabel('Imaginary Part');
title('After IFFT Block');

%Cyclic Prefix
end_symb = size(signal_tx, 2); 
signal_tx = [signal_tx(:,(end_symb-guard_time+1):end_symb) signal_tx];

r = real(signal_tx);
i = imag(signal_tx);

figure(6);
stem(r);
xlabel('Discrete Time Domain');
ylabel('Real Part');
title('After Cyclic Prefix Addition');

figure(7);
stem(i);
xlabel('Discrete Time Domain');
ylabel('Imaginary Part');
title('After Cyclic Prefix Addition');

%Parallel to serial
xp = signal_tx;
signal_tx = signal_tx'; 
signal_tx = reshape(signal_tx, 1, size(signal_tx,1)*size(signal_tx,2));



%% Add Noise

signal_c = awgn(signal_tx,15) ; %15 dB noise signal_tx;

%% Receiver
%Needs ifft_size, guard_time, length of bit stream, i.e n, carrier values 

signal_rx = signal_c;

%Serial to parallel
frame_size = ifft_size + guard_time;
len = length(signal_rx);
signal_rx = reshape(signal_rx, frame_size, len/frame_size);
signal_rx = signal_rx';

%Removing cyclic prefix
signal_rx = signal_rx(:, guard_time+1 :end);

%FFT
spectrum_rx = (fft(signal_rx'))';

%Extract data from carriers
data_rx_matrix = spectrum_rx(:,carriers);

%Convert to serial stream
rx = reshape(data_rx_matrix', 1 , size(data_rx_matrix,1) * size(data_rx_matrix,2));
rx = rx(:,1:n/4); 
%QAM Demodulation
op_stream = qamdemod(rx,16);

%Convert to bit stream
op_bit_stream = [];
for i=1:size(op_stream,2)
    x = de2bi(op_stream(i),4);
    op_bit_stream = [op_bit_stream x];
end

figure(8);
stem(op_bit_stream);
grid on; 
xlabel('Output Bits');
ylabel('Amplitude');
title('Output Data ');

nerrors = sum(ip_bit_stream ~= op_bit_stream);
disp('Nerrors =');
disp(nerrors);

figure(9);
subplot(2,1,1);
stem(ip_bit_stream);
xlabel('Data Points');
ylabel('Amplitude');
title('Transmitted Data ');
subplot(2,1,2);
stem(op_bit_stream);
xlabel('Data Points');
ylabel('Amplitude');
title('Recieved Data ');

