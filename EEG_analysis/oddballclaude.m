%% Oddball. event-related potential (ERP)
% Rare stimulus (O, ~20%) = code 2   -> should produce a P300
% Common stimulus (X, ~80%) = code 1 -> small/no P300
clearvars; close all; clc
load Oddball.mat            % eeg [Nx1], t [Nx1], stims [569x1], stimtimes [569x1]
 
eeg = eeg(:);               % make sure it is a column
 
fs    = round(1/median(diff(t)));   % Sampling frequency (Hz), taken from the time vector
fprintf('Sampling frequency: %d Hz  |  recording length: %.1f s\n', fs, length(eeg)/fs);
% (If fs comes out absurdly small, t is in ms instead of s -> use 1000/median(diff(t)))
 
t_pre = 100;                        % ms BEFORE the stimulus (baseline)
t_wd  = 800;                        % ms epoch Time window AFTER the stimulus
N_pre = round(t_pre/1000*fs);       % baseline samples
N_wd  = round(t_wd/1000*fs);        % number of samples at each epoch (post-stimulus)
tt    = (-N_pre:N_wd-1)/fs*1000;    % epoch time axis in ms (0 = stimulus onset)
 
%% Optional: band-pass filter the continuous EEG before cutting epochs
% 0.5-30 Hz keeps the ERP, removes slow drift and 50 Hz mains / muscle noise.
% filtfilt = zero phase -> peaks are NOT shifted in time (important for latency!)
do_filter = true;
if do_filter
    [B,A] = butter(4, [0.5 30]/(fs/2), 'bandpass');
    eeg   = filtfilt(B, A, eeg);
end
 
%% Stimulus indices
% Rare stimulus is number 2, Common is number 1
idx_stim2 = round(stimtimes(stims==2)*fs);  % Indices of rare stimulus
idx_stim1 = round(stimtimes(stims==1)*fs);  % Indices of common stimulus
 
% Discard events whose epoch would fall outside the recording
ok = @(idx) idx(idx-N_pre >= 1 & idx+N_wd-1 <= length(eeg));
idx_stim2 = ok(idx_stim2);
idx_stim1 = ok(idx_stim1);
fprintf('Rare (O): %d epochs  |  Common (X): %d epochs\n', length(idx_stim2), length(idx_stim1));
 
%% Load in a matrix the epochs of the rare stimulus (one row per trial)
ERP = zeros(length(idx_stim2), N_pre+N_wd);      % Initialize the matrix
for ii = 1:length(idx_stim2)
    seg = eeg(idx_stim2(ii)-N_pre : idx_stim2(ii)+N_wd-1)';
    ERP(ii,:) = seg - mean(seg(1:N_pre));        % baseline correction
end
 
% Same for the common stimulus
ERP_c = zeros(length(idx_stim1), N_pre+N_wd);
for ii = 1:length(idx_stim1)
    seg = eeg(idx_stim1(ii)-N_pre : idx_stim1(ii)+N_wd-1)';
    ERP_c(ii,:) = seg - mean(seg(1:N_pre));
end
 
%% Make the average
ERP_mean   = mean(ERP, 1);          % rare
ERPc_mean  = mean(ERP_c, 1);        % common
ERP_diff   = ERP_mean - ERPc_mean;  % difference wave (isolates the "oddball" response)
 
% Standard error of the mean (how reliable each average is)
sem_r = std(ERP,  0, 1)/sqrt(size(ERP,1));
sem_c = std(ERP_c,0, 1)/sqrt(size(ERP_c,1));
 
%% P300: biggest positive peak between 250 and 600 ms in the difference wave
win = tt >= 250 & tt <= 600;
tw  = tt(win);
[P3_amp, k] = max(ERP_diff(win));
P3_lat = tw(k);
fprintf('P300 (rare - common): %.2f uV at %.0f ms\n', P3_amp, P3_lat);
 
%% Plot it
% Figure 1: single trials vs average -> averaging removes the noise
figure('Color','w');
plot(tt, ERP', 'Color', [0.8 0.8 0.8]); hold on
plot(tt, ERP_mean, 'r', 'LineWidth', 2)
xline(0,'k--'); grid on
xlabel('Time after stimulus (ms)'); ylabel('Potential (\muV)')
title(sprintf('Rare stimulus: %d single trials (grey) and their average (red)', size(ERP,1)))
 
% Figure 2: rare vs common, with SEM bands
figure('Color','w'); hold on
fill([tt fliplr(tt)], [ERP_mean+sem_r fliplr(ERP_mean-sem_r)], 'r', 'FaceAlpha',0.2,'EdgeColor','none');
fill([tt fliplr(tt)], [ERPc_mean+sem_c fliplr(ERPc_mean-sem_c)], 'b', 'FaceAlpha',0.2,'EdgeColor','none');
h1 = plot(tt, ERP_mean,  'r', 'LineWidth', 2);
h2 = plot(tt, ERPc_mean, 'b', 'LineWidth', 2);
h3 = plot(tt, ERP_diff,  'k', 'LineWidth', 1.5);
plot(P3_lat, P3_amp, 'ko', 'MarkerFaceColor','y', 'MarkerSize', 8)
text(P3_lat+15, P3_amp, sprintf('P300\n%.0f ms', P3_lat))
xline(0,'k--'); yline(0,'k:'); grid on
xlabel('Time after stimulus (ms)'); ylabel('Potential (\muV)')
legend([h1 h2 h3], {'Rare (O, 20%)','Common (X, 80%)','Rare - Common'}, 'Location','best')
title('Oddball ERP')
 
% Figure 3: noise goes down as 1/sqrt(N) when averaging more trials
Ns = [1 5 10 20 50 size(ERP,1)];
figure('Color','w');
for k = 1:length(Ns)
    subplot(length(Ns),1,k)
    plot(tt, mean(ERP(1:Ns(k),:),1), 'r'); xline(0,'k--'); grid on
    ylabel(sprintf('N=%d', Ns(k)))
end
xlabel('Time after stimulus (ms)')
sgtitle('Average of the first N rare trials')
 
% Residual noise (std in the baseline) vs number of trials
Nall  = 1:size(ERP,1);
noise = arrayfun(@(n) std(mean(ERP(1:n,1:N_pre),1)), Nall(2:end));
figure('Color','w');
loglog(Nall(2:end), noise, 'r.-'); hold on
loglog(Nall(2:end), noise(1)*sqrt(2)./sqrt(Nall(2:end)), 'k--')
grid on; xlabel('Number of averaged trials N'); ylabel('Baseline noise (\muV)')
legend('Measured','Theory: \propto 1/\surdN'); title('Averaging reduces noise')