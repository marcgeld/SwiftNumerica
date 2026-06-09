public extension Numerica.Statistics {
    /// Returns the population skewness of the tensor values.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The skewness, or `nil` when it is undefined.
    static func skewness(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().skewness(tensor)
    }
}
