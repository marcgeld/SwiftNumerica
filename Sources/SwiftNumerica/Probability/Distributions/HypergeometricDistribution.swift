public extension Numerica.Probability {
    /// A hypergeometric probability distribution.
    struct HypergeometricDistribution: Sendable {
        /// The total population size.
        public let populationSize: Int

        /// The number of success states in the population.
        public let successStates: Int

        /// The number of draws.
        public let draws: Int

        /// The analytical mean of the distribution.
        public var mean: Double {
            guard populationSize > 0 else { return 0 }
            return Double(draws) * Double(successStates) / Double(populationSize)
        }

        /// The analytical variance of the distribution.
        public var variance: Double {
            guard populationSize > 1 else { return 0 }
            let population = Double(populationSize)
            let successRatio = Double(successStates) / population
            return Double(draws) * successRatio * (1 - successRatio)
                * Double(populationSize - draws) / Double(populationSize - 1)
        }

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

        /// Evaluates the inverse cumulative distribution function.
        public func inverseCDF(_ probability: Double) -> Int? {
            guard (0...1).contains(probability) else { return nil }
            let lower = Swift.max(0, draws - (populationSize - successStates))
            let upper = Swift.min(successStates, draws)
            if probability == 0 { return lower }
            if probability == 1 { return upper }

            var cumulative = 0.0
            for value in lower...upper {
                cumulative += pmf(value)
                if cumulative >= probability {
                    return value
                }
            }
            return upper
        }

        /// Evaluates probability mass at a value.
        public func probability(at value: Double) -> Double {
            guard value.rounded() == value else { return 0 }
            return pmf(Int(value))
        }

        /// Draws a random sample from the distribution using `generator`.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Int {
            guard draws > 0, successStates > 0 else { return 0 }

            var remainingSuccesses = successStates
            var remainingPopulation = populationSize
            var sampledSuccesses = 0

            for _ in 0..<draws {
                let successProbability = Double(remainingSuccesses) / Double(remainingPopulation)
                if Double.random(in: 0..<1, using: &generator) < successProbability {
                    sampledSuccesses += 1
                    remainingSuccesses -= 1
                }
                remainingPopulation -= 1
            }

            return sampledSuccesses
        }
    }
}

extension Numerica.Probability.HypergeometricDistribution: Numerica.Probability.DiscreteDistribution {}
