import Foundation

public extension Numerica.Probability {
    /// A gamma probability distribution parameterized by shape and scale.
    struct GammaDistribution: Sendable {
        /// The shape parameter.
        public let shape: Double

        /// The scale parameter.
        public let scale: Double

        /// The analytical mean of the distribution.
        public var mean: Double {
            shape * scale
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            shape * scale * scale
        }

        /// Creates a gamma distribution.
        ///
        /// - Returns: `nil` when `shape` or `scale` is not positive.
        public init?(shape: Double, scale: Double = 1) {
            guard shape > 0, scale > 0 else { return nil }
            self.shape = shape
            self.scale = scale
        }

        /// Evaluates the probability density function.
        public func pdf(_ value: Double) -> Double {
            guard value >= 0 else { return 0 }
            if value == 0 {
                if shape == 1 { return 1 / scale }
                return shape < 1 ? .infinity : 0
            }

            let logDensity = (shape - 1) * Foundation.log(value)
                - value / scale
                - ProbabilityMath.logGamma(shape)
                - shape * Foundation.log(scale)
            return Foundation.exp(logDensity)
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Double) -> Double {
            guard value > 0 else { return 0 }
            return ProbabilityMath.regularizedLowerIncompleteGamma(shape: shape, x: value / scale)
        }

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Double? {
            guard (0...1).contains(probability) else { return nil }
            if probability == 0 { return 0 }
            if probability == 1 { return .infinity }

            var lower = 0.0
            var upper = Swift.max(mean, scale)
            while cdf(upper) < probability {
                upper *= 2
            }

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
            ProbabilityMath.gammaSample(shape: shape, scale: scale, using: &generator)
        }
    }
}

extension Numerica.Probability.GammaDistribution: Numerica.Probability.ContinuousDistribution {}
