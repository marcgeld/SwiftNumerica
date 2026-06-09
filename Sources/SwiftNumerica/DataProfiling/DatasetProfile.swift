/// Summary statistics for a numerical tensor.
public struct SummaryStatistics: Equatable, Sendable {
    /// The mean value.
    public let mean: Double?

    /// The median value.
    public let median: Double?

    /// The modal values.
    public let mode: [Double]

    /// The statistical range.
    public let range: Double?

    /// The sample variance.
    public let sampleVariance: Double?

    /// The sample standard deviation.
    public let sampleStandardDeviation: Double?
}

/// A complete automated profile for a numerical tensor.
public struct DatasetProfile: Equatable, Sendable {
    /// Summary statistics.
    public let summaryStatistics: SummaryStatistics

    /// Benford's Law analysis.
    public let benfordAnalysis: Numerica.DataProfiling.BenfordAnalysis?

    /// Zipf's Law analysis.
    public let zipfAnalysis: Numerica.DataProfiling.ZipfAnalysis?

    /// Pareto analysis.
    public let paretoAnalysis: Numerica.DataProfiling.ParetoAnalysis?

    /// Normality analysis.
    public let normalityAnalysis: Numerica.DataProfiling.NormalityAnalysis?

    /// Uniformity analysis.
    public let uniformityAnalysis: Numerica.DataProfiling.UniformityAnalysis?

    /// Outlier analysis.
    public let outlierAnalysis: Numerica.DataProfiling.OutlierAnalysis?

    /// Correlation matrix for rank-2 tensors.
    public let correlationMatrix: [[Double?]]?

    /// Trend analysis.
    public let trendAnalysis: Numerica.DataProfiling.TrendAnalysis?

    /// Consecutive growth rates.
    public let growthRateAnalysis: [Double]?
}

/// Automated profiling for numerical tensors.
public enum DatasetProfiler {
    /// Profiles a tensor using SwiftNumerica's reusable statistical primitives.
    ///
    /// - Parameter tensor: The tensor to profile.
    /// - Returns: A dataset profile.
    public static func profile(_ tensor: Tensor<Double>) -> DatasetProfile {
        DatasetProfile(
            summaryStatistics: .init(
                mean: Numerica.Statistics.mean(tensor),
                median: Numerica.Statistics.median(tensor),
                mode: Numerica.Statistics.mode(tensor),
                range: Numerica.Statistics.range(tensor),
                sampleVariance: Numerica.Statistics.sampleVariance(tensor),
                sampleStandardDeviation: Numerica.Statistics.sampleStandardDeviation(tensor)
            ),
            benfordAnalysis: Numerica.DataProfiling.benfordAnalysis(tensor),
            zipfAnalysis: Numerica.DataProfiling.zipfAnalysis(tensor),
            paretoAnalysis: Numerica.DataProfiling.paretoAnalysis(tensor),
            normalityAnalysis: Numerica.DataProfiling.normalityAnalysis(tensor),
            uniformityAnalysis: Numerica.DataProfiling.uniformityAnalysis(tensor),
            outlierAnalysis: Numerica.DataProfiling.outlierAnalysis(tensor),
            correlationMatrix: correlationMatrix(for: tensor),
            trendAnalysis: Numerica.DataProfiling.trendAnalysis(tensor),
            growthRateAnalysis: Numerica.DataProfiling.growthRates(tensor)
        )
    }

    private static func correlationMatrix(for tensor: Tensor<Double>) -> [[Double?]]? {
        guard tensor.rank == 2,
              tensor.shape.dimensions.count == 2,
              tensor.shape.dimensions[1] > 0 else { return nil }

        let rowCount = tensor.shape.dimensions[0]
        let columnCount = tensor.shape.dimensions[1]
        let columns = (0..<columnCount).map { column in
            Tensor.vector((0..<rowCount).map { row in
                tensor.values[row * columnCount + column]
            })
        }

        return columns.map { left in
            columns.map { right in
                Numerica.Statistics.pearsonCorrelation(left, right)
            }
        }
    }
}
