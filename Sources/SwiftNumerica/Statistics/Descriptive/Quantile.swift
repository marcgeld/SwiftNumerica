public extension Numerica.Statistics {
    /// Returns a linearly interpolated quantile of the tensor values.
    ///
    /// - Parameters:
    ///   - tensor: The tensor to summarize.
    ///   - probability: A probability between `0` and `1`.
    /// - Returns: The quantile value, or `nil` when inputs are invalid.
    static func quantile(_ tensor: Tensor<Double>, probability: Double) -> Double? {
        try? BackendResolver.statisticsBackend().quantile(tensor, probability: probability)
    }
}
