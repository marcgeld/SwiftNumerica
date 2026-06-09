public extension Numerica.Statistics {
    /// Returns the most frequently occurring tensor values.
    ///
    /// - Parameter tensor: The tensor to summarize.
    /// - Returns: The modal values, or an empty array when there is no repeated mode.
    static func mode(_ tensor: Tensor<Double>) -> [Double] {
        (try? BackendResolver.statisticsBackend().mode(tensor)) ?? []
    }
}
