extension Numerica.DataProfiling {
    /// Benford's Law analysis for leading digits.
    public struct BenfordAnalysis: Equatable, Sendable {
        /// Observed frequencies for leading digits `1...9`.
        public let observedFrequencies: [Int: Double]

        /// Expected Benford frequencies for leading digits `1...9`.
        public let expectedFrequencies: [Int: Double]

        /// Mean absolute deviation between observed and expected frequencies.
        public let meanAbsoluteDeviation: Double
    }

    /// Analyzes leading digits using Benford's Law.
    ///
    /// - Parameter tensor: The tensor to analyze.
    /// - Returns: Benford analysis, or `nil` when no leading digits can be extracted.
    public static func benfordAnalysis(_ tensor: Tensor<Double>) -> BenfordAnalysis? {
        let digits = tensor.values.compactMap(leadingDigit)
        guard !digits.isEmpty else { return nil }

        var observed: [Int: Double] = [:]
        for digit in 1...9 {
            observed[digit] = Double(digits.filter { $0 == digit }.count) / Double(digits.count)
        }

        let expected: [Int: Double] = [
            1: 0.3010299956639812,
            2: 0.17609125905568124,
            3: 0.12493873660829993,
            4: 0.09691001300805642,
            5: 0.07918124604762482,
            6: 0.06694678963061322,
            7: 0.05799194697768673,
            8: 0.05115252244738129,
            9: 0.04575749056067514,
        ]

        var totalDeviation = 0.0
        for digit in 1...9 {
            totalDeviation += abs((observed[digit] ?? 0) - (expected[digit] ?? 0))
        }
        let deviation = totalDeviation / 9

        return .init(
            observedFrequencies: observed,
            expectedFrequencies: expected,
            meanAbsoluteDeviation: deviation
        )
    }

    private static func leadingDigit(_ value: Double) -> Int? {
        var magnitude = abs(value)
        guard magnitude >= 1 else { return nil }
        while magnitude >= 10 {
            magnitude /= 10
        }
        return Int(magnitude)
    }
}
