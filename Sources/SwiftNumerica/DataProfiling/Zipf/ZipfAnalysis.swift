public extension Numerica.DataProfiling {
    /// A ranked frequency entry for Zipf's Law analysis.
    struct ZipfEntry: Equatable, Sendable {
        /// The observed value.
        public let value: Double

        /// The rank, starting at `1`.
        public let rank: Int

        /// The observed frequency.
        public let frequency: Double

        /// A normalized `1 / rank` expected frequency.
        public let expectedFrequency: Double
    }

    /// Zipf's Law analysis.
    struct ZipfAnalysis: Equatable, Sendable {
        /// Ranked frequency entries.
        public let entries: [ZipfEntry]
    }

    /// Computes ranked frequencies for Zipf-style analysis.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Zipf analysis, or `nil` for an empty tensor.
    static func zipfAnalysis(_ tensor: Tensor<Double>) -> ZipfAnalysis? {
        guard !tensor.values.isEmpty else { return nil }
        let counts = Dictionary(grouping: tensor.values, by: { $0 }).mapValues(\.count)
        let ranked = counts.sorted {
            if $0.value == $1.value { return $0.key < $1.key }
            return $0.value > $1.value
        }
        let harmonic = (1...ranked.count).map { 1 / Double($0) }.reduce(0, +)
        let entries = ranked.enumerated().map { index, pair in
            ZipfEntry(
                value: pair.key,
                rank: index + 1,
                frequency: Double(pair.value) / Double(tensor.count),
                expectedFrequency: (1 / Double(index + 1)) / harmonic
            )
        }
        return .init(entries: entries)
    }
}
