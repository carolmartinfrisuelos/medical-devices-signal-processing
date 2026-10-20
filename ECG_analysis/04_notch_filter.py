#  Notch filter for power line noise  

import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.signal import welch
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
# POWER SPECTRUM OF THE ORIGINAL ECG
# ---------------------------------------------------------------
f, Pxx = welch(ecg, fs=fs, nperseg=2048, scaling="spectrum")

plt.figure(figsize=(8, 5))
plt.semilogy(f, Pxx)
plt.title("Power spectrum of the original ECG")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power spectrum of the ECG $(mV^2)$")
plt.xlim(f[[0, -1]])
plt.show()

# ---------------------------------------------------------------
# DESIGN THE NOTCH FILTER AND PLOT ITS FREQUENCY RESPONSE
# ---------------------------------------------------------------
f0 = 60   # Frequency to be removed from signal (Hz)
Q = 30    # Quality factor
# Design notch filter
b, a = signal.iirnotch(f0, Q, fs)

# Frequency response
freq, h = signal.freqz(b, a, fs=fs)

# Plot
fig, ax = plt.subplots(2, 1, figsize=(8, 6))
ax[0].plot(freq, 20*np.log10(abs(h)), color='blue')
ax[0].set_title("Frequency Response")
ax[0].set_ylabel("Amplitude (dB)", color='blue')
ax[0].set_xlim([0, 100])
ax[0].set_ylim([-25, 10])
ax[0].grid(True)
ax[1].plot(freq, np.unwrap(np.angle(h))*180/np.pi, color='green')
ax[1].set_ylabel("Angle (degrees)", color='green')
ax[1].set_xlabel("Frequency (Hz)")
ax[1].set_xlim([0, 100])
ax[1].set_yticks([-90, -60, -30, 0, 30, 60, 90])
ax[1].set_ylim([-90, 90])
ax[1].grid(True)
plt.show()

# ---------------------------------------------------------------
# APPLY THE NOTCH FILTER
# ---------------------------------------------------------------
# filtfilt filters forward and backward: the R peaks stay at the same time and
# the 60 Hz attenuation is applied twice.
ecg_notch = signal.filtfilt(b, a, ecg)

# ---------------------------------------------------------------
# POWER SPECTRUM OF THE FILTERED ECG
# ---------------------------------------------------------------
f, Pxx = welch(ecg_notch, fs=fs, nperseg=4096)
plt.figure(figsize=(8, 5))
plt.semilogy(f, Pxx)
plt.title("Power spectrum of the ECG after the notch filter")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power spectrum of the ECG $(mV^2)$")
plt.xlim(f[[0, -1]])
plt.show()

