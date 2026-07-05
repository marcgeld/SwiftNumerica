import SwiftNumerica

// Data profiling:
// https://en.wikipedia.org/wiki/Data_profiling
//
// This example checks distribution shape, uniformity, outliers, trends, growth
// rates, and the aggregate DatasetProfiler output.

let values = Tensor.vector([1, 2, 3, 4, 5, 10, 100, 1_000])
let matrix = Tensor.matrix([[1, 2], [2, 4], [3, 6], [4, 8]])!
let normality = Numerica.DataProfiling.normalityAnalysis(values)
let uniformity = Numerica.DataProfiling.uniformityAnalysis(values, bucketCount: 4)
let outliers = Numerica.DataProfiling.outlierAnalysis(values)
let trend = Numerica.DataProfiling.trendAnalysis(values)
let growth = Numerica.DataProfiling.growthRates(values)
let profile = DatasetProfiler.profile(matrix)

print("Normality (expected mean 140.625 and isApproximatelyNormal false): \(normality as Any)")
print("Uniformity (expected chi-square 17 and isApproximatelyUniform false): \(uniformity as Any)")
print("Outliers (expected [100, 1000]): \(outliers?.outliers ?? [])")
print("Trend (expected positive slope and isIncreasing true): \(trend as Any)")
print("Growth rates (expected [1, 0.5, 0.333..., 0.25, 1, 9, 9]): \(growth ?? [])")
print("Dataset summary (expected mean 3.75, median 3.5): \(profile.summaryStatistics)")
print("Correlation matrix (expected all entries 1): \(profile.correlationMatrix ?? [])")
