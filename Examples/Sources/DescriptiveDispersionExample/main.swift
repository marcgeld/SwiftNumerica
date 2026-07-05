import SwiftNumerica

// Statistical dispersion:
// https://en.wikipedia.org/wiki/Statistical_dispersion
//
// This example shows range, variance, standard deviation, and z-score APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])
let mean = data.mean()!
let populationStandardDeviation = data.populationStandardDeviation()!

print("Data:", data.values)
print("Range:", Numerica.Statistics.range(data) ?? .nan)
print("Population variance:", Numerica.Statistics.populationVariance(data) ?? .nan)
print("Sample variance:", Numerica.Statistics.sampleVariance(data) ?? .nan)
print("Variance alias:", Numerica.Statistics.variance(data) ?? .nan)
print("Population standard deviation:", populationStandardDeviation)
print("Sample standard deviation:", Numerica.Statistics.sampleStandardDeviation(data) ?? .nan)
print("Standard deviation alias:", Numerica.Statistics.standardDeviation(data) ?? .nan)
print("Z-score for 9:", Numerica.Statistics.zScore(value: 9, mean: mean, standardDeviation: populationStandardDeviation) ?? .nan)
