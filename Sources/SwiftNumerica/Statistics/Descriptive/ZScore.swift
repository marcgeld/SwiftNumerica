public extension Numerica.Statistics {
    /// Returns the z-score for a value relative to a mean and standard deviation.
    ///
    /// - Parameters:
    ///   - value: The observed value.
    ///   - mean: The mean of the distribution or sample.
    ///   - standardDeviation: The standard deviation of the distribution or sample.
    /// - Returns: The z-score, or `nil` when `standardDeviation` is zero.
    static func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double? {
        try? BackendResolver.statisticsBackend().zScore(
            value: value,
            mean: mean,
            standardDeviation: standardDeviation
        )
    }
}
