import SwiftNumerica

// Convolution:
// https://en.wikipedia.org/wiki/Convolution
//
// This example applies convolution, correlation, autocorrelation, and common
// window functions to short deterministic signals.

let signal = Tensor.vector([1, 2, 3, 4])
let kernel = Tensor.vector([0.25, 0.5, 0.25])
let convolution = Numerica.SignalProcessing.convolve(signal, with: kernel)!
let correlation = Numerica.SignalProcessing.correlate(signal, with: kernel)!
let autocorrelation = Numerica.SignalProcessing.autocorrelation(signal)!
let movingAverage = Numerica.SignalProcessing.movingAverage(signal, windowSize: 3)!
let rectangularWindow = Numerica.SignalProcessing.rectangularWindow(size: 4)
let hannWindow = Numerica.SignalProcessing.hannWindow(size: 4)
let hammingWindow = Numerica.SignalProcessing.hammingWindow(size: 4)
let blackmanWindow = Numerica.SignalProcessing.blackmanWindow(size: 4)

print("Signal (expected [1, 2, 3, 4]): \(signal.values)")
print("Kernel (expected smoothing kernel [0.25, 0.5, 0.25]): \(kernel.values)")
print("Convolution (expected [0.25, 1, 2, 3, 2.75, 1]): \(convolution.values)")
print("Correlation (expected same as convolution for this symmetric kernel): \(correlation.values)")
print("Autocorrelation (expected [4, 11, 20, 30, 20, 11, 4]): \(autocorrelation.values)")
print("Moving average (expected [1.5, 2, 3, 3.5]): \(movingAverage.values)")
print("Rectangular window (expected four ones): \(rectangularWindow?.values ?? [])")
print("Hann window (expected approximately [0, 0.75, 0.75, 0]): \(hannWindow?.values ?? [])")
print("Hamming window (expected approximately [0.08, 0.77, 0.77, 0.08]): \(hammingWindow?.values ?? [])")
print("Blackman window (expected approximately [0, 0.63, 0.63, 0]): \(blackmanWindow?.values ?? [])")
