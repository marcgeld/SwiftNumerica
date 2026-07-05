import SwiftNumerica

// Quantile:
// https://en.wikipedia.org/wiki/Quantile
//
// This example shows quantile, percentile, and interquartile range APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

print("Data:", data.values)
print("First quartile:", Numerica.Statistics.quantile(data, probability: 0.25) ?? .nan)
print("Median percentile:", Numerica.Statistics.percentile(data, percentile: 50) ?? .nan)
print("95th percentile:", data.percentile(95) ?? .nan)
print("Interquartile range:", Numerica.Statistics.interquartileRange(data) ?? .nan)
print("Value-style interquartile range:", data.interquartileRange() ?? .nan)
