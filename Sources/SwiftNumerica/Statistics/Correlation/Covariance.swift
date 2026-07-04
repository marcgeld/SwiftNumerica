public extension Numerica.Statistics {
    /// Returns the sample covariance between two tensors.
    ///
    /// This is a convenience alias for `sampleCovariance(_:,_:)`.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The sample covariance, or `nil` when undefined.
    static func covariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        sampleCovariance(x, y)
    }

    /// Returns the population covariance between two tensors.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The population covariance, or `nil` when undefined.
    static func populationCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().populationCovariance(x, y)
    }

    /// Returns the sample covariance between two tensors.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The sample covariance, or `nil` when undefined.
    static func sampleCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().sampleCovariance(x, y)
    }

    /// Returns the Pearson correlation coefficient for two tensors.
    ///
    /// This is a convenience alias for `pearsonCorrelation(_:,_:)`.
    ///
    /// - Parameters:
    ///   - x: The first tensor.
    ///   - y: The second tensor.
    /// - Returns: The Pearson correlation coefficient, or `nil` when undefined.
    static func correlation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        pearsonCorrelation(x, y)
    }
}
