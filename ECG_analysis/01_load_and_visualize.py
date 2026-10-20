# =====================================================================
# Practice 1: ECG filtering, part 1
# Course: Medical instrumentation and devices (UC3M)
# FILE 1 of 5: Load and visualize the ECG data  (Section 01)
# =====================================================================

# ---------------------------------------------------------------
# 00 - LIBRARIES
# ---------------------------------------------------------------
import numpy as np
import os
import pandas as pd
import matplotlib.pyplot as plt

# ---------------------------------------------------------------
# 01 - LOAD ECG DATA
# ---------------------------------------------------------------

from scipy.datasets import electrocardiogram

ecg = electrocardiogram()  # NumPy array of shape (N,), N = number of samples
fs = 360                   # Hz : sampling frequency of the ECG signal

# ---------------------------------------------------------------
# SHAPE AND DURATION
# ---------------------------------------------------------------
L = ecg.shape[0]           # number of samples (the array has only one dimension)
L_seconds = L / fs         # duration in seconds (samples / samples-per-second)
aux_print = 'ECG shape: ' + str(ecg.shape)
print(aux_print)
aux_print = 'ECG duration: ' + str(L_seconds) + ' seconds'
print(aux_print)

# ---------------------------------------------------------------
# PLOT 1: FIRST 10 SECONDS
# ---------------------------------------------------------------
t_init = 0
t_end = 10
time = np.arange(L) / fs   # time vector in seconds (sample indices / fs)
plt.figure(figsize=(12, 4))
plt.title("ECG Signal (First 10 seconds)")
plt.plot(time, ecg)
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(t_init, t_end)
plt.ylim(-1.2, 2.2)
plt.show()


# ---------------------------------------------------------------
# PLOT 2: FIRST 0.5 SECONDS
# ---------------------------------------------------------------
t_init = 0
t_end = 0.5
time = np.arange(L) / fs
plt.figure(figsize=(12, 4))
plt.title("ECG, first 0.5 seconds")
plt.plot(time, ecg)
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(t_init, t_end)
plt.ylim(-1, 2)
plt.show()

# ---------------------------------------------------------------
# PLOT 3: BETWEEN 207 AND 215 SECONDS
# ---------------------------------------------------------------
t_init = 207
t_end = 215
time = np.arange(L) / fs
plt.figure(figsize=(12, 4))
plt.title("ECG between 207 s and 215 s")
plt.plot(time, ecg)
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(t_init, t_end)
plt.ylim(-2, 3.5)
plt.show()
