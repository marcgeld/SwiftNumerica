public extension Numerica.Statistics {
    /// Returns the Spearman rank correlation coefficient for two tensors.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The Spearman correlation coefficient, or `nil` when undefined.
    static func spearmanCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().spearmanCorrelation(x, y)
    }
}
