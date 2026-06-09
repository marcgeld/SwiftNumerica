import Foundation

public extension Numerica.Probability {
    /// A binomial probability distribution.
    struct BinomialDistribution: Sendable {
        /// The number of trials.
        public let trials: Int

        /// The success probability for each trial.
        public let probabilityOfSuccess: Double

        /// Creates a binomial distribution.
        ///
        /// - Returns: `nil` when `trials` is negative or probability is outside `0...1`.
        public init?(trials: Int, probabilityOfSuccess: Double) {
            guard trials >= 0, (0...1).contains(probabilityOfSuccess) else { return nil }
            self.trials = trials
            self.probabilityOfSuccess = probabilityOfSuccess
        }

        /// Evaluates the probability mass function.
        public func pmf(_ value: Int) -> Double {
            guard value >= 0, value <= trials,
                  let combinations = ProbabilityMath.combinations(n: trials, r: value) else { return 0 }
            return combinations * Foundation.pow(probabilityOfSuccess, Double(value)) * Foundation.pow(1 - probabilityOfSuccess, Double(trials - value))
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Int) -> Double {
            guard value >= 0 else { return 0 }
            guard value < trials else { return 1 }
            return (0...value).map(pmf).reduce(0, +)
        }

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }
    }
}

extension Numerica.Probability.BinomialDistribution: Numerica.Probability.DiscreteDistribution {}
