public extension Numerica.Statistics {
    /// Returns the excess population kurtosis of the tensor values.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The excess kurtosis, or `nil` when it is undefined.
    static func kurtosis(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().kurtosis(tensor)
    }
}
