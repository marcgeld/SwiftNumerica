public extension Numerica.Statistics {
    /// Returns the sum of the tensor values.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The sum, or `nil` when `tensor` is empty.
    static func sum(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().sum(tensor)
    }

    /// Returns the minimum tensor value.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The minimum value, or `nil` when `tensor` is empty.
    static func min(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().min(tensor)
    }

    /// Returns the maximum tensor value.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The maximum value, or `nil` when `tensor` is empty.
    static func max(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().max(tensor)
    }

    /// Returns a percentile of the tensor values.
    ///
    /// - Parameters:
    ///   - tensor: The tensor to summarize.
    ///   - percentile: A percentile between `0` and `100`.
    /// - Returns: The percentile value, or `nil` when inputs are invalid.
    static func percentile(_ tensor: Tensor<Double>, percentile: Double) -> Double? {
        try? BackendResolver.statisticsBackend().percentile(tensor, percentile: percentile)
    }

    /// Returns the interquartile range of the tensor values.
    ///
    /// The interquartile range is the 75th percentile minus the 25th percentile.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The interquartile range, or `nil` when `tensor` is empty.
    static func interquartileRange(_ tensor: Tensor<Double>) -> Double? {
        try? BackendResolver.statisticsBackend().interquartileRange(tensor)
    }
}
