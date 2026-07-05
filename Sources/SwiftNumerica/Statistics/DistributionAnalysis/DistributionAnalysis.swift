import Foundation

public extension Numerica.Statistics {
    /// Distribution fitting and goodness-of-fit routines.
    enum DistributionAnalysis {
        /// Result from a one-sample continuous goodness-of-fit test.
        public struct ContinuousGoodnessOfFitResult: Equatable, Sendable {
            /// The test statistic.
            public let statistic: Double

            /// The asymptotic p-value.
            public let pValue: Double

            /// The number of sample values used by the test.
            public let sampleSize: Int

            /// Creates a goodness-of-fit result.
            public init(statistic: Double, pValue: Double, sampleSize: Int) {
                self.statistic = statistic
                self.pValue = pValue
                self.sampleSize = sampleSize
            }
        }

        /// Fits a normal distribution using maximum-likelihood estimates.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: A normal distribution, or `nil` for empty, non-finite, or constant data.
        public static func fitNormal(_ sample: Tensor<Double>) -> Numerica.Probability.NormalDistribution? {
            guard finiteValues(sample) != nil,
                  let mean = Numerica.Statistics.mean(sample),
                  let variance = Numerica.Statistics.populationVariance(sample),
                  variance > 0 else { return nil }

            return Numerica.Probability.NormalDistribution(
                mean: mean,
                standardDeviation: variance.squareRoot()
            )
        }

        /// Fits a uniform distribution using the observed minimum and maximum.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: A uniform distribution, or `nil` for empty, non-finite, or constant data.
        public static func fitUniform(_ sample: Tensor<Double>) -> Numerica.Probability.UniformDistribution? {
            guard let values = finiteValues(sample),
                  let minimum = values.min(),
                  let maximum = values.max(),
                  maximum > minimum else { return nil }

            return Numerica.Probability.UniformDistribution(lowerBound: minimum, upperBound: maximum)
        }

        /// Fits an exponential distribution using the maximum-likelihood rate estimate.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: An exponential distribution, or `nil` when values are negative, non-finite, or mean zero.
        public static func fitExponential(_ sample: Tensor<Double>) -> Numerica.Probability.ExponentialDistribution? {
            guard let values = finiteValues(sample),
                  values.allSatisfy({ $0 >= 0 }),
                  let mean = Numerica.Statistics.mean(sample),
                  mean > 0 else { return nil }

            return Numerica.Probability.ExponentialDistribution(rate: 1 / mean)
        }

        /// Performs a one-sample Kolmogorov-Smirnov goodness-of-fit test.
        ///
        /// The p-value uses the standard large-sample Kolmogorov approximation and
        /// is intended as a practical screening statistic.
        ///
        /// - Parameters:
        ///   - sample: The observed sample.
        ///   - distribution: The continuous distribution to compare against.
        /// - Returns: A goodness-of-fit result, or `nil` for empty or non-finite data.
        public static func kolmogorovSmirnovTest<Distribution: Numerica.Probability.ContinuousDistribution>(
            _ sample: Tensor<Double>,
            distribution: Distribution
        ) -> ContinuousGoodnessOfFitResult? {
            guard let values = finiteValues(sample)?.sorted() else { return nil }

            let sampleSize = values.count
            var statistic = 0.0
            for (index, value) in values.enumerated() {
                let cdf = distribution.cdf(value)
                guard cdf.isFinite, (0...1).contains(cdf) else { return nil }

                let empiricalUpper = Double(index + 1) / Double(sampleSize)
                let empiricalLower = Double(index) / Double(sampleSize)
                statistic = Swift.max(statistic, empiricalUpper - cdf, cdf - empiricalLower)
            }

            return ContinuousGoodnessOfFitResult(
                statistic: statistic,
                pValue: kolmogorovPValue(statistic: statistic, sampleSize: sampleSize),
                sampleSize: sampleSize
            )
        }

        private static func finiteValues(_ sample: Tensor<Double>) -> [Double]? {
            guard !sample.values.isEmpty,
                  sample.values.allSatisfy(\.isFinite) else { return nil }
            return sample.values
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

            return Swift.min(1, Swift.max(0, sum))
        }
    }
}
