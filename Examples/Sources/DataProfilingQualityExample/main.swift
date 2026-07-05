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

print("Normality:", normality as Any)
print("Uniformity:", uniformity as Any)
print("Outliers:", outliers?.outliers ?? [])
print("Trend:", trend as Any)
print("Growth rates:", growth ?? [])
print("Dataset summary:", profile.summaryStatistics)
print("Correlation matrix:", profile.correlationMatrix ?? [])
