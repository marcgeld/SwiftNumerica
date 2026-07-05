import SwiftNumerica

// Quantile:
// https://en.wikipedia.org/wiki/Quantile
//
// This example shows quantile, percentile, and interquartile range APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])
let firstQuartile = Numerica.Statistics.quantile(data, probability: 0.25)
let medianPercentile = Numerica.Statistics.percentile(data, percentile: 50)
let percentile95 = data.percentile(95)
let interquartileRange = Numerica.Statistics.interquartileRange(data)
let valueStyleInterquartileRange = data.interquartileRange()

print("Data (expected sorted sample with repeated 4s and 5s): \(data.values)")
print("First quartile (expected 25th percentile = 4): \(firstQuartile ?? .nan)")
print("Median percentile (expected 50th percentile = 4.5): \(medianPercentile ?? .nan)")
print("95th percentile (expected interpolated value = 8.299999999999999): \(percentile95 ?? .nan)")
print("Interquartile range (expected Q3 - Q1 = 5.5 - 4 = 1.5): \(interquartileRange ?? .nan)")
print("Value-style interquartile range (expected same value = 1.5): \(valueStyleInterquartileRange ?? .nan)")
