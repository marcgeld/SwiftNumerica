import Foundation

public extension Numerica.Probability {
    /// A Poisson probability distribution.
    struct PoissonDistribution: Sendable {
        /// The expected event rate.
        public let lambda: Double

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

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }
    }
}

extension Numerica.Probability.PoissonDistribution: Numerica.Probability.DiscreteDistribution {}
