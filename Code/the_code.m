clear, clc, close all

[y1, Fs1] = audioread('Short_FM9090.wav');
[y2, Fs2] = audioread('Short_QuranPalestine.wav');
y1 =  y1(:);
y1 = y1(1:length(y1)/2);    % cutting the signal one into half
y2 =  y2(:);
y2 = y2(1:length(y2)/2);    % cutting the signal two into half

% padding the signal one to fit the length of the signal two
y1 = y1';
y1 = [y1 zeros(1, length(y2) - length(y1))];
y1 = y1';

% to frequency domain
Y1 = fft(y1);
K1 = - length(Y1)/2 : length(Y1)/2 -1;
subplot(3, 2, 1);
plot(K1*Fs1/length(Y1), abs(fftshift(Y1)))
Y2 = fft(y2);
title('Spectrum of signal one')
xlabel('Frequency in Hz')
subplot(3, 2, 2);
plot(K1*Fs2/length(Y2), abs(fftshift(Y2)))
title('Spectrum of signal one')
xlabel('Frequency in Hz')

% making interp
y1 = interp(y1, 10);  % Fs_new = 10 * Fs_old
y2 = interp(y2, 10);  % Fs_new = 10 * Fs_old

% creating the carrier one with freq = 100 khz and carrier two with freq 160 khz

t1 = 0 : 1/(10*Fs1) : length(y1)/(10*Fs1) - 1/(10*Fs1);   % getting the exact length of the signal seconds
c1 = cos(2*pi*100000*t1);
C1 = fft(c1);
K3 = - length(C1)/2 : length(C1)/2 -1;
%subplot(4, 1, 3);
%plot(K3*10*Fs1/length(C1), abs(fftshift(C1)))

t2 = 0: 1/(10*Fs2) : length(y2)/(10*Fs2) - 1/(10*Fs2);
c2 = cos(2*pi*160000*t2);
C2 = fft(c2);
K4 = -length(C2)/2 : length(C2)/2 -1;
%subplot(4, 1, 4);
%plot(K4*Fs2/length(C2), abs(fftshift(C2)))

% making the modulation
c1 = c1';
m1 = y1 .* c1;
M1 = fft(m1);
K5 = - length(M1)/2 : length(M1)/2 -1;
subplot(3, 2, 3);
plot(K5*10*Fs1/length(M1), abs(fftshift(M1)))
title('Modulated signal one with carrier frequency 100 kHz')
xlabel('Frequency in Hz')

c2 = c2';
m2 = y2 .* c2;
M2 = fft(m2);
K6 = -length(M2)/2 : length(M2)/2 -1;
subplot(3, 2, 4);
plot(K6*10*Fs2/length(M2), abs(fftshift(M2)))
title('Modulated signal two with carrier frequency 160 kHz')
xlabel('Frequency in Hz')

% % making the channel in FDM
subplot(3, 2, [5 6]);
mx = m1 + m2;
Mx = fft(mx);
plot(K6*10*Fs1/length(Mx), abs(fftshift(Mx)))
title('Spectrum of the channel')
xlabel('Frequency in Hz')

% RF stage
bpFilt1 = designfilt('bandpassfir', 'FilterOrder', 20, ...
             'CutoffFrequency1', 95000, 'CutoffFrequency2', 105000,...
             'SampleRate', 441000);  
bpFilt2 = designfilt('bandpassfir', 'FilterOrder', 20, ...
             'CutoffFrequency1', 155000, 'CutoffFrequency2', 165000,...
             'SampleRate', 441000);  
freqz(bpFilt1)
freqz(bpFilt2)
figure
subplot(4, 1, 1)
mx_RF1 = fftfilt(bpFilt1, mx);
Mx_RF_BPF1 = fft(mx_RF1);
plot(K6*10*Fs1/length(Mx), abs(fftshift(Mx_RF_BPF1)))
title('The multiplexed siganl after the BPF centered at 100 kHz ')
xlabel('Frequency in Hz')
subplot(4, 1, 2)
mx_RF2 = fftfilt(bpFilt2, mx);
Mx_RF_BPF2 = fft(mx_RF2);
plot(K6*10*Fs1/length(Mx), abs(fftshift(Mx_RF_BPF2)))
title('The multiplexed siganl after the BPF centered at 160 kHz ')
xlabel('Frequency in Hz')

% Mixer stage

% creating the int carrier one with freq = 100+30 khz and int carrier two with freq 160+30 khz

