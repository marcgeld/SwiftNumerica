public extension Numerica.Statistics {
    /// Returns the arithmetic mean of the tensor values.
    ///
    /// - Parameter tensor: The tensor to average.
    /// - Returns: The arithmetic mean, or `nil` when `tensor` is empty.
    static func mean(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().mean(tensor)
    }
}
