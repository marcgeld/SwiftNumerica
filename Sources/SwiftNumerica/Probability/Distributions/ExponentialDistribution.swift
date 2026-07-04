import Foundation

public extension Numerica.Probability {
    /// An exponential probability distribution.
    struct ExponentialDistribution: Sendable {
        /// The event rate.
        public let rate: Double

        /// The analytical mean of the distribution.
        public var mean: Double {
            1 / rate
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            1 / (rate * rate)
        }

        /// Creates an exponential distribution.
        ///
        /// - Returns: `nil` when `rate` is not positive.
        public init?(rate: Double) {
            guard rate > 0 else { return nil }
            self.rate = rate
        }

        /// Evaluates the probability density function.
        public func pdf(_ value: Double) -> Double {
            guard value >= 0 else { return 0 }
            return rate * Foundation.exp(-rate * value)
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Double) -> Double {
            guard value >= 0 else { return 0 }
            return 1 - Foundation.exp(-rate * value)
        }

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Double? {
            guard (0...1).contains(probability) else { return nil }
            if probability == 1 { return .infinity }
            return -Foundation.log1p(-probability) / rate
        }

        /// Evaluates probability density at a value.
        public func probability(at value: Double) -> Double {
            pdf(value)
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Double {
            let uniform = Double.random(in: Double.leastNonzeroMagnitude..<1, using: &generator)
            return -Foundation.log(uniform) / rate
        }
    }
}

extension Numerica.Probability.ExponentialDistribution: Numerica.Probability.ContinuousDistribution {}
