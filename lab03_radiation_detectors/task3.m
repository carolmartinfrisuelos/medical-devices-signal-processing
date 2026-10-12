%% LAB 3 - TASK 3: what happens with 1/10 of the pulses and with more/fewer bins?
%
% IDEA: a histogram is a COUNTING experiment. Every pulse is an independent random
% event, so the number of counts N in a bin fluctuates by about sqrt(N) (Poisson
% statistics). The relative noise of a bin is therefore 1/sqrt(N):
%   - fewer pulses -> fewer counts per bin -> noisier histogram
%   - more bins    -> narrower bins -> fewer counts per bin -> noisier histogram
%   - fewer bins   -> wider bins -> smoother, but peaks lose detail (resolution)
%
% REQUIREMENT: radiation_alu.mat must be in the current folder.
% If task1_results.mat exists it is used; otherwise the integrals are recomputed here
% with the same method as Task 1 (so this script runs on its own).
clearvars; close all
 
%% 1. GET THE INTEGRALS (one number per pulse)
needCompute = true;
if exist('task1_results.mat', 'file') == 2
    load('task1_results.mat');                       % brings back radInts
    if exist('radInts', 'var'), needCompute = false; end
end
 
if needCompute
    fprintf('task1_results.mat not found: computing the integrals from radiation_alu.mat\n');
    if exist('radiation_alu.mat', 'file') ~= 2
        error('radiation_alu.mat not found. Put it in the current folder (see pwd).');
    end
    load('radiation_alu.mat');                       % radPulses (36817x75) and fs
    [nPulses, nSamples] = size(radPulses);
 
    % 1a. remove the baseline of each pulse (mean of the first 15 samples)
    baseline  = mean(radPulses(:,1:15), 2);
    radPulses = radPulses - repmat(baseline, 1, nSamples);
 
    % 1b. mean pulse, smoothed with a 3-sample moving average
    meanPulses = mean(radPulses, 1);
    meanSmooth = filter(ones(1,3)/3, 1, meanPulses);
 
    % 1c. integration limits from the derivative of the mean pulse
    difP   = diff(meanSmooth);
    thrMax = 0.10*max(difP);                         % rising threshold
    thrMin = 0.05*min(difP);                         % falling threshold (negative)
    tIndexMax = find(difP > thrMax, 1, 'first');     % start of the pulse
    [~, iFast] = min(difP);                          % fastest decay
    iEnd = find(difP(iFast:end) > thrMin, 1, 'first');
    if isempty(iEnd)
        tIndexMin = nSamples;
    else
        tIndexMin = iFast + iEnd - 1;                % end of the pulse
    end
    fprintf('Integration window: samples %d to %d\n', tIndexMax, tIndexMin);
 
    % 1d. integrate every pulse over that window
    radInts = trapz(radPulses(:, tIndexMax:tIndexMin), 2);
end
 
nTot = numel(radInts);                               % total number of pulses
 
% Use ONE common horizontal range for every histogram (set by ALL the pulses).
% If each subset used its own min and max, the plots would not be comparable.
rmin = min(radInts);
rmax = max(radInts);
 
%% 2. CHOOSE A RANDOM 1/10 OF THE PULSES
rng(1);                                              % fixed seed: same choice every run
order = randperm(nTot);                              % pulse numbers in random order
idx10 = order(1:round(nTot/10));                     % first 10% of that random order
radInts10 = radInts(idx10);                          % integrals of those pulses only
fprintf('All pulses: %d | 10%% subset: %d\n', nTot, numel(radInts10));
% Each pulse is integrated independently with the same window, so taking 1/10 of the
% integrals is identical to taking 1/10 of the pulses and integrating them.
 
