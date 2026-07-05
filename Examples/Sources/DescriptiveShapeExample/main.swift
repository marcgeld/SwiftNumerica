import SwiftNumerica

// Skewness and kurtosis:
// https://en.wikipedia.org/wiki/Skewness
// https://en.wikipedia.org/wiki/Kurtosis
//
// This example shows distribution-shape summaries for one sample.

let data = Tensor.vector([1, 2, 2, 3, 4, 8, 13])
let skewness = Numerica.Statistics.skewness(data)
let kurtosis = Numerica.Statistics.kurtosis(data)
let valueStyleSkewness = data.skewness()
let valueStyleKurtosis = data.kurtosis()

print("Data (expected right-skewed sample): \(data.values)")
print("Skewness (expected approximately 1.1419277952951876): \(skewness ?? .nan)")
print("Excess kurtosis (expected approximately -0.10357001972386737): \(kurtosis ?? .nan)")
print("Value-style skewness (expected same value): \(valueStyleSkewness ?? .nan)")
print("Value-style kurtosis (expected same value): \(valueStyleKurtosis ?? .nan)")
