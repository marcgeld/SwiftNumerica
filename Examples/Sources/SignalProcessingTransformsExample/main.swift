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

print("Input samples:", signal.values)
print("FFT spectrum:", spectrum.values.map { ($0.real, $0.imaginary) })
print("Reconstructed samples:", reconstructed.values)
print("Periodogram:", periodogram.values)
print("Magnitude spectrum:", magnitudes.values)
print("Phase spectrum:", phases.values)
print("Moving average:", smoothed.values)
print("Detrended:", detrended.values)
print("Normalized:", normalized.values)
print("Zero crossing rate:", crossings)
print("Peaks:", peaks)
print("Tensor value-style FFT:", samples.fft()?.values.map(\.magnitude) ?? [])

