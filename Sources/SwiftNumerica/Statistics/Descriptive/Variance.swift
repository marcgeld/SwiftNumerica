public extension Numerica.Statistics {
    /// Returns the sample variance of the tensor values.
    ///
    /// This is a convenience alias for `sampleVariance(_:)`.
    ///
    /// - Parameter tensor: A sample tensor.
    /// - Returns: The unbiased sample variance, or `nil` when fewer than two values are provided.
    static func variance(_ tensor: Tensor<Double>) -> Double? {
        sampleVariance(tensor)
    }

    /// Returns the population variance of the tensor values.
    ///
    /// - Parameter tensor: The full population tensor.
    /// - Returns: The population variance, or `nil` when `tensor` is empty.
    static func populationVariance(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().populationVariance(tensor)
    }

    /// Returns the sample variance of the tensor values.
    ///
    /// - Parameter tensor: A sample tensor.
    /// - Returns: The unbiased sample variance, or `nil` when fewer than two values are provided.
    static func sampleVariance(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().sampleVariance(tensor)
    }
}
