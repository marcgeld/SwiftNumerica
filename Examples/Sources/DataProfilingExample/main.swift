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

print("Benford MAD:", benford?.meanAbsoluteDeviation ?? .nan)
print("Zipf entries:", zipf?.entries.count ?? 0)
print("Pareto top 20 percent share:", pareto?.topTwentyPercentShare ?? .nan)
print("Normality skewness:", normality?.skewness ?? .nan)
print("Uniform chi-square:", uniformity?.chiSquareStatistic ?? .nan)
print("Outlier values:", outliers?.outliers ?? [])
print("Trend slope:", trend?.regression.slope ?? .nan, "is increasing:", trend?.isIncreasing ?? false)
print("Growth rates:", growth ?? [])
print("Dataset summary mean:", profile.summaryStatistics.mean ?? .nan)
print("Correlation matrix:", profile.correlationMatrix ?? [])
