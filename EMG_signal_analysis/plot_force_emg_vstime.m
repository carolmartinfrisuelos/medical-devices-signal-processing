%% 1. Load the data
load('parte1-workspace-sandra.mat') 

t      = data.TimeStamps;   % seconds
forceV = data.ai0;          % raw dynamometer output (Volts)
emgV   = data.ai1;          % raw EMG output (Volts)

%% 2. Calibrate the dynamometer channel (V -> N) 
% From the lab script:Force (N) = 175.416 * V - 19.296
slope     = 175.416;
intercept = -19.296;
forceN = slope .* forceV + intercept;

%% 3. Correct the EMG channel's internal offset 
% The EMG sensor has a internal +1 V offset.
% We substract it so signal is centered.
emgCorrected = emgV - 1;

%% 4. Plot signals as subplots
figure('Name','Muscle Fatigue Lab');

subplot(2,1,1)                      
plot(t, forceN, 'b')
xlabel('Time (s)')
ylabel('Force (N)')
title('Force vs. Time')
grid on

subplot(2,1,2)                     
plot(t, emgCorrected, 'Color', [0.85 0.33 0.10])   
xlabel('Time (s)')
ylabel('EMG (V)')
title('EMG vs. Time')
grid on