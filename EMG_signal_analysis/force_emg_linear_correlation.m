%% force_emg_analysis.m
% Continues from plot_force_emg.m. Adds:
%   - Table 1 stats (max/min/median force)
%   - EMG rectification + envelope
%   - Correlation between EMG envelope and Force (R^2, p-value)
%   - Scatter plot with fitted line

%% 1. Load data + Assign variables
load('parte1-workspace-sandra.mat')    

t      = data.TimeStamps;    % seconds
forceV = data.ai0;           % raw dynamometer output (Volts)
emgV   = data.ai1;           % raw EMG output (Volts)

%% 2. Calibrate force (V -> N) 
slope     = 175.416;
intercept = -19.296;
forceN = slope .* forceV + intercept;

%% 3. Correct EMG offset 
emgCorrected = emgV - 1;  

%% 4. Print: Maximum / Minimum / Median force
maxForce    = max(forceN);
minForce    = min(forceN);
medianForce = median(forceN);

fprintf('Maximum Force: %.2f N\n', maxForce);
fprintf('Minimum Force: %.2f N\n', minForce);
fprintf('Median Force:  %.2f N\n', medianForce);


%% ---- STEP 4: Rectify the EMG signal ----
% Raw EMG swings positive AND negative around 0. Averaging it as-is
% would cancel out to ~0 no matter how hard you squeezed - there's no
% "more" or "less" in a signal that always nets to zero. Taking the
% absolute value makes every sample positive, so more muscle activity
% actually shows up as a bigger number.
emgRect = abs(emgCorrected);

%% ---- STEP 5: Extract the envelope (smooth the rectified signal) ----
% Rectified EMG is still spiky sample-to-sample - that spikiness is
% real, but it's too fast to compare against Force, which changes
% slowly. A moving average over a short window smooths the rectified
% signal into a slower curve that tracks overall contraction
% intensity. THIS envelope, not the raw EMG, is what you correlate
% against force.
Fs = 1000;                          % sampling rate (Hz)
windowSize = round(0.25 * Fs);      % 250 ms averaging window
emgEnvelope = movmean(emgRect, windowSize);

%% ---- STEP 6: Correlate EMG envelope with Force ----
[R, P] = corrcoef(forceN, emgEnvelope);
r  = R(1,2);          % Pearson correlation coefficient (-1 to 1)
pv = P(1,2);           % p-value: probability this correlation is due to chance
R2 = r^2;               % R-squared: how well Force "explains" the EMG envelope

fprintf('Correlation r = %.3f,  R^2 = %.3f,  p = %.3g\n', r, R2, pv);

%% ---- STEP 7: Scatter plot with fitted line ----
coeffs  = polyfit(forceN, emgEnvelope, 1);   % [slope, intercept] of best-fit line
fitLine = polyval(coeffs, forceN);

figure('Name','Force vs EMG correlation');
scatter(forceN, emgEnvelope, 4, 'filled')
hold on
plot(forceN, fitLine, 'r-', 'LineWidth', 2)
xlabel('Force (N)')
ylabel('EMG Envelope Amplitude (V)')
title(sprintf('R^2 = %.3f,  p = %.3g', R2, pv))
legend('Samples','Linear fit','Location','best')
grid on

% Tip: with 60,000 points the scatter can render slowly. To speed it
% up visually (stats above still use ALL the data), plot a subset:
%   idx = 1:10:length(forceN);
%   scatter(forceN(idx), emgEnvelope(idx), 4, 'filled')
