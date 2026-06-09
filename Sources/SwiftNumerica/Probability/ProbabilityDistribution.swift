public extension Numerica.Probability {
    /// A continuous probability distribution over `Double` values.
    protocol ContinuousDistribution: Sendable {
        /// Evaluates the probability density function at `value`.
        func pdf(_ value: Double) -> Double

        /// Evaluates the cumulative distribution function at `value`.
        func cdf(_ value: Double) -> Double
    }

    /// A discrete probability distribution over integer outcomes.
    protocol DiscreteDistribution: Sendable {
        /// Evaluates the probability mass function at `value`.
        func pmf(_ value: Int) -> Double

        /// Evaluates the cumulative distribution function at `value`.
        func cdf(_ value: Int) -> Double
    }
}
