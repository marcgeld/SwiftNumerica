public extension Numerica.DataProfiling {
    /// Lightweight uniformity diagnostics based on equal-width buckets.
    struct UniformityAnalysis: Equatable, Sendable {
        /// The number of observations in each bucket.
        public let bucketCounts: [Int]

        /// The chi-square statistic against equal bucket frequencies.
        public let chiSquareStatistic: Double

        /// A pragmatic uniformity flag based on bucket balance.
        public let isApproximatelyUniform: Bool
    }

    /// Computes equal-width bucket uniformity diagnostics.
    ///
    /// - Parameters:
    ///   - tensor: The tensor to analyze.
    ///   - bucketCount: The number of equal-width buckets.
    /// - Returns: Uniformity analysis, or `nil` when inputs are invalid.
    static func uniformityAnalysis(_ tensor: Tensor<Double>, bucketCount: Int = 10) -> UniformityAnalysis? {
        guard bucketCount > 0,
              let minimum = tensor.values.min(),
              let maximum = tensor.values.max(),
              minimum != maximum else { return nil }

        var buckets = Array(repeating: 0, count: bucketCount)
        for value in tensor.values {
            let scaled = (value - minimum) / (maximum - minimum)
            let index = min(bucketCount - 1, Int((scaled * Double(bucketCount)).rounded(.down)))
            buckets[index] += 1
        }

        let expected = Double(tensor.count) / Double(bucketCount)
        let chiSquare = buckets.map { count in
            let difference = Double(count) - expected
            return difference * difference / expected
        }.reduce(0, +)

        return .init(
            bucketCounts: buckets,
            chiSquareStatistic: chiSquare,
            isApproximatelyUniform: chiSquare / Double(bucketCount) < 1
        )
    }
}
