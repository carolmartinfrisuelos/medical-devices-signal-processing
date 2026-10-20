# Remove baseline wandering (FIR high-pass)  (Section 03)

import matplotlib.pyplot as plt
from scipy import signal
from scipy.datasets import electrocardiogram

import numpy as np
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
# FIR LINEAR-PHASE HIGH-PASS FILTER
# ---------------------------------------------------------------
# Baseline drift is very slow (below about 0.5 Hz) and the ECG's useful
# content is faster. A high-pass filter blocks the slow part and keeps the beats.

numtaps = 501   # filter length (must be odd)
cutoff = 0.5    # cutoff frequency in Hz

# pass_zero=False -> high-pass; True -> low-pass.
# Since we pass fs, the cutoff can be given directly in Hz
# (otherwise it would be normalized by the Nyquist frequency, fs/2).
taps = signal.firwin(numtaps, cutoff, pass_zero=False, fs=fs)

# filtfilt filters forward and backward -> zero phase (beats are not shifted).
# A FIR filter has no feedback part, so the denominator is 1.0.
ecg_baseline_removed = signal.filtfilt(taps, 1.0, ecg)

# ---------------------------------------------------------------
# PLOT: ORIGINAL VS BASELINE REMOVED
# ---------------------------------------------------------------
t_init = 0
t_end = 2
plt.figure(figsize=(12, 5))
plt.plot(time, ecg, label='Original')
plt.plot(time, ecg_baseline_removed, label='Baseline wandering removed')
plt.title("Baseline wandering removal (FIR high-pass)")
plt.legend()
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(t_init, t_end)
plt.ylim(-1, 2)
plt.show()