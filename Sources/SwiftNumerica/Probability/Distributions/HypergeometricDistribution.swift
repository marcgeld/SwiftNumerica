public extension Numerica.Probability {
    /// A hypergeometric probability distribution.
    struct HypergeometricDistribution: Sendable {
        /// The total population size.
        public let populationSize: Int

        /// The number of success states in the population.
        public let successStates: Int

        /// The number of draws.
        public let draws: Int

        /// Creates a hypergeometric distribution.
        ///
        /// - Returns: `nil` when the population parameters are invalid.
        public init?(populationSize: Int, successStates: Int, draws: Int) {
            guard populationSize >= 0,
                  successStates >= 0,
                  draws >= 0,
                  successStates <= populationSize,
                  draws <= populationSize else { return nil }
            self.populationSize = populationSize
            self.successStates = successStates
            self.draws = draws
        }

        /// Evaluates the probability mass function.
        public func pmf(_ value: Int) -> Double {
            guard value >= 0,
                  value <= successStates,
                  draws - value <= populationSize - successStates,
                  let successes = ProbabilityMath.combinations(n: successStates, r: value),
                  let failures = ProbabilityMath.combinations(n: populationSize - successStates, r: draws - value),
                  let total = ProbabilityMath.combinations(n: populationSize, r: draws),
                  total != 0 else { return 0 }
            return successes * failures / total
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Int) -> Double {
            guard value >= 0 else { return 0 }
            let upper = Swift.min(value, Swift.min(successStates, draws))
            return (0...upper).map(pmf).reduce(0, +)
        }

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }
    }
}

extension Numerica.Probability.HypergeometricDistribution: Numerica.Probability.DiscreteDistribution {}
