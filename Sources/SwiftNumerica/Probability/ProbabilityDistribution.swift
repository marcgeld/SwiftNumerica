public extension Numerica.Probability {
    /// A continuous probability distribution over `Double` values.
    protocol ContinuousDistribution: Sendable {
        /// The analytical mean of the distribution.
        var mean: Double { get }

        /// The analytical variance of the distribution.
        var variance: Double { get }

        /// Evaluates the probability density function at `value`.
        func pdf(_ value: Double) -> Double

        /// Evaluates the cumulative distribution function at `value`.
        func cdf(_ value: Double) -> Double

        /// Evaluates the inverse cumulative distribution function.
        func inverseCDF(_ probability: Double) -> Double?

        /// Draws a random sample from the distribution using `generator`.
        func sample<T: RandomNumberGenerator>(using generator: inout T) -> Double
    }

    /// A discrete probability distribution over integer outcomes.
    protocol DiscreteDistribution: Sendable {
        /// The analytical mean of the distribution.
        var mean: Double { get }

        /// The analytical variance of the distribution.
        var variance: Double { get }

        /// Evaluates the probability mass function at `value`.
        func pmf(_ value: Int) -> Double

        /// Evaluates the cumulative distribution function at `value`.
        func cdf(_ value: Int) -> Double

        /// Evaluates the inverse cumulative distribution function.
        func inverseCDF(_ probability: Double) -> Int?

        /// Draws a random sample from the distribution using `generator`.
        func sample<T: RandomNumberGenerator>(using generator: inout T) -> Int
    }
}

public extension Numerica.Probability.ContinuousDistribution {
    /// Draws a random sample from the distribution.
    func sample() -> Double {
        var generator = SystemRandomNumberGenerator()
        return sample(using: &generator)
    }

    /// Draws `count` random samples from the distribution.
    func sample(count: Int) -> [Double] {
        var generator = SystemRandomNumberGenerator()
        return sample(count: count, using: &generator)
    }

    /// Draws `count` random samples from the distribution using `generator`.
    func sample<T: RandomNumberGenerator>(count: Int, using generator: inout T) -> [Double] {
        guard count > 0 else { return [] }
        return (0..<count).map { _ in sample(using: &generator) }
    }
}

public extension Numerica.Probability.DiscreteDistribution {
    /// Draws a random sample from the distribution.
    func sample() -> Int {
        var generator = SystemRandomNumberGenerator()
        return sample(using: &generator)
    }

    /// Draws `count` random samples from the distribution.
    func sample(count: Int) -> [Int] {
        var generator = SystemRandomNumberGenerator()
        return sample(count: count, using: &generator)
    }

    /// Draws `count` random samples from the distribution using `generator`.
    func sample<T: RandomNumberGenerator>(count: Int, using generator: inout T) -> [Int] {
        guard count > 0 else { return [] }
        return (0..<count).map { _ in sample(using: &generator) }
    }
}
