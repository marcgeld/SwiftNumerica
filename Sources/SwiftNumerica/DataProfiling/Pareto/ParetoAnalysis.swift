public extension Numerica.DataProfiling {
    /// Pareto-style concentration analysis.
    struct ParetoAnalysis: Equatable, Sendable {
        /// The share of total magnitude held by the largest 20 percent of values.
        public let topTwentyPercentShare: Double

        /// Whether the tensor approximately follows an 80/20 concentration pattern.
        public let isApproximatelyPareto: Bool
    }

    /// Computes a simple Pareto concentration analysis.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Pareto analysis, or `nil` when total magnitude is zero.
    static func paretoAnalysis(_ tensor: Tensor<Double>) -> ParetoAnalysis? {
        let magnitudes = tensor.values.map(abs).sorted(by: >)
        guard !magnitudes.isEmpty else { return nil }
        let total = magnitudes.reduce(0, +)
        guard total != 0 else { return nil }
        let topCount = max(1, Int((Double(magnitudes.count) * 0.2).rounded(.up)))
        let share = magnitudes.prefix(topCount).reduce(0, +) / total
        return .init(topTwentyPercentShare: share, isApproximatelyPareto: share >= 0.75)
    }
}
