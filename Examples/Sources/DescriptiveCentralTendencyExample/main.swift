import SwiftNumerica

// Central tendency:
// https://en.wikipedia.org/wiki/Central_tendency
//
// This example shows the public mean, median, mode, sum, min, and max APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

print("Data:", data.values)
print("Sum:", Numerica.Statistics.sum(data) ?? .nan)
print("Minimum:", Numerica.Statistics.min(data) ?? .nan)
print("Maximum:", Numerica.Statistics.max(data) ?? .nan)
print("Mean:", Numerica.Statistics.mean(data) ?? .nan)
print("Median:", Numerica.Statistics.median(data) ?? .nan)
print("Mode:", Numerica.Statistics.mode(data))
print("Value-style mean:", data.mean() ?? .nan)
print("Value-style median:", data.median() ?? .nan)
