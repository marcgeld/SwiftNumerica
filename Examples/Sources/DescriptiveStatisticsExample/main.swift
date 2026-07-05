import SwiftNumerica

// Descriptive statistics:
// https://en.wikipedia.org/wiki/Descriptive_statistics
//
// This example summarizes one tensor using the core descriptive statistics API.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])
let sum = Numerica.Statistics.sum(data)
let min = Numerica.Statistics.min(data)
let max = Numerica.Statistics.max(data)
let range = Numerica.Statistics.range(data)
let mean = Numerica.Statistics.mean(data)
let median = Numerica.Statistics.median(data)
let mode = Numerica.Statistics.mode(data)
let populationVariance = Numerica.Statistics.populationVariance(data)
let sampleVariance = Numerica.Statistics.sampleVariance(data)
let varianceAlias = Numerica.Statistics.variance(data)
let populationStandardDeviation = Numerica.Statistics.populationStandardDeviation(data)
let sampleStandardDeviation = Numerica.Statistics.sampleStandardDeviation(data)
let standardDeviationAlias = Numerica.Statistics.standardDeviation(data)
let firstQuartile = Numerica.Statistics.quantile(data, probability: 0.25)
let percentile95 = Numerica.Statistics.percentile(data, percentile: 95)
let interquartileRange = Numerica.Statistics.interquartileRange(data)
let skewness = Numerica.Statistics.skewness(data)
let kurtosis = Numerica.Statistics.kurtosis(data)
let zScore = Numerica.Statistics.zScore(
    value: 9,
    mean: data.mean() ?? 0,
    standardDeviation: data.populationStandardDeviation() ?? 1
)
let valueStyleMean = data.mean()
let valueStylePercentile = data.percentile(95)

print("Data (expected eight values): \(data.values)")
print("Sum (expected 40): \(sum ?? .nan)")
print("Min (expected 2): \(min ?? .nan)")
print("Max (expected 9): \(max ?? .nan)")
print("Range (expected 9 - 2 = 7): \(range ?? .nan)")
print("Mean (expected 40 / 8 = 5): \(mean ?? .nan)")
print("Median (expected average of middle values 4 and 5 = 4.5): \(median ?? .nan)")
print("Mode (expected [4]): \(mode)")
print("Population variance (expected 4): \(populationVariance ?? .nan)")
print("Sample variance (expected 4.571428571428571): \(sampleVariance ?? .nan)")
print("Variance alias (expected sample variance = 4.571428571428571): \(varianceAlias ?? .nan)")
print("Population standard deviation (expected 2): \(populationStandardDeviation ?? .nan)")
print("Sample standard deviation (expected 2.138089935299395): \(sampleStandardDeviation ?? .nan)")
print("Standard deviation alias (expected sample standard deviation = 2.138089935299395): \(standardDeviationAlias ?? .nan)")
print("Quantile 0.25 (expected 4): \(firstQuartile ?? .nan)")
print("Percentile 95 (expected interpolated value 8.299999999999999): \(percentile95 ?? .nan)")
print("Interquartile range (expected 1.5): \(interquartileRange ?? .nan)")
print("Skewness (expected approximately 0.65625): \(skewness ?? .nan)")
print("Excess kurtosis (expected approximately -0.21875): \(kurtosis ?? .nan)")
print("Z-score for 9 (expected (9 - 5) / 2 = 2): \(zScore ?? .nan)")
print("Value-style mean (expected same as namespace mean = 5): \(valueStyleMean ?? .nan)")
print("Value-style percentile (expected same as namespace percentile = 8.299999999999999): \(valueStylePercentile ?? .nan)")
