
clearvars;close all
clc;

%read the data using the ReadEDF function by Andrey Shapking : Epilepsy
%    http://www.mathworks.com/matlabcentral/fileexchange/38641-reading-and-
%    saving-of-data-in-the-edf
% [data, header] = ReadEDF('alu_eeg.edf');
[data, header] = ReadEDF('chb19_30.edf');
L = 5000;
%move the data from a cell to a multidimensional array and take only the first 5000 values
eeg_data = zeros(length(data),L);
for i = 1 : length(data)
    eeg_data(i,:) = data{i}(1:L);
end

%plot only the first 10 channels of your data
figure('units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1])
fs = header.samplerate(1);
fs = fs(1);
t = 0:1/fs:(L-1)/fs;
for i = 1 : 10
    subplot(5,2,i);
    plot(t,eeg_data(i,:));
    title(header.labels{i});
    ylabel('Potential (\muV)')
    set(gca,'FontSize',15)
    grid minor
end

% to find the anatomical position of these electrodes check the standard
% Internation 10-20 EEG system
%  http://www.bem.fi/book/13/13.htm#03

% Now, try to find the different EEG rhythms knowing that their freq content is
%   Delta 0.5Hz up to 4 Hz;
%   Theta  4 - 8 Hz
%   Alpha 8 - 13 Hz
%   Beta 13 - 30 Hz
%   Gamma 30 - 100 Hz
deltaBand = [0.5,4];
thetaBand = [4,8];
alphaBand = [8,13];
betaBand = [13,30];
gammaBand = [30,100];

% For this example, we will only use the first channel, remember to
% select an adequate electrode in order to find the proper rhythm. Notice as
% well that all rhythms might not be visible at all times.

% NOTA ... Los estudiantes deberian saber tres metodos de filtrado
% 1 - usando las funciones de transferencia
% 2 - usando funciones propias de matlab para general filtros
% 3 - usando la transformada de Fourier

% A continuacion lo hare usando Fourier para el Alpha, pero lo mismo se
% aplica para las demas
Fs = header.samplerate(1);
T = 1/Fs; % Sample time
L = size(eeg_data,2); % Length of signal
t = (0:L-1)*T; % Time vector

%Fourier transform of our signal using the fast fourier transform
eeg_fft = fft(eeg_data(1,:), L);
%used to properly view the frequency components of our signal
f = Fs*linspace(0,1,L); %/2+1);
%figure;
%plot(f,2*abs(eeg_fft(1:L)));
%title('FFT plot');

% Delta 0.5 -> 4 Hz
freqMin = round(deltaBand(1)*L/Fs);
freqMax = round(deltaBand(2)*L/Fs);
% Square filter
eeg_fft_filt = eeg_fft*0; %create an empty signal
eeg_fft_filt(freqMin:freqMax) = eeg_fft(freqMin:freqMax);
eeg_fft_filt((L-freqMax):(L-freqMin)) = eeg_fft((L-freqMax):(L-freqMin));
[B,A] = butter(6,deltaBand(2)/(fs/2),'low');
[H,F] = freqz(B,A,length(eeg_fft),'whole',Fs);
plot(F,abs(H))
% Butter Filter
win = zeros(L,1);
win(freqMin:freqMax-1) = hamming(freqMax-freqMin);
win((L-freqMax):(L-freqMin)-1) = hamming(freqMax-freqMin);
eeg_fft_filt_win = eeg_fft.*abs(H)'; %create an empty signal
figure(2);clf
subplot(3,1,1)
plot(f,abs(eeg_fft))
title('FFT')
xlabel('Hz')
grid minor
axis ([ 0 255 0 4.5E4])
subplot(3,1,2)
plot(f,abs(eeg_fft_filt))
subplot(3,1,3)
plot(f,abs(eeg_fft_filt_win))

%plot the filtered fourier space
%figure;
%plot(f,2*abs(eeg_fft_filt(1:L)));
%title('FFT plot');
%we can now do the inverse transform to recover the alpha rhythm
figure(3);clf
eeg_delta = ifft(eeg_fft_filt,L);
eeg_delta_win = ifft(eeg_fft_filt_win,L);
subplot(2,1,1)
plot(real(ifft(eeg_fft_filt_win,L)))
subplot(2,1,2)
plot(real(ifft(eeg_fft_filt,L)))

figure(4);clf
figure('units','normalized','outerposition',[0 0 1 1],'Color',[1 1 1])

subplot(5,1,1);
plot(t,real(eeg_delta(1:L))); title('Delta 0.5 - 4 Hz');
eeg_delta = ifft(eeg_fft_filt_win,L);
ylabel('Potential (\muV)')
set(gca,'FontSize',12)

% Theta 4 - 8 Hz
freqMin = round(4*L/Fs);
freqMax = round(8*L/Fs);
eeg_fft_filt = eeg_fft*0; %create an empty signal
eeg_fft_filt(freqMin:freqMax) = eeg_fft(freqMin:freqMax);
eeg_fft_filt((L-freqMax):(L-freqMin)) = eeg_fft((L-freqMax):(L-freqMin));
%we can now do the inverse transform to recover the rhythm
eeg_theta = ifft(eeg_fft_filt,L);
subplot(5,1,2);
plot(t,real(eeg_theta(1:L))); title('Theta 4 - 8 Hz');
ylabel('Potential (\muV)')
set(gca,'FontSize',12)

% Alpha  8 -> 13 Hz
freqMin = round(8*L/Fs);
freqMax = round(13*L/Fs);
eeg_fft_filt = eeg_fft*0; %create an empty signal
eeg_fft_filt(freqMin:freqMax) = eeg_fft(freqMin:freqMax);
eeg_fft_filt((L-freqMax):(L-freqMin)) = eeg_fft((L-freqMax):(L-freqMin));
%we can now do the inverse transform to recover the alpha rhythm
eeg_alpha = ifft(eeg_fft_filt,L);
subplot(5,1,3);
plot(t,real(eeg_alpha(1:L))); title('Alpha 8 - 13 Hz');
ylabel('Potential (\muV)')
set(gca,'FontSize',12)

% Beta 13 - 30 Hz
freqMin = round(13*L/Fs);
freqMax = round(30*L/Fs);
eeg_fft_filt = eeg_fft*0; %create an empty signal
eeg_fft_filt(freqMin:freqMax) = eeg_fft(freqMin:freqMax);
eeg_fft_filt((L-freqMax):(L-freqMin)) = eeg_fft((L-freqMax):(L-freqMin));
%we can now do the inverse transform to recover the rhythm
eeg_beta = ifft(eeg_fft_filt,L);
subplot(5,1,4);
plot(t,real(eeg_beta(1:L))); title(' Beta 13 - 30 Hz');
ylabel('Potential (\muV)')
set(gca,'FontSize',12)

% Gamma 30 - 100 Hz
freqMin = round(30*L/Fs);
freqMax = round(100*L/Fs);
eeg_fft_filt = eeg_fft*0; %create an empty signal
eeg_fft_filt(freqMin:freqMax) = eeg_fft(freqMin:freqMax);
eeg_fft_filt((L-freqMax):(L-freqMin)) = eeg_fft((L-freqMax):(L-freqMin));
%we can now do the inverse transform to recover the rhythm
eeg_gamma = ifft(eeg_fft_filt,L);
subplot(5,1,5);
plot(t,real(eeg_gamma(1:L))); title(' Gamma 30 - 100 Hz');
xlabel('Time(sec)');    ylabel('Potential (\muV)')
set(gca,'FontSize',12)
