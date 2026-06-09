public extension Numerica.Statistics {
    /// Returns the median value of the tensor values.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The median value, or `nil` when `tensor` is empty.
    static func median(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().median(tensor)
    }
}
