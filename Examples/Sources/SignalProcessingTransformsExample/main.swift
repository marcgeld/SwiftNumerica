import SwiftNumerica

// Fast Fourier transform:
// https://en.wikipedia.org/wiki/Fast_Fourier_transform
//
// This example transforms a cosine-like waveform from the time domain into the
// frequency domain, then uses related signal processing utilities.

let samples = Tensor.vector([1, 0, -1, 0])
let signal = Signal(samples: samples, sampleRate: 4)!

let spectrum = Numerica.SignalProcessing.fft(samples)!
let reconstructed = Numerica.SignalProcessing.inverseFFT(spectrum)!
let periodogram = Numerica.SignalProcessing.periodogram(samples)!
let magnitudes = Numerica.SignalProcessing.magnitudeSpectrum(samples)!
let phases = Numerica.SignalProcessing.phaseSpectrum(samples)!
let smoothed = signal.movingAverage(windowSize: 3)!
let detrended = signal.detrended()!
let normalized = signal.normalized()!
let crossings = Numerica.SignalProcessing.zeroCrossingRate(Tensor.vector([-1, 1, -1, 1]))!
let peaks = signal.peaks()
let valueStyleFFTMagnitudes = samples.fft()?.values.map(\.magnitude)

print("Input samples (expected cosine-like [1, 0, -1, 0]): \(signal.values)")
print("FFT spectrum (expected energy at bins 1 and 3 with magnitude 2): \(spectrum.values.map { ($0.real, $0.imaginary) })")
print("Reconstructed samples (expected approximately [1, 0, -1, 0]): \(reconstructed.values)")
print("Periodogram (expected approximately [0, 1, 0, 1]): \(periodogram.values)")
print("Magnitude spectrum (expected approximately [0, 2, 0, 2]): \(magnitudes.values)")
print("Phase spectrum (expected deterministic phase values): \(phases.values)")
print("Moving average (expected [0.5, 0, -0.333..., -0.5]): \(smoothed.values)")
print("Detrended (expected linearly detrended signal): \(detrended.values)")
print("Normalized (expected z-scored signal): \(normalized.values)")
print("Zero crossing rate (expected 1): \(crossings)")
print("Peaks (expected [] for this sample): \(peaks)")
print("Tensor value-style FFT magnitudes (expected same as magnitude spectrum): \(valueStyleFFTMagnitudes ?? [])")
