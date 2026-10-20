#Heart rate estimation (Optional)  (Section 05)

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.signal import find_peaks
from scipy.datasets import electrocardiogram
import os
import pandas as pd

# ---------------------------------------------------------------
# DATA (same as file 1)
# ---------------------------------------------------------------
ecg = electrocardiogram()
fs = 360
L = ecg.shape[0]
time = np.arange(L) / fs

# ---------------------------------------------------------------
# PRE-PROCESS: baseline removal (same filter as file 3)
# ---------------------------------------------------------------
taps = signal.firwin(501, 0.5, pass_zero=False, fs=fs)
ecg_baseline_removed = signal.filtfilt(taps, 1.0, ecg)

# ---------------------------------------------------------------
# CALCULATE THE HEART BEAT
# - What do you propose? A method based on peak detection.
# ---------------------------------------------------------------
# PEAK DETECTION
x = ecg_baseline_removed

peaks, _ = find_peaks(x, height=0.6, distance=int(0.25 * fs))

# find_peaks returns the sample positions of the peaks and a dictionary with
# extra info (discarded with _).
# height   -> minimum height (to count just the R peaks)
# distance -> minimum number of samples between peaks (0.25 s = 90 samples)

# ESTIMATE THE HEART BEAT
# CALCULATE DISTANCE BETWEEN PEAKS
peaks_diff = np.diff(peaks)  # each element minus the previous one: samples between R peaks
print(peaks_diff)
mean_rr_interval = np.mean(peaks_diff)  # average samples between two R peaks
mean_rr_interval_seconds = mean_rr_interval / fs
mean_rr_freq_hz = 1 / mean_rr_interval_seconds
heart_beat = mean_rr_freq_hz * 60

aux_print = 'Mean RR interval: ' + str(mean_rr_interval_seconds) + ' seconds.'
print(aux_print)
aux_print = 'Cycles per second: ' + str(mean_rr_freq_hz) + ' Hz.'
print(aux_print)
aux_print = 'Beats per minute: ' + str(heart_beat) + ' bpm.'
print(aux_print)

# ---------------------------------------------------------------
# PLOT OF THE DETECTED PEAKS
# ---------------------------------------------------------------
plt.figure(figsize=(12, 5))
plt.plot(time, x, label='ECG (baseline removed)')
plt.plot(time[peaks], x[peaks], 'rx', markersize=8, label='Detected R peaks')
plt.title("Detected R peaks (first 10 seconds)")
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(0, 10)
plt.legend()
plt.show()

# Whole recording (general view)
plt.figure(figsize=(14, 5))
plt.plot(time, x, label='ECG (baseline removed)')
plt.plot(time[peaks], x[peaks], 'rx', label='Detected R peaks')
plt.title("Detected R peaks in the whole recording (300 s)")
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.legend()
plt.show()
