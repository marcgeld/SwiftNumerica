import SwiftNumerica

// Central tendency:
// https://en.wikipedia.org/wiki/Central_tendency
//
// This example shows the public mean, median, mode, sum, min, and max APIs.

let data = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])
let sum = try Numerica.Statistics.sum(data)
let minimum = try Numerica.Statistics.min(data)
let maximum = try Numerica.Statistics.max(data)
let mean = try Numerica.Statistics.mean(data)
let median = try Numerica.Statistics.median(data)
let mode = try Numerica.Statistics.mode(data)
let valueStyleMean = try data.mean()
let valueStyleMedian = try data.median()

print("Data (expected eight values): \(data.values)")
print("Sum (expected 2 + 4 + 4 + 4 + 5 + 5 + 7 + 9 = 40): \(sum ?? .nan)")
print("Minimum (expected smallest value = 2): \(minimum ?? .nan)")
print("Maximum (expected largest value = 9): \(maximum ?? .nan)")
print("Mean (expected 40 / 8 = 5): \(mean ?? .nan)")
print("Median (expected average of middle values 4 and 5 = 4.5): \(median ?? .nan)")
print("Mode (expected most frequent value [4]): \(mode)")
print("Value-style mean (expected same as namespace mean = 5): \(valueStyleMean ?? .nan)")
print("Value-style median (expected same as namespace median = 4.5): \(valueStyleMedian ?? .nan)")
