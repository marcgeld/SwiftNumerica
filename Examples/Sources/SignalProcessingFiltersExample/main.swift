import SwiftNumerica

// Digital filter:
// https://en.wikipedia.org/wiki/Digital_filter
//
// This example applies FIR low/high/band-pass/band-stop filters plus a direct
// form biquad filter to a short deterministic signal.

let signal = Tensor.vector([0, 1, 0, -1, 0, 1, 0])
let lowPass = Numerica.SignalProcessing.lowPassFilter(signal, cutoffFrequency: 1, sampleRate: 10, filterLength: 5)!
let highPass = Numerica.SignalProcessing.highPassFilter(signal, cutoffFrequency: 1, sampleRate: 10, filterLength: 5)!
let bandPass = Numerica.SignalProcessing.bandPassFilter(signal, lowCutoffFrequency: 1, highCutoffFrequency: 2, sampleRate: 10, filterLength: 5)!
let bandStop = Numerica.SignalProcessing.bandStopFilter(signal, lowCutoffFrequency: 1, highCutoffFrequency: 2, sampleRate: 10, filterLength: 5)!
let biquad = BiquadFilter(b0: 1, b1: 0, b2: 0, a1: 0, a2: 0)!
let biquadOutput = Numerica.SignalProcessing.apply(biquad, to: signal)!

print("Input:", signal.values)
print("Low-pass:", lowPass.values)
print("High-pass:", highPass.values)
print("Band-pass:", bandPass.values)
print("Band-stop:", bandStop.values)
print("Biquad identity:", biquadOutput.values)
print("Biquad value-style:", biquad.applied(to: signal)?.values ?? [])

