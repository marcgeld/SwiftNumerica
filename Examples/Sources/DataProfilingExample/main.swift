import SwiftNumerica

// Data profiling:
// https://en.wikipedia.org/wiki/Data_profiling
//
// This example runs the profiling helpers directly and through DatasetProfiler.

let values = Tensor.vector([1, 2, 3, 4, 5, 10, 100, 1_000])
let matrix = Tensor.matrix([[1, 2], [2, 4], [3, 6], [4, 8]])!

let benford = Numerica.DataProfiling.benfordAnalysis(values)
let zipf = Numerica.DataProfiling.zipfAnalysis(values)
let pareto = Numerica.DataProfiling.paretoAnalysis(values)
let normality = Numerica.DataProfiling.normalityAnalysis(values)
let uniformity = Numerica.DataProfiling.uniformityAnalysis(values, bucketCount: 4)
let outliers = Numerica.DataProfiling.outlierAnalysis(values)
let trend = Numerica.DataProfiling.trendAnalysis(values)
let growth = Numerica.DataProfiling.growthRates(values)
let profile = DatasetProfiler.profile(matrix)

print("Benford MAD (expected approximately 0.0606533352604528): \(benford?.meanAbsoluteDeviation ?? .nan)")
print("Zipf entries (expected 8): \(zipf?.entries.count ?? 0)")
print("Pareto top 20 percent share (expected approximately 0.9777777777777777): \(pareto?.topTwentyPercentShare ?? .nan)")
print("Normality skewness (expected approximately 2.2276616272887173): \(normality?.skewness ?? .nan)")
print("Uniform chi-square (expected 17): \(uniformity?.chiSquareStatistic ?? .nan)")
print("Outlier values (expected [100, 1000]): \(outliers?.outliers ?? [])")
print("Trend slope/is increasing (expected positive slope 89.3452380952381 and true): \(trend?.regression.slope ?? .nan) \(trend?.isIncreasing ?? false)")
print("Growth rates (expected [1, 0.5, 0.333..., 0.25, 1, 9, 9]): \(growth ?? [])")
print("Dataset summary mean (expected 3.75): \(profile.summaryStatistics.mean ?? .nan)")
print("Correlation matrix (expected all entries 1): \(profile.correlationMatrix ?? [])")
