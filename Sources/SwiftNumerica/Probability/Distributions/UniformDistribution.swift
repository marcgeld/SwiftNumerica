public extension Numerica.Probability {
    /// A continuous uniform probability distribution.
    struct UniformDistribution: Sendable {
        /// The lower bound.
        public let lowerBound: Double

        /// The upper bound.
        public let upperBound: Double

        /// Creates a uniform distribution.
        ///
        /// - Returns: `nil` when `upperBound` is not greater than `lowerBound`.
        public init?(lowerBound: Double = 0, upperBound: Double = 1) {
            guard upperBound > lowerBound else { return nil }
            self.lowerBound = lowerBound
            self.upperBound = upperBound
        }

        /// Evaluates the probability density function.
        public func pdf(_ value: Double) -> Double {
            guard value >= lowerBound, value <= upperBound else { return 0 }
            return 1 / (upperBound - lowerBound)
        }

        /// Evaluates the cumulative distribution function.
        public func cdf(_ value: Double) -> Double {
            if value <= lowerBound { return 0 }
            if value >= upperBound { return 1 }
            return (value - lowerBound) / (upperBound - lowerBound)
        }

        /// Evaluates probability density at a value.
        public func probability(at value: Double) -> Double {
            pdf(value)
        }
    }
}

extension Numerica.Probability.UniformDistribution: Numerica.Probability.ContinuousDistribution {}
