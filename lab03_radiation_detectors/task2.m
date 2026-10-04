%-------------------------------------------------------------------------
%% 1. Load Integrals from Task 1 
%-------------------------------------------------------------------------
clearvars; close all
load('task1_results.mat');       % brings back radInts: one integral per pulse (36817x1)

%-------------------------------------------------------------------------
%% 2. Example of quick  histogram
%-------------------------------------------------------------------------
nBins = 512;
[histVals, centers] = hist(radInts, nBins);   % histVals = counts per bin, centers = middle of each bin

%the two-peak shape described above, but with the horizontal axis in "integral units" 
%(big numbers like 5000 or 30000), which mean nothing yet.
figure(1); clf
plot(centers, histVals)
xlabel('Integral of the pulse (au)'); ylabel('Counts')
title('Histogram of the integrals')

%-------------------------------------------------------------------------
%% 3. Use channel number as the horizontal axis
%-------------------------------------------------------------------------

channels = 1:nBins;
figure(2); clf
plot(channels, histVals)
xlabel('Channel number'); ylabel('Counts')
title('Spectrum in channels')

%-------------------------------------------------------------------------
%% 4. Find 2 photo peaks
%-------------------------------------------------------------------------


smoothVals = conv(histVals, ones(1,5)/5, 'same');   % smooth over 5 channels (only to find peaks)

figure(3); clf
plot(channels, smoothVals, 'LineWidth', 1.5)
xlabel('Channel number'); ylabel('Counts')
title('Click the 511 keV peak FIRST, then the 1274.5 keV peak')
[xClick, ~] = ginput(2);          % click twice on the plot
xClick = sort(round(xClick));

pkCh = zeros(1,2);
for k = 1:2
    c  = min(max(xClick(k), 1), nBins);          % keep the click inside the plot
    lo = max(1, c-8);  hi = min(nBins, c+8);     % search +-8 channels around the click
    [~, im] = max(smoothVals(lo:hi));            % highest point there = peak top
    pkCh(k) = lo + im(1) - 1;
end
fprintf('Peak 1: channel %d | Peak 2: channel %d\n', pkCh(1), pkCh(2));

%-------------------------------------------------------------------------
%% 5. Linear Calibration
%-------------------------------------------------------------------------
Eref = [511 1274.5];              % known energies of the two peaks (keV)
p = polyfit(pkCh, Eref, 1);       % straight line: E = p(1)*channel + p(2)
keV = polyval(p, channels);       % energy of every channel
fprintf('E(keV) = %.3f * channel + %.2f\n', p(1), p(2));


Ec = 2*Eref.^2 ./ (511 + 2*Eref);        % Compton edges: about 341 and 1062 keV
fprintf('Expected Compton edges: %.0f and %.0f keV (appendix: 340+-30, 1068+-45)\n', Ec(1), Ec(2));


%-------------------------------------------------------------------------
%% 6. plot in keV and check
%-------------------------------------------------------------------------
figure(4); clf
plot(keV, histVals, 'LineWidth', 1.5); hold on
yl = ylim;
for e = Eref, line([e e], yl, 'Color','r','LineStyle','--'); end        % photopeaks
for e = Ec,   line([e e], yl, 'Color',[0 0.6 0],'LineStyle',':'); end    % Compton edges
xlabel('Energy (keV)'); ylabel('Counts')
title('{}^{22}Na spectrum (calibrated)')