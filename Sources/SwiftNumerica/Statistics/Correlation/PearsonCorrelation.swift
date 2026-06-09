public extension Numerica.Statistics {
    /// Returns the Pearson correlation coefficient for two tensors.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The Pearson correlation coefficient, or `nil` when undefined.
    static func pearsonCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().pearsonCorrelation(x, y)
    }
}
