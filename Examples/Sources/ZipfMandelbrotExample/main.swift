import SwiftNumerica

// Zipf-Mandelbrot distribution:
// https://en.wikipedia.org/wiki/Zipf%E2%80%93Mandelbrot_law
//
// This example evaluates a finite rank distribution and shows how its offset
// changes the normalized rank probabilities.

let zipf = Numerica.Probability.ZipfMandelbrotDistribution(numberOfRanks: 3, exponent: 1)!
let shifted = Numerica.Probability.ZipfMandelbrotDistribution(numberOfRanks: 3, exponent: 1, offset: 1)!
let zipfProbabilities = (1...3).map(zipf.pmf)
let shiftedProbabilities = (1...3).map(shifted.pmf)

print("Zipf normalization constant (expected 6 / 11): \(zipf.normalizationConstant)")
print("Zipf rank probabilities (expected [6/11, 3/11, 2/11]): \(zipfProbabilities)")
print("Offset q = 1 normalization constant (expected 12 / 13): \(shifted.normalizationConstant)")
print("Offset q = 1 probabilities (expected [6/13, 4/13, 3/13]): \(shiftedProbabilities)")
print("Offset distribution CDF through rank 2 (expected 10 / 13): \(shifted.cdf(2))")
print("The offset flattens rank probabilities; this models ranks, not Mandelbrot-set numbers.")
