%-------------------------------------------------------------------------
%% 1. Obtain digitized pulses 
%-------------------------------------------------------------------------
clearvars; close all
load('radiation_alu.mat'); % loads radPulses and fs
[nPulses, nSamples] = size(radPulses ) % no semicolon: so it prints 36817 75
t = (0:nSamples-1)/fs*1e6; % time axis in microseconds

% 100 pulses from a gamma with different deposited E
figure(1); clf
plot(t, radPulses(1:100,:)');              % ' flips the matrix so each pulse is one curve
xlabel('Time (\mus)'); ylabel('Voltage (au)'); title('100 raw pulses')

% Example of pulse number 10
figure(2); clf
plot(t, radPulses(10,:));                  % one single pulse
xlabel('Time (\mus)'); ylabel('Voltage (au)'); title('Pulse #10')

%-------------------------------------------------------------------------
%% 2. Quantify each pulse: choose integration start and window
%-------------------------------------------------------------------------
% A single pulse is too noisy to decide integration window
% We compute the average puse where noise cancels out

% 2a. emove each pulse's baseline offset (flat part before the pulse)
nBase = 15;                                         % first 15 samples = 0 to 0.11 us
baseline  = mean(radPulses(:,1:nBase), 2);          % one offset per pulse
radPulses = radPulses - repmat(baseline, 1, nSamples);

% 2b. Mean pulse and light smoothing
meanPulses = mean(radPulses, 1);                    % average over all 36817 pulses
b = ones(1,3)/3;  a = 1;
meanPulsesSmooth = filter(b, a, meanPulses);        % moving average of 3 samples

% 2c. Find start and end using the slope (derivative)
difPulses = diff(meanPulsesSmooth);                 % slope between neighbouring samples
thrMax = 0.10*max(difPulses);                       % "the signal is rising fast"
thrMin = 0.05*min(difPulses);                       % "the decay has almost flattened" (negative)

tIndexMax = find(difPulses > thrMax, 1, 'first');   % START: first sample where it rises
[~, iFast] = min(difPulses);                        % point of fastest decay
iEnd = find(difPulses(iFast:end) > thrMin, 1, 'first');
tIndexMin = iFast + iEnd - 1;                       % END: decay is almost flat again

fprintf('Window: samples %d to %d (%.3f to %.3f us)\n', ...
        tIndexMax, tIndexMin, t(tIndexMax), t(tIndexMin));

% 2d. Plot the mean pulse and the limits
figure(3); clf
plot(t, meanPulsesSmooth, 'LineWidth', 1.5); hold on
yTop = max(meanPulses)*1.01;
line([t(tIndexMax) t(tIndexMax)], [-500 yTop], 'Color','r');
line([t(tIndexMin) t(tIndexMin)], [-500 yTop], 'Color','r');
xlabel('Time (\mus)'); ylabel('Voltage (au)'); title('Mean pulse and integration limits')

%-------------------------------------------------------------------------
%% 3. Integrate each pulse and bin the data in the histogram
%-------------------------------------------------------------------------
% we use the same window for all 36817 pulses and sum each one
% it will give one number per pulse
%count how many pulses fall into each size bucket (bin)

% 3a. Integrate every pulse over the window
radInts = trapz(radPulses(:, tIndexMax:tIndexMin), 2);   % 36817 x 1: one number per pulse

% 3b. Quick histogram with MATLAB's own function
figure(4); clf
plot(hist(radInts, 512));
xlabel('Bucket'); ylabel('Counts'); title('Spectrum (hist)')

% 3c. The same histogram built by hand
histSize = 512;
radIntsScaled = round((radInts-min(radInts))/(max(radInts)-min(radInts))*(histSize-1)) + 1;
radHist = zeros(1, histSize);
for i = 1:length(radIntsScaled)
    radHist(radIntsScaled(i)) = radHist(radIntsScaled(i)) + 1;   % add 1 to that bucket
end

figure(5); clf
plot(radHist);
xlabel('Channel number'); ylabel('Counts'); title('Spectrum')

%-------------------------------------------------------------------------
%% 4. Accumulate many pulses and get an energy spectrum
%-------------------------------------------------------------------------

figure(6); clf
nList = [100 1000 10000 numel(radInts)];
edges = linspace(min(radInts), max(radInts), 513);
for k = 1:4
    subplot(2,2,k)
    c = histcounts(radInts(1:nList(k)), edges);     % use only the first n pulses
    plot(c);
    title(sprintf('%d pulses', nList(k)));
    xlabel('Channel'); ylabel('Counts')
end

