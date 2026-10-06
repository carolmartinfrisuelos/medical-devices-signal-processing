# Radiation Detectors and Signal Processing

**Medical Instrumentation and Devices** · Universidad Carlos III de Madrid

**Carolina Martín** · 02/10/2026

---

## 2. Radiation Pulse Processing

The objective for this laboratory was to analyse the pulses that were obtained using radiation detectors. To achieve this, the data went through the following procedure.

Firstly, we obtained the digitized pulses. In the following image we can observe the first 100 pulses of the data.

![Figure 1. 100 digitized pulses from the detector.](figures/fig01_100_raw_pulses.png)

*Figure 1. 100 digitized pulses from the detector.*

The detector data consists of 36817 digitized pulses with 75 samples each (as we observe in the MATLAB workspace variable `radPulses` → 36817x75 double). These samples were acquired at a sampling frequency of 125 MHz (also part of the data, `fs`), thus 8 ns per sample, so 75 samples per pulse take 0.6 µs.

![Figure 2. Example single pulse #10 in which we can observe the noise.](figures/fig02_pulse10.png)

*Figure 2. Example single pulse #10 in which we can observe the noise.*

Each pulse corresponds to one gamma ray detected by the scintillator (SiPM system). As we can see in Figure 1, all the pulses have the same shape: an initial flat baseline, a fast rise and a slower decay, but they have different heights, since the voltage recorded by the detector depends on the energy of the gamma ray deposited in the crystal. Each individual pulse is noisy (Figure 2), so to proceed with the analysis it is crucial to compute the average of the pulses, in which the noise will cancel because it is random for each pulse. This will allow us to choose the integration limits.

![Figure 3. Average of all pulses to take out the noise and integration limits selected.](figures/fig03_mean_pulse_limits.png)

*Figure 3. Average of all pulses to take out the noise and integration limits selected.*

If we take a close look at the data `radPulses` we observe that the first 25 samples of each pulse probably come from before the gamma ray arrives, because the values of these samples are much smaller than the following values. This is why, before averaging, we subtracted from the whole pulse the mean of its first 15 samples, which we are certain (15 < 25 samples) do not include any information about the gamma ray energy. This improves the noise cancelling of all the pulses in the next step. Next, all 36817 pulses were averaged sample by sample, giving the mean pulse, cancelling random error, and allowing us to select the correct integration window. To smooth the mean pulse a bit more, we computed a 3-sample moving average, in which the output is the average of the sample and the two samples before it.

To find out the correct time at which the pulse starts and ends, the derivative was computed (using the `diff` function), which gives the slope between consecutive samples. This slope will be zero at the beginning (because of the flat line), then large and positive during the rise, and finally large and negative during the decay. With this knowledge, we can precisely choose the moment at which the mean pulse starts rising and the moment at which it has decayed. In MATLAB we used two thresholds: when the slope exceeded 10% of its maximum, the pulse had started to rise; and when the slope had returned to 5% of its most negative value, the pulse had ended. These two sample numbers are the integration limits, drawn as red lines in Figure 3.

![Figure 4. Spectrum of the integrals divided into bins using the hist function.](figures/fig04_spectrum_hist.png)

*Figure 4. Spectrum of the integrals divided into bins using the `hist` function.*

After choosing the integration window, the trapezoidal rule was chosen as the integration method to compute the area beneath each pulse. The basic idea of this rule is to draw a trapezoid under the curve between each pair of neighbouring samples, whose area is the average of the two heights times the width, and then add all the trapezoids. In MATLAB we used `trapz` without a time vector, so results are in "voltage × samples". With the integration window, the samples selected were **samples 25 to 46** (22 samples) of each pulse; across those 22 columns we obtain 21 trapezoids, which are added together, obtaining one total value for each pulse.

It is important to mention that the spacing is the same for every pulse (8 ns), so it acts as a constant, multiplying every integral by the same factor and not changing the shape of the spectrum. In the next step, MATLAB's `hist` splits those integrals into 512 equal buckets and counts how many pulses fall in each of them. In Figure 4 we can see the plot that draws the counts as the spectrum. The histogram was also computed manually, using the procedure proposed in the script, which gives the same spectrum as before. The main idea in the manual computation is to rescale the integrals so that the smallest goes to channel 1 and the largest goes to channel 512, and with a loop add 1 to the counter of the channel in which each integral falls.

![Figure 5. Spectrum of the integrals divided into bins manually.](figures/fig05_spectrum_manual.png)

*Figure 5. Spectrum of the integrals divided into bins manually.*

---

### 2.1. Task 1

**Which method have you employed to compute the integration limits of the pulse? Think of any possible source of error and reason the robustness of your method. What are the sample limits of your integration?**

To compute the integration limits, as explained in the procedure, I computed the average of all 36817 pulses and then used the derivative of that mean pulse. The baseline (mean of the first 15 samples of each pulse) was subtracted first, and then the mean pulse was smoothed with a 3-sample moving average. Two thresholds were chosen and, using the slope, the limits were found: the first is the first sample that exceeded 10% of the maximum slope, and the second is the first sample after the decay at which the slope returns to 5% of its most negative value.

Thanks to computing the mean pulse, most of the noise was averaged out, which defines the limits better. In addition, subtracting the baseline offset reduced the error that grows with the window length. The thresholds used to select the limits from the slope could be modified and may achieve better results, but they lie well above the noise slope and well below the rise slope. Also, a small part of the tail was left out, which can shift the energy scale slightly and decrease the precision; and using one window for all pulses assumes that every pulse starts at the same sample, so if the start varies, some pulses lose area.

The sample limits of my integration were: **samples 25 to 46 (0.192 to 0.360 µs)**.

**Why do you have to integrate at all? Can you explain the relation between the energy of the pulse and the integral? Why is the maximum another valid method? Can you point out any advantages of the integral over the maxima method?**

It is crucial to integrate because each pulse is composed of 75 samples, which are 75 numbers that identify the pulse, and to build a histogram we need one number per pulse that represents the energy of the gamma ray. The integral, which is the area under the pulse, gives us one number that is proportional to this energy.

Moreover, only by counting many pulses does a pattern appear. This pattern allows us to decide which isotope is emitting the gamma rays, since the full-energy events pile up in the same channel and make peaks that act as the isotope's fingerprint.

A gamma ray coming from sodium-22 deposits energy in the scintillator, producing a number of light photons proportional to this energy. The SiPM then converts the detected photons of this visible light into an electrical signal, which we observe as pulses. So the total charge it delivers is proportional to the number of photons, and thus to the gamma ray energy. Finally, the area under each pulse is the total charge of the detected photons, since the voltage is proportional to the current.

$$\text{integral} \propto \text{charge} \propto \text{number of detected photons} \propto \text{energy deposited by the gamma ray}$$

The maximum could be another valid method, since all pulses have the same shape (given by the scintillator decay and the hardware components) and differ by a scale factor, which is proportional to the energy. Thus, a taller pulse indicates a bigger amount of deposited energy. This method selects the sample with the biggest value for each pulse and then makes a histogram out of those values.

One advantage of the integral over the maxima method is that the integral uses all the samples inside the window, averaging the noise out, while the maxima method takes only the highest sample, which includes whatever noise was added to that sample. Also, the true peak of a pulse falls between two samples, and depending on the moment the samples were taken, using just the highest value of one sample may not be accurate. Thus, the integral is also less sensitive to timing and shape.

---

## 3. Build the Histogram

For the next part of the laboratory a histogram was built using the values of the integrals of Task 1. In Figure 6 we observe how the histogram can be built using the `hist` function of MATLAB, but the x-axis is in "integral units", which are voltage times samples, a size that depends on our window and does not mean anything physically.

![Figure 6. Histogram built with the hist function.](figures/fig06_hist_integral_units.png)

*Figure 6. Histogram built with the `hist` function.*

Then, the x-axis was changed from the integral units to the channels, which are the bin numbers, as we can see in Figure 7. Bin 1 starts at the smallest integral and bin 512 ends at the largest, so there is a linear relationship between the channel and the integral. This number of channels was selected because 2⁹ = 512, which is typical of real multichannel analysers, and it was also used in the handout.

![Figure 7. Histogram with x-axis as the channels (number of bins).](figures/fig07_spectrum_channels.png)

*Figure 7. Histogram with x-axis as the channels (number of bins).*

Finally, the two photopeaks were identified using the laboratory script figure. We identify one peak at around 500 keV (theoretically the gamma ray with E = 511 keV) and another peak at around 1250 keV (theoretically 1274.5 keV), as seen in Figure 8. The peaks are located with the red dashed lines, and the continuum of the Compton scattering falls off near the green lines.

![Figure 8. 22Na spectrum using calibration of energy in keV.](figures/fig08_na22_calibrated.png)

*Figure 8. ²²Na spectrum using calibration of energy in keV.*

---

### 3.1. Task 2

**In Appendix 1 you can find the spectrum of the ²²Na. Compare it to Figure 6. The abscissa axis does not display energy but the channel number. What is it? Use the spectrum in Appendix 1 to calibrate and display energy in keV. Use a linear fitting.**

Comparing the histogram obtained to the handout spectrum of ²²Na, we can observe that it is similar. Firstly, on the left we can see in both the continuum produced by Compton scattering, in which a gamma gives part of its energy to an electron and then continues in a new direction. The scattered gamma leaves the crystal, so what is recorded is the energy transferred to the electron. This electron energy depends on the scattering angle. A small angle makes the deposited energy close to 0, and the maximum possible energy for the electron is given by a 180° angle. This maximum is called the Compton edge, and everything between 0 and the maximum is the continuum.

A gamma of energy $E$ scatters off an electron at a certain angle $\theta$. Energy and momentum conservation give the energy of the scattered gamma, $E'$:

$$E' = \frac{E}{1 + \frac{E}{511}\,(1-\cos\theta)}$$

For the maximum transfer, $\theta = 180^\circ$ ($\cos\theta = -1$):

$$E' = \frac{E}{1 + 2E/511}$$

The crystal receives $T = E - E'$, so the maximum energy deposited (the Compton edge) is:

$$T_{max} = \frac{2E^2}{511 + 2E}$$

Here $E$ is the energy of the incident gamma (in keV), and 511 keV is the electron rest energy, calculated with the electron mass in $E = mc^2$ (the positron has the same mass).

For the 511 keV line the edge is 340.7 keV, and for the 1274.5 keV line the edge is 1061.7 keV.

Moreover, we can also observe in both spectra the difference between the 511 keV peak and the 1274.5 keV peak. This height difference is due to the number of events that deposit all their energy in the crystal. This number can vary because of the number of gammas that are emitted: a positron decay produces two 511 keV photons, but only one 1274.5 keV photon per decay. Also, the probability of the photoelectric effect decreases with energy, so the higher the energy, the lower the probability that the photon is fully absorbed. Moreover, peaks are usually wider at higher energies, giving a lower top.

In addition, there is an accumulation of events at low energy because both gamma lines can scatter and leave energy anywhere from 0 up to their Compton edge, which makes the beginning of the spectrum higher than the second gamma peak.

To calibrate the x-axis and display the energy in keV, we used the positions of the two gamma ray peaks as the points for the linear calibration:

- Point 1: (179, 511 keV)
- Point 2: (320, 1274.5 keV)

We assume $E = a \cdot \text{channel} + b$. The slope is

$$a = \frac{1274.5 - 511}{320 - 179} = \frac{763.5}{141} = 5.42\ \text{keV/channel}$$

and the offset is

$$b = 511 - 5.42 \cdot 179 = -459\ \text{keV}$$

We can check with channel 1 (E = −454 keV) and channel 512 (E = 2316 keV), and we see that it matches the axis we obtained.

---

### 3.2. Task 3

**Now try playing around with the histogram, use only 1/10 of the radiation pulses to generate the histogram. What happens?**

As we can see in the following images, the spectrum keeps the same shape and peak positions even when fewer pulses are used for the histogram. Obviously, the counts decrease as the number of pulses used decreases. However, the histogram becomes much noisier, as we can observe in the following figures. For the example proposed, 1/10 of the pulses, each bin contains about ten times fewer counts; and since the number of counts in a bin fluctuates by about $\sqrt{N}$ (Poisson statistics), the relative noise increases by a factor of $\sqrt{10} \approx 3.2$. This way the smaller features become much harder to distinguish, so it is harder to identify the 1274.5 keV photopeak and the Compton edges.

![Figure 9. Comparison of 1/10 of the pulses with the same number of bins.](figures/fig09_all_vs_10pct.png)

*Figure 9. Comparison of 1/10 of the pulses with the same number of bins.*

![Figure 10. Comparison of 1/10 of the pulses magnified to compare the noise.](figures/fig10_overlay.png)

*Figure 10. Comparison of 1/10 of the pulses (multiplied by 10) to compare the noise.*

![Figure 11. Histogram when using different amounts of pulses.](figures/fig11_accumulating.png)

*Figure 11. Histogram when using different numbers of pulses.*

**Try decreasing/increasing the number of bins and see what happens to your histogram.**

We can check in the figure below how more or fewer bins affect the histogram for 10/10 of the pulses or 1/10. With few bins (32), the histogram is smoother because each bin collects many counts, but since the bins are very wide the peaks are blurred and details of the spectrum are lost. If too many bins are used (2048), the horizontal resolution is high, but each bin contains very few counts, so the histogram is spiky and the real structure is hidden by statistical noise. Furthermore, we can see that for the total number of pulses the histogram is clearer with 512 bins, but when only 1/10 of the pulses is used, a histogram with fewer bins (128) looks less noisy.

![Figure 12. Decreasing/increasing the number of bins, comparing 1/10 and 10/10 of the pulses.](figures/fig12_bins.png)

*Figure 12. Decreasing/increasing the number of bins, comparing 1/10 and 10/10 of the pulses.*
