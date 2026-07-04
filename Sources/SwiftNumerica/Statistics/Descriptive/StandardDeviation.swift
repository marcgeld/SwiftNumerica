public extension Numerica.Statistics {
    /// Returns the sample standard deviation of the tensor values.
    ///
    /// This is a convenience alias for `sampleStandardDeviation(_:)`.
    ///
    /// - Parameter tensor: A sample tensor.
    /// - Returns: The sample standard deviation, or `nil` when fewer than two values are provided.
    static func standardDeviation(_ tensor: Tensor<Double>) -> Double? {
        sampleStandardDeviation(tensor)
    }

    /// Returns the population standard deviation of the tensor values.
    ///
    /// - Parameter tensor: The full population tensor.
    /// - Returns: The population standard deviation, or `nil` when `tensor` is empty.
    static func populationStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().populationStandardDeviation(tensor)
    }

    /// Returns the sample standard deviation of the tensor values.
    ///
    /// - Parameter tensor: A sample tensor.
    /// - Returns: The sample standard deviation, or `nil` when fewer than two values are provided.
    static func sampleStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().sampleStandardDeviation(tensor)
    }
}
