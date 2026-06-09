import Foundation

public extension Numerica.Probability {
    /// A normal probability distribution.
    struct NormalDistribution: Sendable {
        /// The mean of the distribution.
        public let mean: Double

        /// The standard deviation of the distribution.
        public let standardDeviation: Double

        /// Creates a normal distribution.
        ///
        /// - Returns: `nil` when `standardDeviation` is not positive.
        public init?(mean: Double = 0, standardDeviation: Double = 1) {
            guard standardDeviation > 0 else { return nil }
            self.mean = mean
            self.standardDeviation = standardDeviation
        }

        /// Evaluates the probability density function.
        public func pdf(_ value: Double) -> Double {
            let z = (value - mean) / standardDeviation
            return Foundation.exp(-0.5 * z * z) / (standardDeviation * ProbabilityMath.squareRootOfTwoPi)
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Double) -> Double {
            ProbabilityMath.normalCDFStandardized((value - mean) / standardDeviation)
        }

        /// Evaluates probability density at a value.
        public func probability(at value: Double) -> Double {
            pdf(value)
        }
    }
}

extension Numerica.Probability.NormalDistribution: Numerica.Probability.ContinuousDistribution {}
