import Foundation

public extension Numerica.Probability {
    /// A Poisson probability distribution.
    struct PoissonDistribution: Sendable {
        /// The expected event rate.
        public let lambda: Double

        /// The analytical mean of the distribution.
        public var mean: Double {
            lambda
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            lambda
        }

        /// Creates a Poisson distribution.
        ///
        /// - Returns: `nil` when `lambda` is not positive.
        public init?(lambda: Double) {
            guard lambda > 0 else { return nil }
            self.lambda = lambda
        }

        /// Evaluates the probability mass function.
        public func pmf(_ value: Int) -> Double {
            guard value >= 0,
                  let factorial = ProbabilityMath.factorial(value) else { return 0 }
            return Foundation.exp(-lambda) * Foundation.pow(lambda, Double(value)) / factorial
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Int) -> Double {
            guard value >= 0 else { return 0 }
            return (0...value).map(pmf).reduce(0, +)
        }

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Int? {
            guard (0...1).contains(probability) else { return nil }
            if probability == 0 { return 0 }
            if probability == 1 { return nil }

            var value = 0
            var mass = Foundation.exp(-lambda)
            var cumulative = mass
            while cumulative < probability {
                value += 1
                mass *= lambda / Double(value)
                cumulative += mass
            }
            return value
        }

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Int {
            let threshold = Foundation.exp(-lambda)
            var product = 1.0
            var count = 0

            repeat {
                count += 1
                product *= Double.random(in: 0..<1, using: &generator)
            } while product > threshold

            return count - 1
        }
    }
}

extension Numerica.Probability.PoissonDistribution: Numerica.Probability.DiscreteDistribution {}
