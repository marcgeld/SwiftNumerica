import Foundation

public extension Numerica.Statistics {
    /// A confidence interval around an estimated value.
    struct ConfidenceInterval: Equatable, Sendable {
        /// The lower interval bound.
        public let lowerBound: Double

        /// The upper interval bound.
        public let upperBound: Double

        /// The confidence level used to construct the interval.
        public let confidenceLevel: Double

        /// Creates a confidence interval.
        public init(lowerBound: Double, upperBound: Double, confidenceLevel: Double) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            self.confidenceLevel = confidenceLevel
        }
    }

    /// The result of a statistical hypothesis test.
    struct HypothesisTestResult: Equatable, Sendable {
        /// The test statistic.
        public let statistic: Double

        /// The p-value for the test.
        public let pValue: Double

        /// The confidence interval when the test produces one.
        public let confidenceInterval: ConfidenceInterval?

        /// Creates a hypothesis test result.
        public init(statistic: Double, pValue: Double, confidenceInterval: ConfidenceInterval? = nil) {
            self.statistic = statistic
            self.pValue = pValue
            self.confidenceInterval = confidenceInterval
        }
    }

    /// Performs Welch's two-sample t-test.
    ///
    /// - Parameters:
    ///   - sampleA: The first independent sample.
    ///   - sampleB: The second independent sample.
    ///   - confidenceLevel: The confidence level for the mean-difference interval.
    /// - Returns: The test result, or `nil` when the test is undefined.
    static func tTest(
        _ sampleA: Tensor<Double>,
        _ sampleB: Tensor<Double>,
        confidenceLevel: Double = 0.95
    ) -> HypothesisTestResult? {
        guard sampleA.count > 1,
              sampleB.count > 1,
              let meanA = mean(sampleA),
              let meanB = mean(sampleB),
              let varianceA = sampleVariance(sampleA),
              let varianceB = sampleVariance(sampleB),
              isValidConfidenceLevel(confidenceLevel) else { return nil }

        let sampleCountA = Double(sampleA.count)
        let sampleCountB = Double(sampleB.count)
        let standardErrorSquared = varianceA / sampleCountA + varianceB / sampleCountB
        guard standardErrorSquared > 0 else { return nil }

        let standardError = standardErrorSquared.squareRoot()
        let statistic = (meanA - meanB) / standardError
        let degreesOfFreedomNumerator = standardErrorSquared * standardErrorSquared
        let degreesOfFreedomDenominator =
            (varianceA * varianceA) / (sampleCountA * sampleCountA * Double(sampleA.count - 1))
            + (varianceB * varianceB) / (sampleCountB * sampleCountB * Double(sampleB.count - 1))
        guard degreesOfFreedomDenominator > 0 else { return nil }

        let degreesOfFreedom = degreesOfFreedomNumerator / degreesOfFreedomDenominator
        let pValue = twoSidedTTestPValue(statistic: statistic, degreesOfFreedom: degreesOfFreedom)
        let confidenceInterval = meanDifferenceConfidenceInterval(
            estimate: meanA - meanB,
            standardError: standardError,
            degreesOfFreedom: degreesOfFreedom,
            confidenceLevel: confidenceLevel
        )

        return .init(statistic: statistic, pValue: pValue, confidenceInterval: confidenceInterval)
    }

    /// Performs a paired t-test.
    ///
    /// - Parameters:
    ///   - sampleA: The first paired sample.
    ///   - sampleB: The second paired sample.
    ///   - confidenceLevel: The confidence level for the mean-difference interval.
    /// - Returns: The test result, or `nil` when the test is undefined.
    static func pairedTTest(
        _ sampleA: Tensor<Double>,
        _ sampleB: Tensor<Double>,
        confidenceLevel: Double = 0.95
    ) -> HypothesisTestResult? {
        guard sampleA.count == sampleB.count,
              sampleA.count > 1,
              isValidConfidenceLevel(confidenceLevel) else { return nil }

        let differences = Tensor.vector(zip(sampleA.values, sampleB.values).map { $0 - $1 })
        guard let differenceMean = mean(differences),
              let differenceStandardDeviation = sampleStandardDeviation(differences),
              differenceStandardDeviation > 0 else { return nil }

        let standardError = differenceStandardDeviation / Double(differences.count).squareRoot()
        let statistic = differenceMean / standardError
        let degreesOfFreedom = Double(differences.count - 1)
        let pValue = twoSidedTTestPValue(statistic: statistic, degreesOfFreedom: degreesOfFreedom)
        let confidenceInterval = meanDifferenceConfidenceInterval(
            estimate: differenceMean,
            standardError: standardError,
            degreesOfFreedom: degreesOfFreedom,
            confidenceLevel: confidenceLevel
        )

        return .init(statistic: statistic, pValue: pValue, confidenceInterval: confidenceInterval)
    }

    /// Performs a chi-square goodness-of-fit test.
    ///
    /// When `expected` is omitted, the observed total is distributed uniformly
    /// across all categories.
    ///
    /// - Parameters:
    ///   - observed: Observed category counts.
    ///   - expected: Expected category counts.
    /// - Returns: The test result, or `nil` when the test is undefined.
    static func chiSquareTest(
        observed: Tensor<Double>,
        expected: Tensor<Double>? = nil
    ) -> HypothesisTestResult? {
        guard observed.count > 1,
              observed.values.allSatisfy({ $0 >= 0 }) else { return nil }

        let expectedValues: [Double]
        if let expected {
            guard expected.count == observed.count,
                  expected.values.allSatisfy({ $0 > 0 }) else { return nil }
            expectedValues = expected.values
        } else {
            let total = observed.values.reduce(0, +)
            guard total > 0 else { return nil }
            expectedValues = Array(repeating: total / Double(observed.count), count: observed.count)
        }

        let statistic = zip(observed.values, expectedValues).reduce(0.0) { partialResult, pair in
            let difference = pair.0 - pair.1
            return partialResult + difference * difference / pair.1
        }
        let degreesOfFreedom = Double(observed.count - 1)
        let pValue = chiSquareUpperTail(statistic: statistic, degreesOfFreedom: degreesOfFreedom)

        return .init(statistic: statistic, pValue: pValue)
    }

    /// Performs a one-way analysis of variance.
    ///
    /// - Parameter groups: Independent samples, one tensor per group.
    /// - Returns: The test result, or `nil` when the test is undefined.
    static func oneWayANOVA(_ groups: [Tensor<Double>]) -> HypothesisTestResult? {
        guard groups.count > 1,
              groups.allSatisfy({ !$0.values.isEmpty }) else { return nil }

        let totalCount = groups.reduce(0) { $0 + $1.count }
        guard totalCount > groups.count else { return nil }

        let allValues = groups.flatMap(\.values)
        let grandMean = allValues.reduce(0, +) / Double(totalCount)

        var betweenGroupSumSquares = 0.0
        var withinGroupSumSquares = 0.0

        for group in groups {
            guard let groupMean = mean(group) else { return nil }
            let groupDifference = groupMean - grandMean
            betweenGroupSumSquares += Double(group.count) * groupDifference * groupDifference
            withinGroupSumSquares += group.values.reduce(0.0) { partialResult, value in
                let difference = value - groupMean
                return partialResult + difference * difference
            }
        }

        let betweenDegreesOfFreedom = Double(groups.count - 1)
        let withinDegreesOfFreedom = Double(totalCount - groups.count)
        guard withinGroupSumSquares > 0 else { return nil }

        let statistic = (betweenGroupSumSquares / betweenDegreesOfFreedom)
            / (withinGroupSumSquares / withinDegreesOfFreedom)
        let pValue = fUpperTail(
            statistic: statistic,
            numeratorDegreesOfFreedom: betweenDegreesOfFreedom,
            denominatorDegreesOfFreedom: withinDegreesOfFreedom
        )

        return .init(statistic: statistic, pValue: pValue)
    }

    /// Performs a two-sided Mann-Whitney U test.
    ///
    /// - Parameters:
    ///   - sampleA: The first independent sample.
    ///   - sampleB: The second independent sample.
    /// - Returns: The test result, or `nil` when the test is undefined.
    static func mannWhitneyU(_ sampleA: Tensor<Double>, _ sampleB: Tensor<Double>) -> HypothesisTestResult? {
        guard !sampleA.values.isEmpty, !sampleB.values.isEmpty else { return nil }

        let leftCount = Double(sampleA.count)
        let rightCount = Double(sampleB.count)
        let ranked = rankedSamples(sampleA.values, sampleB.values)
        let leftRankSum = ranked.ranks.enumerated().reduce(0.0) { partialResult, pair in
            ranked.sampleIndexes[pair.offset] == 0 ? partialResult + pair.element : partialResult
        }

        let leftU = leftRankSum - leftCount * (leftCount + 1) / 2
        let rightU = leftCount * rightCount - leftU
        let statistic = Swift.min(leftU, rightU)
        let meanU = leftCount * rightCount / 2
        let varianceU = mannWhitneyVariance(
            leftCount: leftCount,
            rightCount: rightCount,
            tieCounts: ranked.tieCounts
        )
        guard varianceU > 0 else { return nil }

        let zStatistic = (statistic - meanU + 0.5) / varianceU.squareRoot()
        let pValue = 2 * Swift.min(
            ProbabilityMath.normalCDFStandardized(zStatistic),
            1 - ProbabilityMath.normalCDFStandardized(zStatistic)
        )

        return .init(statistic: statistic, pValue: Swift.min(1, Swift.max(0, pValue)))
    }

    private static func isValidConfidenceLevel(_ confidenceLevel: Double) -> Bool {
        confidenceLevel > 0 && confidenceLevel < 1
    }

    private static func twoSidedTTestPValue(statistic: Double, degreesOfFreedom: Double) -> Double {
        let tail = 1 - studentTCDF(Swift.abs(statistic), degreesOfFreedom: degreesOfFreedom)
        return Swift.min(1, Swift.max(0, 2 * tail))
    }

    private static func studentTCDF(_ value: Double, degreesOfFreedom: Double) -> Double {
        guard degreesOfFreedom > 0 else { return .nan }
        if value == 0 { return 0.5 }

        let x = degreesOfFreedom / (degreesOfFreedom + value * value)
        let beta = ProbabilityMath.regularizedBeta(x: x, alpha: degreesOfFreedom / 2, beta: 0.5)
        if value > 0 {
            return 1 - 0.5 * beta
        }
        return 0.5 * beta
    }

    private static func inverseStudentTCDF(probability: Double, degreesOfFreedom: Double) -> Double? {
        guard (0...1).contains(probability), degreesOfFreedom > 0 else { return nil }
        if probability == 0 { return -.infinity }
        if probability == 1 { return .infinity }

        var lower = -1.0
        var upper = 1.0
        while studentTCDF(lower, degreesOfFreedom: degreesOfFreedom) > probability {
            lower *= 2
        }
        while studentTCDF(upper, degreesOfFreedom: degreesOfFreedom) < probability {
            upper *= 2
        }

        for _ in 0..<100 {
            let midpoint = (lower + upper) / 2
            if studentTCDF(midpoint, degreesOfFreedom: degreesOfFreedom) < probability {
                lower = midpoint
            } else {
                upper = midpoint
            }
        }
        return (lower + upper) / 2
    }

    private static func meanDifferenceConfidenceInterval(
        estimate: Double,
        standardError: Double,
        degreesOfFreedom: Double,
        confidenceLevel: Double
    ) -> ConfidenceInterval? {
        let probability = 0.5 + confidenceLevel / 2
        guard let criticalValue = inverseStudentTCDF(
            probability: probability,
            degreesOfFreedom: degreesOfFreedom
        ) else { return nil }

        let margin = criticalValue * standardError
        return .init(
            lowerBound: estimate - margin,
            upperBound: estimate + margin,
            confidenceLevel: confidenceLevel
        )
    }

    private static func chiSquareUpperTail(statistic: Double, degreesOfFreedom: Double) -> Double {
        guard statistic >= 0, degreesOfFreedom > 0 else { return .nan }
        return 1 - ProbabilityMath.regularizedLowerIncompleteGamma(
            shape: degreesOfFreedom / 2,
            x: statistic / 2
        )
    }

    private static func fUpperTail(
        statistic: Double,
        numeratorDegreesOfFreedom: Double,
        denominatorDegreesOfFreedom: Double
    ) -> Double {
        guard statistic >= 0,
              numeratorDegreesOfFreedom > 0,
              denominatorDegreesOfFreedom > 0 else { return .nan }

        let numerator = numeratorDegreesOfFreedom * statistic
        let x = numerator / (numerator + denominatorDegreesOfFreedom)
        let cdf = ProbabilityMath.regularizedBeta(
            x: x,
            alpha: numeratorDegreesOfFreedom / 2,
            beta: denominatorDegreesOfFreedom / 2
        )
        return 1 - cdf
    }

    private static func rankedSamples(_ left: [Double], _ right: [Double])
        -> (ranks: [Double], sampleIndexes: [Int], tieCounts: [Int])
    {
        let combined = left.map { (value: $0, sampleIndex: 0) }
            + right.map { (value: $0, sampleIndex: 1) }
        let sorted = combined.enumerated().sorted { $0.element.value < $1.element.value }
        var ranks = Array(repeating: 0.0, count: combined.count)
        var sampleIndexes = Array(repeating: 0, count: combined.count)
        var tieCounts: [Int] = []
        var index = 0

        while index < sorted.count {
            var upper = index
            while upper + 1 < sorted.count
                && sorted[upper + 1].element.value == sorted[index].element.value
            {
                upper += 1
            }

            let averageRank = (Double(index + 1) + Double(upper + 1)) / 2
            let tieCount = upper - index + 1
            if tieCount > 1 {
                tieCounts.append(tieCount)
            }

            for rankIndex in index...upper {
                let originalIndex = sorted[rankIndex].offset
                ranks[originalIndex] = averageRank
                sampleIndexes[originalIndex] = sorted[rankIndex].element.sampleIndex
            }

            index = upper + 1
        }

        return (ranks, sampleIndexes, tieCounts)
    }

    private static func mannWhitneyVariance(
        leftCount: Double,
        rightCount: Double,
        tieCounts: [Int]
    ) -> Double {
        let totalCount = leftCount + rightCount
        let tieAdjustment = tieCounts.reduce(0.0) { partialResult, tieCount in
            let count = Double(tieCount)
            return partialResult + count * count * count - count
        }
        let correction = tieAdjustment / (totalCount * (totalCount - 1))
        return leftCount * rightCount / 12 * (totalCount + 1 - correction)
    }
}

