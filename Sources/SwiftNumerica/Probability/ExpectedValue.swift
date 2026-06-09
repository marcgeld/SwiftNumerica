public extension Numerica.Probability {
    /// A namespace for expected value operations.
    enum ExpectedValue {
        /// Computes an expected value from paired value and probability tensors.
        ///
        /// - Parameters:
        ///   - values: Outcome values as a tensor.
        ///   - probabilities: Probabilities associated with the outcomes.
        /// - Returns: The expected value, or `nil` when inputs are invalid.
        public static func discrete(values: Tensor<Double>, probabilities: Tensor<Double>) -> Double? {
            guard values.count == probabilities.count,
                  !values.values.isEmpty else { return nil }
            return zip(values.values, probabilities.values).map(*).reduce(0, +)
        }
    }
}
