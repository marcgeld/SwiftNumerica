import SwiftNumerica

// Skewness and kurtosis:
// https://en.wikipedia.org/wiki/Skewness
// https://en.wikipedia.org/wiki/Kurtosis
//
// This example shows distribution-shape summaries for one sample.

let data = Tensor.vector([1, 2, 2, 3, 4, 8, 13])

print("Data:", data.values)
print("Skewness:", Numerica.Statistics.skewness(data) ?? .nan)
print("Excess kurtosis:", Numerica.Statistics.kurtosis(data) ?? .nan)
print("Value-style skewness:", data.skewness() ?? .nan)
print("Value-style kurtosis:", data.kurtosis() ?? .nan)