t11 = 0 : 1/(10*Fs1) : length(y1)/(10*Fs1) - 1/(10*Fs1);   % getting the exact length of the signal seconds
c11 = cos(2*pi*(100000+30000)*t11);
C11 = fft(c11);
K33 = - length(C11)/2 : length(C11)/2 -1;
%subplot(4, 1, 3);
%plot(K33*10*Fs1/length(C11), abs(fftshift(C11)))

t22 = 0: 1/(10*Fs2) : length(y2)/(10*Fs2) - 1/(10*Fs2);
c22 = cos(2*pi*(160000+30000)*t22);
C22 = fft(c22);
K44 = -length(C22)/2 : length(C22)/2 -1;

%subplot(4, 1, 4);
%plot(K44*Fs2/length(C22), abs(fftshift(C22)))
c11 = c11';
mx_RF1_int = mx_RF1 .* c11;
Mx_RF1_int = fft(mx_RF1_int);
subplot(4, 1, 3);
plot(K6*10*Fs1/length(Mx_RF1_int), abs(fftshift(Mx_RF1_int)))
title('The siganl after the mixer with carrier 130 kHz')
xlabel('Frequency in Hz')

c22 = c22';
mx_RF2_int = mx_RF2 .* c22;
Mx_RF2_int = fft(mx_RF2_int);
subplot(4, 1, 4);
plot(K6*10*Fs1/length(Mx_RF2_int), abs(fftshift(Mx_RF2_int)))
title('The siganl after the mixer with carrier 160 kHz')
xlabel('Frequency in Hz')

% IF stage

bpFilt3 = designfilt('bandpassfir', 'FilterOrder', 20, ...
             'CutoffFrequency1', 25000, 'CutoffFrequency2', 35000,...
             'SampleRate', 441000);  
figure
subplot(2, 1, 1)
mx_RF1 = fftfilt(bpFilt3, mx_RF1_int);
Mx_RF_BPF1 = fft(mx_RF1);
plot(K6*10*Fs1/length(Mx), abs(fftshift(Mx_RF_BPF1)))
title('The first siganl after the BPF centered at 30 kHz ')
xlabel('Frequency in Hz')
subplot(2, 1, 2)
mx_RF2 = fftfilt(bpFilt3, mx_RF2_int);
Mx_RF_BPF2 = fft(mx_RF2);
plot(K6*10*Fs1/length(Mx), abs(fftshift(Mx_RF_BPF2)))
title('The first siganl after the BPF centered at 30 kHz ')
xlabel('Frequency in Hz')

% Baseband detection stage

% creating the base carrier one with freq = 30 khz

t11 = 0 : 1/(10*Fs1) : length(y1)/(10*Fs1) - 1/(10*Fs1);   % getting the exact length of the signal seconds
c111 = cos(2*pi*(30000)*t11);
C111 = fft(c111);
K33 = -length(C111)/2 : length(C111)/2 -1;
%subplot(4, 1, 3);
%plot(K33*10*Fs1/length(C11), abs(fftshift(C11)))

figure
c111 = c111';
mx_base1 = mx_RF1 .* c111;
Mx_base1 = fft(mx_base1);
subplot(4, 1, 1);
plot(K6*10*Fs1/length(Mx_RF1_int), abs(fftshift(Mx_base1)))
title('The first siganl after the mixer with carrier 30 kHz')
xlabel('Frequency in Hz')

mx_base2 = mx_RF2 .* c111;
Mx_base2 = fft(mx_base2);
subplot(4, 1, 2);
plot(K6*10*Fs1/length(Mx_RF2_int), abs(fftshift(Mx_base2)))
title('The second siganl after the mixer with carrier 30 kHz')
xlabel('Frequency in Hz')

% Designing of the low pass filter
lpFilt = designfilt('lowpassfir', 'PassbandFrequency', 0.05,...
             'StopbandFrequency', 0.07, 'PassbandRipple', 0.5, ...
             'StopbandAttenuation', 65, 'DesignMethod', 'kaiserwin'); 
         
subplot(4, 1, 3);         
m_base1 = fftfilt(lpFilt, mx_base1);   
M_base1 = fft(m_base1);
plot(K6*10*Fs1/length(Mx_RF1_int), abs(fftshift(M_base1))) 
title('The first siganl after the LPF')
xlabel('Frequency in Hz')

subplot(4, 1, 4);
m_base2 = fftfilt(lpFilt, mx_base2);   
M_base2 = fft(m_base2);
plot(K6*10*Fs1/length(Mx_RF1_int), abs(fftshift(M_base2)))
title('The second siganl after the LPF')
xlabel('Frequency in Hz')

output_sig1 = downsample(m_base1, 10);
output_sig2 = downsample(m_base2, 10);
sound(10 * output_sig1, Fs1)
pause(17)
sound(10 * output_sig2, Fs2)