import Foundation

public extension Numerica.Probability {
    /// A beta probability distribution over the closed interval `0...1`.
    struct BetaDistribution: Sendable {
        /// The alpha shape parameter.
        public let alpha: Double

        /// The beta shape parameter.
        public let beta: Double

        /// The analytical mean of the distribution.
        public var mean: Double {
            alpha / (alpha + beta)
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            alpha * beta / ((alpha + beta) * (alpha + beta) * (alpha + beta + 1))
        }

        /// Creates a beta distribution.
        ///
        /// - Returns: `nil` when `alpha` or `beta` is not positive.
        public init?(alpha: Double, beta: Double) {
            guard alpha > 0, beta > 0 else { return nil }
            self.alpha = alpha
            self.beta = beta
        }

        /// Evaluates the probability density function.
        public func pdf(_ value: Double) -> Double {
            guard (0...1).contains(value) else { return 0 }
            if value == 0 {
                if alpha == 1 { return beta }
                return alpha < 1 ? .infinity : 0
            }
            if value == 1 {
                if beta == 1 { return alpha }
                return beta < 1 ? .infinity : 0
            }

            let logDensity = (alpha - 1) * Foundation.log(value)
                + (beta - 1) * Foundation.log1p(-value)
                + ProbabilityMath.logGamma(alpha + beta)
                - ProbabilityMath.logGamma(alpha)
                - ProbabilityMath.logGamma(beta)
            return Foundation.exp(logDensity)
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Double) -> Double {
            ProbabilityMath.regularizedBeta(x: value, alpha: alpha, beta: beta)
        }

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Double? {
            guard (0...1).contains(probability) else { return nil }
            if probability == 0 { return 0 }
            if probability == 1 { return 1 }

            var lower = 0.0
            var upper = 1.0
            for _ in 0..<100 {
                let midpoint = (lower + upper) / 2
                if cdf(midpoint) < probability {
                    lower = midpoint
                } else {
                    upper = midpoint
                }
            }
            return (lower + upper) / 2
        }

        /// Evaluates probability density at a value.
        public func probability(at value: Double) -> Double {
            pdf(value)
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Double {
            let left = ProbabilityMath.gammaSample(shape: alpha, scale: 1, using: &generator)
            let right = ProbabilityMath.gammaSample(shape: beta, scale: 1, using: &generator)
            return left / (left + right)
        }
    }
}

extension Numerica.Probability.BetaDistribution: Numerica.Probability.ContinuousDistribution {}
