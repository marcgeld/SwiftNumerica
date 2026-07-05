import Foundation

public extension Numerica.Statistics {
    /// Statistical hypothesis tests.
    enum HypothesisTesting {
        /// A confidence interval around an estimated value.
        public struct ConfidenceInterval: Equatable, Sendable {
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

        /// Direction of the alternative hypothesis.
        public enum AlternativeHypothesis: Equatable, Sendable {
            /// The compared estimate differs from the null value.
            case twoSided

            /// The compared estimate is less than the null value.
            case less

            /// The compared estimate is greater than the null value.
            case greater
        }

        /// The result of a statistical hypothesis test.
        public struct HypothesisTestResult: Equatable, Sendable {
            /// The human-readable method name.
            public let method: String

            /// The test statistic.
            public let statistic: Double

            /// The p-value for the test.
            public let pValue: Double

            /// The confidence interval when the test produces one.
            public let confidenceInterval: ConfidenceInterval?

            /// The primary degrees of freedom when the test has one.
            public let degreesOfFreedom: Double?

            /// The denominator degrees of freedom for F-like tests.
            public let denominatorDegreesOfFreedom: Double?

            /// A standardized effect-size estimate when available.
            public let effectSize: Double?

            /// Creates a hypothesis test result.
            public init(
                method: String,
                statistic: Double,
                pValue: Double,
                confidenceInterval: ConfidenceInterval? = nil,
                degreesOfFreedom: Double? = nil,
                denominatorDegreesOfFreedom: Double? = nil,
                effectSize: Double? = nil
            ) {
                self.method = method
                self.statistic = statistic
                self.pValue = pValue
                self.confidenceInterval = confidenceInterval
                self.degreesOfFreedom = degreesOfFreedom
                self.denominatorDegreesOfFreedom = denominatorDegreesOfFreedom
                self.effectSize = effectSize
            }
        }

        /// Performs Welch's two-sample t-test.
        ///
        /// - Parameters:
        ///   - sampleA: The first independent sample.
        ///   - sampleB: The second independent sample.
        ///   - alternative: The alternative hypothesis direction.
        ///   - confidenceLevel: The confidence level for the mean-difference interval.
        /// - Returns: The test result, or `nil` when the test is undefined.
        public static func welchTTest(
            _ sampleA: Tensor<Double>,
            _ sampleB: Tensor<Double>,
            alternative: AlternativeHypothesis = .twoSided,
            confidenceLevel: Double = 0.95
        ) -> HypothesisTestResult? {
            guard sampleA.count > 1,
                  sampleB.count > 1,
                  let meanA = Numerica.Statistics.mean(sampleA),
                  let meanB = Numerica.Statistics.mean(sampleB),
                  let varianceA = Numerica.Statistics.sampleVariance(sampleA),
                  let varianceB = Numerica.Statistics.sampleVariance(sampleB),
                  isValidConfidenceLevel(confidenceLevel) else { return nil }

            let sampleCountA = Double(sampleA.count)
            let sampleCountB = Double(sampleB.count)
            let standardErrorSquared = varianceA / sampleCountA + varianceB / sampleCountB
            guard standardErrorSquared > 0 else { return nil }

            let standardError = standardErrorSquared.squareRoot()
            let estimate = meanA - meanB
            let statistic = estimate / standardError
            let degreesOfFreedomNumerator = standardErrorSquared * standardErrorSquared
            let degreesOfFreedomDenominator =
                (varianceA * varianceA) / (sampleCountA * sampleCountA * Double(sampleA.count - 1))
                + (varianceB * varianceB) / (sampleCountB * sampleCountB * Double(sampleB.count - 1))
            guard degreesOfFreedomDenominator > 0 else { return nil }

            let degreesOfFreedom = degreesOfFreedomNumerator / degreesOfFreedomDenominator
            let confidenceInterval = meanDifferenceConfidenceInterval(
                estimate: estimate,
                standardError: standardError,
                degreesOfFreedom: degreesOfFreedom,
                confidenceLevel: confidenceLevel
            )
            let pooledScale = ((varianceA + varianceB) / 2).squareRoot()

            return .init(
                method: "Welch two-sample t-test",
                statistic: statistic,
                pValue: tTestPValue(
                    statistic: statistic,
                    degreesOfFreedom: degreesOfFreedom,
                    alternative: alternative
                ),
                confidenceInterval: confidenceInterval,
                degreesOfFreedom: degreesOfFreedom,
                effectSize: pooledScale > 0 ? estimate / pooledScale : nil
            )
        }

