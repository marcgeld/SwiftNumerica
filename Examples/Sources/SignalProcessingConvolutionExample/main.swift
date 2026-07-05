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

print("Signal:", signal.values)
print("Kernel:", kernel.values)
print("Convolution:", convolution.values)
print("Correlation:", correlation.values)
print("Autocorrelation:", autocorrelation.values)
print("Moving average:", movingAverage.values)
print("Rectangular window:", Numerica.SignalProcessing.rectangularWindow(size: 4)?.values ?? [])
print("Hann window:", Numerica.SignalProcessing.hannWindow(size: 4)?.values ?? [])
print("Hamming window:", Numerica.SignalProcessing.hammingWindow(size: 4)?.values ?? [])
print("Blackman window:", Numerica.SignalProcessing.blackmanWindow(size: 4)?.values ?? [])
