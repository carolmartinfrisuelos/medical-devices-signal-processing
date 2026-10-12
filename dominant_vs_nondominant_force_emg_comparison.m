%% dominant_vs_nondominant.m
% Compares dominant vs. non-dominant hand recordings (35s each).
% Produces one figure: Force (top) and EMG (bottom), both hands
% overlaid on the same time axis in each panel for direct comparison.

Fs = 1000;
slope = 175.416; intercept = -19.296;

% Confirmed structure within EACH 30s file:
% 0-15s: 50% grip | 15-25s: rest | 25-30s: max grip
segBounds = [15, 25];

%% ---- Load dominant hand recording ----
loadedD   = load('manodominante-carol-datos.mat');        % <-- change to your actual filename
varNamesD = fieldnames(loadedD);
rawD      = loadedD.(varNamesD{1});

if istable(rawD)
    tD      = rawD.TimeStamps;
    forceVD = rawD.ai0;
    emgVD   = rawD.ai1;
elseif isnumeric(rawD)
    tD      = rawD(:,1);
    forceVD = rawD(:,2);
    emgVD   = rawD(:,3);
else
    error('Unrecognized variable type: %s.', class(rawD));
end

forceND       = slope .* forceVD + intercept;
emgCorrectedD = emgVD - 1;

%% ---- Load non-dominant hand recording ----
loadedN   = load('datos-carol-nodominante.mat');     % <-- change to your actual filename
varNamesN = fieldnames(loadedN);
rawN      = loadedN.(varNamesN{1});

if istable(rawN)
    tN      = rawN.TimeStamps;
    forceVN = rawN.ai0;
    emgVN   = rawN.ai1;
elseif isnumeric(rawN)
    tN      = rawN(:,1);
    forceVN = rawN(:,2);
    emgVN   = rawN(:,3);
else
    error('Unrecognized variable type: %s.', class(rawN));
end

forceNN       = slope .* forceVN + intercept;
emgCorrectedN = emgVN - 1;

%% ---- Print summary stats per phase, both hands ----
idx50D = tD >= 0  & tD < 15;   idxMaxD = tD >= 25 & tD <= 30;
idx50N = tN >= 0  & tN < 15;   idxMaxN = tN >= 25 & tN <= 30;

fprintf('--- Dominant ---\n');
fprintf('50%% grip  (0-15s): Max Force = %.2f N | Mean EMG = %.4f V\n', ...
    max(forceND(idx50D)), mean(abs(emgCorrectedD(idx50D))));
fprintf('Max grip (25-30s): Max Force = %.2f N | Mean EMG = %.4f V\n', ...
    max(forceND(idxMaxD)), mean(abs(emgCorrectedD(idxMaxD))));

fprintf('\n--- Non-dominant ---\n');
fprintf('50%% grip  (0-15s): Max Force = %.2f N | Mean EMG = %.4f V\n', ...
    max(forceNN(idx50N)), mean(abs(emgCorrectedN(idx50N))));
fprintf('Max grip (25-30s): Max Force = %.2f N | Mean EMG = %.4f V\n', ...
    max(forceNN(idxMaxN)), mean(abs(emgCorrectedN(idxMaxN))));

%% ---- Plot: Force (top) and EMG (bottom), both hands overlaid ----
figure('Name','Dominant vs Non-Dominant Hand');

% Shared EMG y-axis limits, so the two side-by-side panels below are
% actually comparable instead of each auto-scaling to its own range
emgMin = min([emgCorrectedD; emgCorrectedN]);
emgMax = max([emgCorrectedD; emgCorrectedN]);

subplot(2,2,[1 2])                       % Force: full width, both hands overlaid
plot(tD, forceND, 'b', 'DisplayName','Dominant'); hold on
plot(tN, forceNN, 'r', 'DisplayName','Non-dominant');
for b = segBounds
    xline(b, '--k', 'HandleVisibility','off');
end
xlabel('Time (s)'); ylabel('Force (N)')
title('Force vs. Time - Dominant vs. Non-dominant')
legend('show','Location','best')
grid on

subplot(2,2,3)                           % EMG: dominant, left half
plot(tD, emgCorrectedD, 'Color',[0 0.2 0.8]); hold on
for b = segBounds
    xline(b, '--k');
end
ylim([emgMin emgMax])
xlabel('Time (s)'); ylabel('EMG (V)')
title('EMG - Dominant')
grid on

subplot(2,2,4)                           % EMG: non-dominant, right half
plot(tN, emgCorrectedN, 'Color',[0.85 0.33 0.10]); hold on
for b = segBounds
    xline(b, '--k');
end
ylim([emgMin emgMax])
xlabel('Time (s)'); ylabel('EMG (V)')
title('EMG - Non-dominant')
grid on
