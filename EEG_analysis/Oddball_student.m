%% Oddball. event-related potential (ERP) 
clearvars; close all;clc
load Oddball.mat
fs = ; % Sampling frequency
t_wd = ; % ms epoch Time window
N_wd = ; % number of samples at each epoch

% Rare stimulus is number 2, Common is number 1
idx_stim2 = round(stimtimes (stims==2)*fs); % Indices of rare stimulus
idx_stim1 = round(stimtimes (stims==1)*fs); % Indices of common stimulus

% Load in a matrix the epochs of the rare stimulus 
ERP = zeros(...,...); % Initialize the matrix
for  ii = 1:length(...)
   ERP(ii,:) = eeg(...); 
   end  

% Make the average
ERP_mean = mean(...);
    
% Plot it