/// Performs Welch's two-sample t-test.
public func tTest(
    _ sampleA: Tensor<Double>,
    _ sampleB: Tensor<Double>,
    confidenceLevel: Double = 0.95
) -> Numerica.Statistics.HypothesisTestResult? {
    Numerica.Statistics.tTest(sampleA, sampleB, confidenceLevel: confidenceLevel)
}

/// Performs a paired t-test.
public func pairedTTest(
    _ sampleA: Tensor<Double>,
    _ sampleB: Tensor<Double>,
    confidenceLevel: Double = 0.95
) -> Numerica.Statistics.HypothesisTestResult? {
    Numerica.Statistics.pairedTTest(sampleA, sampleB, confidenceLevel: confidenceLevel)
}

/// Performs a chi-square goodness-of-fit test.
public func chiSquareTest(
    observed: Tensor<Double>,
    expected: Tensor<Double>? = nil
) -> Numerica.Statistics.HypothesisTestResult? {
    Numerica.Statistics.chiSquareTest(observed: observed, expected: expected)
}

/// Performs a one-way analysis of variance.
public func oneWayANOVA(_ groups: [Tensor<Double>]) -> Numerica.Statistics.HypothesisTestResult? {
    Numerica.Statistics.oneWayANOVA(groups)
}

/// Performs a two-sided Mann-Whitney U test.
public func mannWhitneyU(
    _ sampleA: Tensor<Double>,
    _ sampleB: Tensor<Double>
) -> Numerica.Statistics.HypothesisTestResult? {
    Numerica.Statistics.mannWhitneyU(sampleA, sampleB)
}