%% 3. SPECTRUM WITH 512 BINS: ALL PULSES vs 10% OF THE PULSES
nBins   = 512;
edges   = linspace(rmin, rmax, nBins+1);             % boundaries of 512 equal bins
centers = (edges(1:end-1) + edges(2:end))/2;         % middle of each bin
cAll = histcounts(radInts,   edges);                 % counts per bin, all pulses
c10  = histcounts(radInts10, edges);                 % counts per bin, 10% of pulses
% histcounts with fixed edges guarantees both histograms use identical bins.
 
figure(1); clf
ax1 = subplot(2,1,1);
plot(centers, cAll, 'LineWidth', 1.2)
title(sprintf('All pulses (%d), %d bins', nTot, nBins))
ylabel('Counts')
ax2 = subplot(2,1,2);
plot(centers, c10, 'LineWidth', 1.2)
title(sprintf('10%% of the pulses (%d), %d bins', numel(radInts10), nBins))
xlabel('Pulse integral (au)'); ylabel('Counts')
linkaxes([ax1 ax2], 'x')                             % zooming one zooms the other
 
% Overlay: multiply the 10% histogram by 10 so both have the same overall size.
% The peaks coincide (same positions); the 10% curve is just noisier.
figure(2); clf
plot(centers, cAll,   'LineWidth', 1.5); hold on
plot(centers, 10*c10, 'LineWidth', 1.0)
xlabel('Pulse integral (au)'); ylabel('Counts')
title('All pulses vs 10% of the pulses (x10), 512 bins')
legend('All pulses', '10% of pulses (x10)')
 
%% 4. EFFECT OF THE NUMBER OF BINS (top row: all pulses, bottom row: 10%)
binsList = [32 128 512 2048];                        % coarse -> very fine
nB = numel(binsList);
 
figure(3); clf
fprintf('\n bins | bin width |      ALL pulses       |      10%% of pulses\n');
for k = 1:nB
    nb  = binsList(k);
    e   = linspace(rmin, rmax, nb+1);
    ctr = (e(1:end-1) + e(2:end))/2;
    cA  = histcounts(radInts,   e);
    c1  = histcounts(radInts10, e);
 
    subplot(2, nB, k)
    plot(ctr, cA, 'LineWidth', 1); axis tight
    title(sprintf('All, %d bins', nb)); ylabel('Counts')
 
    subplot(2, nB, nB+k)
    plot(ctr, c1, 'LineWidth', 1); axis tight
    title(sprintf('10%%, %d bins', nb)); xlabel('Pulse integral (au)'); ylabel('Counts')
 
    % Tallest bin and the random noise expected there, 1/sqrt(N)
    fprintf('%5d | %9.3g | max %5d (noise %4.1f%%) | max %4d (noise %4.1f%%)\n', ...
        nb, (rmax-rmin)/nb, max(cA), 100/sqrt(max(cA)), max(c1), 100/sqrt(max(c1)));
end
 
%% 5. ACCUMULATING PULSES: 100, 1000, 10000 AND ALL (512 bins)
nList = [100 1000 10000 nTot];
figure(4); clf
for k = 1:4
    subplot(2,2,k)
    sel = radInts(order(1:nList(k)));                % first n pulses of the random order
    plot(centers, histcounts(sel, edges), 'LineWidth', 1); axis tight
    title(sprintf('%d pulses', nList(k)))
    xlabel('Pulse integral (au)'); ylabel('Counts')
end
 
%% 6. NUMERICAL CHECK THAT THE NOISE IS POISSON-LIKE (optional)
% If a bin has N counts in the full histogram, the 10% subset should have about N/10,
% with a random scatter of sqrt(N*0.1*0.9) (picking 10% of N events at random).
% z = (measured - expected)/scatter should therefore have a standard deviation ~ 1.
mask = cAll >= 100;                                  % use only bins with enough counts
if nnz(mask) > 5
    expected = cAll(mask)/10;
    z = (c10(mask) - expected) ./ sqrt(cAll(mask)*0.1*0.9);
    fprintf('\nStd of z over %d bins = %.2f (about 1 means the noise is Poisson-like)\n', ...
        nnz(mask), std(z));
end