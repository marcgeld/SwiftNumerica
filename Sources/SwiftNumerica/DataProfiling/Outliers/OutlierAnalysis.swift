public extension Numerica.DataProfiling {
    /// Interquartile-range outlier analysis.
    struct OutlierAnalysis: Equatable, Sendable {
        /// The lower outlier fence.
        public let lowerFence: Double

        /// The upper outlier fence.
        public let upperFence: Double

        /// Values outside the fences.
        public let outliers: [Double]
    }

    /// Detects outliers with the `1.5 * IQR` rule.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Outlier analysis, or `nil` when quartiles are undefined.
    static func outlierAnalysis(_ tensor: Tensor<Double>) -> OutlierAnalysis? {
        guard let q1 = Numerica.Statistics.quantile(tensor, probability: 0.25),
              let q3 = Numerica.Statistics.quantile(tensor, probability: 0.75) else { return nil }
        let iqr = q3 - q1
        let lowerFence = q1 - 1.5 * iqr
        let upperFence = q3 + 1.5 * iqr
        return .init(
            lowerFence: lowerFence,
            upperFence: upperFence,
            outliers: tensor.values.filter { $0 < lowerFence || $0 > upperFence }
        )
    }
}
