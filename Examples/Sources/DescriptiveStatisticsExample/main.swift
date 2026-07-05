import SwiftNumerica

// Descriptive statistics:
// https://en.wikipedia.org/wiki/Descriptive_statistics
//
// This example summarizes one tensor using the core descriptive statistics API.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

print("Data:", data.values)
print("Sum:", Numerica.Statistics.sum(data) ?? .nan)
print("Min:", Numerica.Statistics.min(data) ?? .nan)
print("Max:", Numerica.Statistics.max(data) ?? .nan)
print("Range:", Numerica.Statistics.range(data) ?? .nan)
print("Mean:", Numerica.Statistics.mean(data) ?? .nan)
print("Median:", Numerica.Statistics.median(data) ?? .nan)
print("Mode:", Numerica.Statistics.mode(data))
print("Population variance:", Numerica.Statistics.populationVariance(data) ?? .nan)
print("Sample variance:", Numerica.Statistics.sampleVariance(data) ?? .nan)
print("Variance alias:", Numerica.Statistics.variance(data) ?? .nan)
print("Population standard deviation:", Numerica.Statistics.populationStandardDeviation(data) ?? .nan)
print("Sample standard deviation:", Numerica.Statistics.sampleStandardDeviation(data) ?? .nan)
print("Standard deviation alias:", Numerica.Statistics.standardDeviation(data) ?? .nan)
print("Quantile 0.25:", Numerica.Statistics.quantile(data, probability: 0.25) ?? .nan)
print("Percentile 95:", Numerica.Statistics.percentile(data, percentile: 95) ?? .nan)
print("Interquartile range:", Numerica.Statistics.interquartileRange(data) ?? .nan)
print("Skewness:", Numerica.Statistics.skewness(data) ?? .nan)
print("Excess kurtosis:", Numerica.Statistics.kurtosis(data) ?? .nan)
print("Z-score for 9:", Numerica.Statistics.zScore(value: 9, mean: data.mean() ?? 0, standardDeviation: data.populationStandardDeviation() ?? 1) ?? .nan)
print("Value-style mean:", data.mean() ?? .nan)
print("Value-style percentile:", data.percentile(95) ?? .nan)

