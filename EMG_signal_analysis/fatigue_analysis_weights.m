%% part2_fatigue_analysis.m
% Part 2a: Fatigue vs. Grip Level (20% / 40% / 60% / 80%)
% Part 2b: Sustained 90-degree weight holds (small weight vs. 8 kg)
% (Dominant vs. non-dominant section intentionally NOT included)

Fs = 1000;   % sampling rate (Hz), used throughout

%% =====================================================================
%% PART 2a - Fatigue vs. Grip Level
%% =====================================================================

%% Step 0: Load the 110s recording (grip force + EMG both recorded)
load('parte-2a-datos-sandra.mat')        % <-- change to your actual Part 2a filename
t      = data(:,1);  % numeric seconds
forceV = data(:,2);         % dynamometer (Volts)
emgV   = data(:,3);         % EMG (Volts)

%% Step 1: Calibrate force, correct EMG offset (same as Part 1)
slope = 175.416; intercept = -19.296;
forceN = slope .* forceV + intercept;
emgCorrected = emgV - 1;

%% Step 2: Rectify + envelope (same "linear envelope" method as before)
emgRect     = abs(emgCorrected);
emgEnvelope = movmean(emgRect, round(0.25*Fs));

%% Step 3: Split the recording using the protocol's own time windows
% From the script: 20%(0-20s) rest(20-30s) 40%(30-50s) rest(50-60s)
%                  60%(60-80s) rest(80-90s) 80%(90-110s)
levels    = {'20%','40%','60%','80%'};
gripStart = [0,  30, 60, 90];
gripEnd   = [20, 50, 80, 110];

fprintf('--- PART 2a: Table 2 values ---\n');
maxForcePerLevel = zeros(1,4);
meanEMGPerLevel  = zeros(1,4);
for i = 1:4
    idx = t >= gripStart(i) & t < gripEnd(i);
    maxForcePerLevel(i) = max(forceN(idx));
    meanEMGPerLevel(i)  = mean(emgEnvelope(idx));
    fprintf('%s grip -> Max Force = %.2f N | Mean EMG envelope = %.4f V\n', ...
        levels{i}, maxForcePerLevel(i), meanEMGPerLevel(i));
end
% maxForcePerLevel now holds your 4 numbers for Table 2, in order 20/40/60/80%.

%% Step 4: Plot with the segment boundaries marked
% (lets you SEE whether force/EMG stayed flat or decayed within each
% 20s window - this is what answers "were you able to maintain X%?")
figure('Name','Part 2a - Fatigue vs Grip Level');

subplot(2,1,1)
plot(t, forceN, 'b'); hold on
for i = 1:4
    xline(gripStart(i), '--k'); xline(gripEnd(i), '--k');
end
xlabel('Time (s)'); ylabel('Force (N)')
title('Force vs. Time - 20/40/60/80% grip levels')
grid on

subplot(2,1,2)
plot(t, emgEnvelope, 'Color',[0.85 0.33 0.10]); hold on
for i = 1:4
    xline(gripStart(i), '--k'); xline(gripEnd(i), '--k');
end
xlabel('Time (s)'); ylabel('EMG envelope (V)')
title('EMG envelope - 20/40/60/80% grip levels')
grid on

%% =====================================================================
%% PART 2b - Sustained Weight Holds (EMG only, no force channel)
%% =====================================================================
% Change these two filenames to whatever you saved each 140s recording as.
weightFiles = {'part(2b)peso-mini-datos-sandra.mat', 'datos-parte-2b-peso-masivo-sandra.mat'};
weightNames = {'Small weight', 'Large weight (8 kg)'};

% Nominal hold/rest schedule from the script (140s total):
% Hold1(0-40s) rest(40-50s) Hold2(50-90s) rest(90-100s) Hold3(100-140s)
holdStart = [0,  50, 100];
holdEnd   = [40, 90, 140];

for w = 1:2
    load(weightFiles{w})        % loads "data" (only TimeStamps + ai1 here)
    t2   = data(:,1);
    emgV2 = data(:,3);           % only EMG was recorded in Part 2b

    emgCorrected2 = emgV2 - 1;
    emgRect2      = abs(emgCorrected2);
    emgEnvelope2  = movmean(emgRect2, round(0.25*Fs));

    fprintf('\n--- PART 2b: %s ---\n', weightNames{w});
    meanEnvPerHold = zeros(1,3);
    for h = 1:3
        idx = t2 >= holdStart(h) & t2 < holdEnd(h);
        meanEnvPerHold(h) = mean(emgEnvelope2(idx));
        fprintf('Hold %d (%ds-%ds): mean EMG envelope = %.4f V\n', ...
            h, holdStart(h), holdEnd(h), meanEnvPerHold(h));
    end
    % Rising values Hold1 -> Hold2 -> Hold3 = classic sign of fatigue
    % (more motor units recruited over time to sustain the same weight).

    figure('Name', ['Part 2b - ' weightNames{w}]);
    plot(t2, emgEnvelope2, 'Color',[0.85 0.33 0.10]); hold on
    for h = 1:3
        xline(holdStart(h), '--k'); xline(holdEnd(h), '--k');
    end
    xlabel('Time (s)'); ylabel('EMG envelope (V)')
    title(['EMG envelope - ' weightNames{w}])
    grid on
end
