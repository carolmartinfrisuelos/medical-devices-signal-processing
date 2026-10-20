
# Remove signal noise with a median filter 
import numpy as np
import os
import pandas as pd
import matplotlib.pyplot as plt

from scipy.datasets import electrocardiogram

# ---------------------------------------------------------------
# DATA (same as file 1)
# ---------------------------------------------------------------
ecg = electrocardiogram()
fs = 360
L = ecg.shape[0]
time = np.arange(L) / fs

# ---------------------------------------------------------------
# MEDIAN FILTER
# ---------------------------------------------------------------
# A median is the middle value of a set of values (sort them and take the one
# in the middle). The window size is the number of values used to calculate it.
def median_filter(data, window_size):
    filtered_data = np.zeros_like(data)  # array of zeros with the same shape as the input

    for i in range(len(data)):
        init = max(0, i - int(window_size/2))
        end = min(i + int(window_size/2), len(data)-1)

        aux_ecg = data[init:end]
        filtered_data[i] = np.median(aux_ecg)  # median of the window -> filtered sample

    return filtered_data

# Apply it with different filter orders (this can take a few seconds)
ecg_filtered_signal_5 = median_filter(ecg, 5)
ecg_filtered_signal_10 = median_filter(ecg, 10)
ecg_filtered_signal_20 = median_filter(ecg, 20)

# ---------------------------------------------------------------
# PLOT: ORIGINAL VS FILTERED
# ---------------------------------------------------------------
t_init = 0
t_end = 1

plt.figure(figsize=(12, 5))
plt.plot(time, ecg, label='Original')
plt.plot(time, ecg_filtered_signal_5, label='Filter order: 5')
plt.plot(time, ecg_filtered_signal_10, label='Filter order: 10')
plt.plot(time, ecg_filtered_signal_20, label='Filter order: 20')
plt.title("Median filter with different orders")
plt.legend()
plt.xlabel("time (s)")
plt.ylabel("ECG (mV)")
plt.xlim(t_init, t_end)
plt.ylim(-1, 2)
plt.show()

