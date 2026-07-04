import Foundation

public extension Numerica.Probability {
    /// A binomial probability distribution.
    struct BinomialDistribution: Sendable {
        /// The number of trials.
        public let trials: Int

        /// The success probability for each trial.
        public let probabilityOfSuccess: Double

        /// The analytical mean of the distribution.
        public var mean: Double {
            Double(trials) * probabilityOfSuccess
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            Double(trials) * probabilityOfSuccess * (1 - probabilityOfSuccess)
        }

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

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Int? {
            guard (0...1).contains(probability) else { return nil }
            if probability == 0 { return 0 }
            if probability == 1 { return trials }

            var cumulative = 0.0
            for value in 0...trials {
                cumulative += pmf(value)
                if cumulative >= probability {
                    return value
                }
            }
            return trials
        }

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Int {
            guard trials > 0, probabilityOfSuccess > 0 else { return 0 }
            guard probabilityOfSuccess < 1 else { return trials }

            var successes = 0
            for _ in 0..<trials where Double.random(in: 0..<1, using: &generator) < probabilityOfSuccess {
                successes += 1
            }
            return successes
        }
    }
}

extension Numerica.Probability.BinomialDistribution: Numerica.Probability.DiscreteDistribution {}
