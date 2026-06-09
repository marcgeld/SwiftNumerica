public extension Numerica.DataProfiling {
    /// Lightweight normality diagnostics.
    struct NormalityAnalysis: Equatable, Sendable {
        /// The sample mean.
        public let mean: Double

        /// The sample standard deviation.
        public let standardDeviation: Double

        /// The population skewness.
        public let skewness: Double

        /// The excess population kurtosis.
        public let kurtosis: Double

        /// A pragmatic normality flag based on skewness and excess kurtosis.
        public let isApproximatelyNormal: Bool
    }

    /// Computes lightweight normality diagnostics.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Normality analysis, or `nil` when required statistics are undefined.
    static func normalityAnalysis(_ tensor: Tensor<Double>) -> NormalityAnalysis? {
        guard let mean = Numerica.Statistics.mean(tensor),
              let standardDeviation = Numerica.Statistics.sampleStandardDeviation(tensor),
              let skewness = Numerica.Statistics.skewness(tensor),
              let kurtosis = Numerica.Statistics.kurtosis(tensor) else { return nil }
        return .init(
            mean: mean,
            standardDeviation: standardDeviation,
            skewness: skewness,
            kurtosis: kurtosis,
            isApproximatelyNormal: abs(skewness) < 0.5 && abs(kurtosis) < 1
        )
    }
}
