import SwiftNumerica

// Statistical dispersion:
// https://en.wikipedia.org/wiki/Statistical_dispersion
//
// This example shows range, variance, standard deviation, and z-score APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])
let mean = data.mean()!
let populationStandardDeviation = data.populationStandardDeviation()!
let range = Numerica.Statistics.range(data)
let populationVariance = Numerica.Statistics.populationVariance(data)
let sampleVariance = Numerica.Statistics.sampleVariance(data)
let varianceAlias = Numerica.Statistics.variance(data)
let sampleStandardDeviation = Numerica.Statistics.sampleStandardDeviation(data)
let standardDeviationAlias = Numerica.Statistics.standardDeviation(data)
let zScore = Numerica.Statistics.zScore(value: 9, mean: mean, standardDeviation: populationStandardDeviation)

print("Data (expected eight values): \(data.values)")
print("Range (expected 9 - 2 = 7): \(range ?? .nan)")
print("Population variance (expected sum squared deviations / 8 = 4): \(populationVariance ?? .nan)")
print("Sample variance (expected sum squared deviations / 7 = 4.571428571428571): \(sampleVariance ?? .nan)")
print("Variance alias (expected sample variance = 4.571428571428571): \(varianceAlias ?? .nan)")
print("Population standard deviation (expected sqrt(4) = 2): \(populationStandardDeviation)")
print("Sample standard deviation (expected sqrt(4.571428571428571) = 2.138089935299395): \(sampleStandardDeviation ?? .nan)")
print("Standard deviation alias (expected sample standard deviation = 2.138089935299395): \(standardDeviationAlias ?? .nan)")
print("Z-score for 9 (expected (9 - 5) / 2 = 2): \(zScore ?? .nan)")