        /// Performs a paired t-test.
        ///
        /// - Parameters:
        ///   - sampleA: The first paired sample.
        ///   - sampleB: The second paired sample.
        ///   - alternative: The alternative hypothesis direction.
        ///   - confidenceLevel: The confidence level for the mean-difference interval.
        /// - Returns: The test result, or `nil` when the test is undefined.
        public static func pairedTTest(
            _ sampleA: Tensor<Double>,
            _ sampleB: Tensor<Double>,
            alternative: AlternativeHypothesis = .twoSided,
            confidenceLevel: Double = 0.95
        ) -> HypothesisTestResult? {
            guard sampleA.count == sampleB.count,
                  sampleA.count > 1,
                  isValidConfidenceLevel(confidenceLevel) else { return nil }

            let differences = Tensor.vector(zip(sampleA.values, sampleB.values).map { $0 - $1 })
            guard let differenceMean = Numerica.Statistics.mean(differences),
                  let differenceStandardDeviation = Numerica.Statistics.sampleStandardDeviation(differences),
                  differenceStandardDeviation > 0 else { return nil }

            let standardError = differenceStandardDeviation / Double(differences.count).squareRoot()
            let statistic = differenceMean / standardError
            let degreesOfFreedom = Double(differences.count - 1)
            let confidenceInterval = meanDifferenceConfidenceInterval(
                estimate: differenceMean,
                standardError: standardError,
                degreesOfFreedom: degreesOfFreedom,
                confidenceLevel: confidenceLevel
            )

            return .init(
                method: "Paired t-test",
                statistic: statistic,
                pValue: tTestPValue(
                    statistic: statistic,
                    degreesOfFreedom: degreesOfFreedom,
                    alternative: alternative
                ),
                confidenceInterval: confidenceInterval,
                degreesOfFreedom: degreesOfFreedom,
                effectSize: differenceMean / differenceStandardDeviation
            )
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
        public static func chiSquareGoodnessOfFit(
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
            let total = observed.values.reduce(0, +)

            return .init(
                method: "Chi-square goodness-of-fit test",
                statistic: statistic,
                pValue: chiSquareUpperTail(statistic: statistic, degreesOfFreedom: degreesOfFreedom),
                degreesOfFreedom: degreesOfFreedom,
                effectSize: total > 0 ? (statistic / total).squareRoot() : nil
            )
        }

        /// Performs a one-way analysis of variance.
        ///
        /// - Parameter groups: Independent samples, one tensor per group.
        /// - Returns: The test result, or `nil` when the test is undefined.
        public static func oneWayANOVA(_ groups: [Tensor<Double>]) -> HypothesisTestResult? {
            guard groups.count > 1,
                  groups.allSatisfy({ !$0.values.isEmpty }) else { return nil }

            let totalCount = groups.reduce(0) { $0 + $1.count }
            guard totalCount > groups.count else { return nil }

            let allValues = groups.flatMap(\.values)
            let grandMean = allValues.reduce(0, +) / Double(totalCount)

            var betweenGroupSumSquares = 0.0
            var withinGroupSumSquares = 0.0

            for group in groups {
                guard let groupMean = Numerica.Statistics.mean(group) else { return nil }
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
            let totalSumSquares = betweenGroupSumSquares + withinGroupSumSquares

            return .init(
                method: "One-way ANOVA",
                statistic: statistic,
                pValue: fUpperTail(
                    statistic: statistic,
                    numeratorDegreesOfFreedom: betweenDegreesOfFreedom,
                    denominatorDegreesOfFreedom: withinDegreesOfFreedom
                ),
                degreesOfFreedom: betweenDegreesOfFreedom,
                denominatorDegreesOfFreedom: withinDegreesOfFreedom,
                effectSize: totalSumSquares > 0 ? betweenGroupSumSquares / totalSumSquares : nil
            )
        }

        /// Performs a Mann-Whitney U test.
        ///
        /// - Parameters:
        ///   - sampleA: The first independent sample.
        ///   - sampleB: The second independent sample.
        ///   - alternative: The alternative hypothesis direction.
        /// - Returns: The test result, or `nil` when the test is undefined.
        public static func mannWhitneyU(
            _ sampleA: Tensor<Double>,
            _ sampleB: Tensor<Double>,
            alternative: AlternativeHypothesis = .twoSided
        ) -> HypothesisTestResult? {
            guard !sampleA.values.isEmpty, !sampleB.values.isEmpty else { return nil }

            let leftCount = Double(sampleA.count)
            let rightCount = Double(sampleB.count)
            let ranked = rankedSamples(sampleA.values, sampleB.values)
            let leftRankSum = ranked.ranks.enumerated().reduce(0.0) { partialResult, pair in
                ranked.sampleIndexes[pair.offset] == 0 ? partialResult + pair.element : partialResult
            }

            let leftU = leftRankSum - leftCount * (leftCount + 1) / 2
            let rightU = leftCount * rightCount - leftU
            let meanU = leftCount * rightCount / 2
            let varianceU = mannWhitneyVariance(
                leftCount: leftCount,
                rightCount: rightCount,
                tieCounts: ranked.tieCounts
            )
            guard varianceU > 0 else { return nil }

            return .init(
                method: "Mann-Whitney U test",
                statistic: leftU,
                pValue: mannWhitneyPValue(
                    leftU: leftU,
                    rightU: rightU,
                    meanU: meanU,
                    standardDeviationU: varianceU.squareRoot(),
                    alternative: alternative
                ),
                effectSize: 2 * leftU / (leftCount * rightCount) - 1
            )
        }

        /// Performs a one-sample Kolmogorov-Smirnov goodness-of-fit test.
        ///
        /// The p-value uses the standard large-sample Kolmogorov approximation and
        /// is intended as a practical screening statistic.
        ///
        /// - Parameters:
        ///   - sample: The observed sample.
        ///   - distribution: The continuous distribution to compare against.
        /// - Returns: The test result, or `nil` for empty or non-finite data.
        public static func kolmogorovSmirnovTest<Distribution: Numerica.Probability.ContinuousDistribution>(
            _ sample: Tensor<Double>,
            distribution: Distribution
        ) -> HypothesisTestResult? {
            guard !sample.values.isEmpty,
                  sample.values.allSatisfy(\.isFinite) else { return nil }

            let values = sample.values.sorted()
            let sampleSize = values.count
            var statistic = 0.0
            for (index, value) in values.enumerated() {
                let cdf = distribution.cdf(value)
                guard cdf.isFinite, (0...1).contains(cdf) else { return nil }

                let empiricalUpper = Double(index + 1) / Double(sampleSize)
                let empiricalLower = Double(index) / Double(sampleSize)
                statistic = Swift.max(statistic, empiricalUpper - cdf, cdf - empiricalLower)
            }

            return .init(
                method: "One-sample Kolmogorov-Smirnov test",
                statistic: statistic,
                pValue: kolmogorovPValue(statistic: statistic, sampleSize: sampleSize)
            )
        }

        private static func isValidConfidenceLevel(_ confidenceLevel: Double) -> Bool {
            confidenceLevel > 0 && confidenceLevel < 1
        }

        private static func tTestPValue(
            statistic: Double,
            degreesOfFreedom: Double,
            alternative: AlternativeHypothesis
        ) -> Double {
            let distribution = studentTCDF(statistic, degreesOfFreedom: degreesOfFreedom)
            switch alternative {
            case .twoSided:
                let tail = statistic >= 0 ? 1 - distribution : distribution
                return clampedProbability(2 * tail)
            case .less:
                return clampedProbability(distribution)
            case .greater:
                return clampedProbability(1 - distribution)
            }
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

        private static func mannWhitneyPValue(
            leftU: Double,
            rightU: Double,
            meanU: Double,
            standardDeviationU: Double,
            alternative: AlternativeHypothesis
        ) -> Double {
            switch alternative {
            case .twoSided:
                let statistic = Swift.min(leftU, rightU)
                let zStatistic = (statistic - meanU + 0.5) / standardDeviationU
                let cdf = ProbabilityMath.normalCDFStandardized(zStatistic)
                return clampedProbability(2 * Swift.min(cdf, 1 - cdf))
            case .less:
                let zStatistic = (leftU - meanU + 0.5) / standardDeviationU
                return clampedProbability(ProbabilityMath.normalCDFStandardized(zStatistic))
            case .greater:
                let zStatistic = (leftU - meanU - 0.5) / standardDeviationU
                return clampedProbability(1 - ProbabilityMath.normalCDFStandardized(zStatistic))
            }
        }

        private static func kolmogorovPValue(statistic: Double, sampleSize: Int) -> Double {
            guard statistic > 0, sampleSize > 0 else { return 1 }

            let rootSampleSize = Double(sampleSize).squareRoot()
            let lambda = (rootSampleSize + 0.12 + 0.11 / rootSampleSize) * statistic
            var sum = 0.0

            for term in 1...100 {
                let sign = term.isMultiple(of: 2) ? -1.0 : 1.0
                let exponent = -2 * Double(term * term) * lambda * lambda
                let contribution = 2 * sign * Foundation.exp(exponent)
                sum += contribution

                if abs(contribution) < 1e-12 { break }
            }

            return clampedProbability(sum)
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

        private static func clampedProbability(_ value: Double) -> Double {
            Swift.min(1, Swift.max(0, value))
        }
    }
}

/// Statistical hypothesis tests.
public typealias HypothesisTesting = Numerica.Statistics.HypothesisTesting

/// Direction of the alternative hypothesis.
public typealias AlternativeHypothesis = Numerica.Statistics.HypothesisTesting.AlternativeHypothesis

/// A confidence interval around an estimated value.
public typealias ConfidenceInterval = Numerica.Statistics.HypothesisTesting.ConfidenceInterval

/// The result of a statistical hypothesis test.
public typealias HypothesisTestResult = Numerica.Statistics.HypothesisTesting.HypothesisTestResult
