% 
% Spectrogram
% The signal eeg contains a simple EEG experiment opening and closing the
% eyes. The sampling rate is 256 Hz.
% Plot the spectrogram and spot when the subject had his oyes closed.
clearvars, close all
load EEG
figure,
win = hamming(512); % window. Try hamming for example
overlap = 100;
Nfft = 256;
spectrogram(eeg,win,overlap,Nfft,'yaxis');
    


% Find the open/close stages
% This solution is an alternative to spectrogram. It is based on bandpass
% filtering. The presence of different frequency bands is assessed by the 
% the amplitude of the filtered signal  
% HINT: you might want to use moving average filter and thresholding
clearvars, close all
load EEG
fs = 256;
N = length(eeg);
t = [0:1/fs:(N-1)/fs]';

figure('Position',[100 100 900 300])
plot(t,eeg), axis tight
xlabel('Time (s)','FontSize',24);ylabel('EEG (\muV)','FontSize',24)
xt = get(gca, 'XTick');set(gca, 'FontSize', 16)

% band pass filter
[B,A] = butter(6,[8 15]/(fs/2),'bandpass');% higher order -> sharper filter / consequence : impulse response is longer
% longer response: if signal changes too quickly you will have an
% adaptation of the impulse all the time and wont get a meaningful signal
[h,th] = impz(B,A,512);
[H,F] = freqz(B,A,1024,fs);

figure
subplot(211), plot(th,h), axis tight
title('Impulse response');xlabel('Samples','FontSize',24);
xt = get(gca, 'XTick');set(gca, 'FontSize', 16)

subplot(212), plot(F,abs(H)), axis tight
title('Amplitude response')
xlabel('Frequency (Hz)','FontSize',24);ylabel('Relative Amplitude','FontSize',24)
xt = get(gca, 'XTick');set(gca, 'FontSize', 16)


% Bandpass filtering
x1 = filtfilt(B,A,eeg);

figure('Position',[100 100 560 700])
subplot(411), plot(t,eeg,'b-'), axis tight
title('Measured signal')
subplot(412), plot(t,x1,'b-'), axis tight
title('Bandpass filtered signal')

% Rectifying and squaring
x2 = abs(x1).^2;
subplot(413), plot(t,x2,'b-'), axis tight
title('Rectified signal')

% MA filtering
x3 = filtfilt(ones(1,fs/2)/(fs/2),1,x2);
subplot(414), plot(t,x3,'b-'), axis tight
title('MA filtered signal')

% Thresholding
thr = 40;
Inds = find(x3 >= thr);
hold on
line([0 60],[thr thr],'Color','red')
plot(t(Inds),zeros(size(Inds)),'g.')
