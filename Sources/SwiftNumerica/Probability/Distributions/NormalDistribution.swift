import Foundation

public extension Numerica.Probability {
    /// A normal probability distribution.
    struct NormalDistribution: Sendable {
        /// The mean of the distribution.
        public let mean: Double

        /// The standard deviation of the distribution.
        public let standardDeviation: Double

        /// The analytical variance of the distribution.
        public var variance: Double {
            standardDeviation * standardDeviation
        }

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

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Double? {
            ProbabilityMath.inverseNormalCDFStandardized(probability).map {
                mean + standardDeviation * $0
            }
        }

        /// Evaluates probability density at a value.
        public func probability(at value: Double) -> Double {
            pdf(value)
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Double {
            mean + standardDeviation * ProbabilityMath.standardNormalSample(using: &generator)
        }
    }
}

extension Numerica.Probability.NormalDistribution: Numerica.Probability.ContinuousDistribution {}
