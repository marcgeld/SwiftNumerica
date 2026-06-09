public extension Numerica.DataProfiling {
    /// Linear trend analysis.
    struct TrendAnalysis: Equatable, Sendable {
        /// The fitted linear regression result.
        public let regression: Numerica.Statistics.LinearRegressionResult

        /// Whether the slope is positive.
        public let isIncreasing: Bool
    }

    /// Computes a linear trend against positional indices.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Trend analysis, or `nil` when regression is undefined.
    static func trendAnalysis(_ tensor: Tensor<Double>) -> TrendAnalysis? {
        let x = Tensor.vector(tensor.values.indices.map(Double.init))
        guard let regression = Numerica.Statistics.linearRegression(x: x, y: tensor) else { return nil }
        return .init(regression: regression, isIncreasing: regression.slope > 0)
    }

    /// Computes consecutive growth rates.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Growth rates, or `nil` when the tensor has fewer than two values or a zero baseline.
    static func growthRates(_ tensor: Tensor<Double>) -> [Double]? {
        guard tensor.count > 1 else { return nil }
        var rates: [Double] = []
        for index in 1..<tensor.values.count {
            let previous = tensor.values[index - 1]
            guard previous != 0 else { return nil }
            rates.append((tensor.values[index] - previous) / previous)
        }
        return rates
    }
}
