public extension Numerica.Statistics {
    /// Returns the statistical range of the tensor values.
    ///
    /// The statistical range is `maximum - minimum`.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The range, or `nil` when `tensor` is empty.
    static func range(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().range(tensor)
    }
}
