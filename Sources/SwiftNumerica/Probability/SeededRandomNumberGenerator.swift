public extension Numerica.Probability {
    /// A deterministic random number generator for reproducible sampling and
    /// simulation.
    ///
    /// The generator implements SplitMix64: the same seed always produces the
    /// same sequence, which makes distribution sampling, Monte Carlo runs, and
    /// random walks repeatable across processes and platforms.
    ///
    /// ```swift
    /// var generator = SeededRandomNumberGenerator(seed: 42)
    /// let normal = Numerica.Probability.NormalDistribution()
    /// let reproducible = normal?.sample(count: 100, using: &generator)
    /// ```
    ///
    /// SplitMix64 is statistically solid for numerical work but is not a
    /// cryptographically secure generator.
    struct SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
        private var state: UInt64

        /// Creates a generator with a seed that fully determines the sequence.
        public init(seed: UInt64) {
            self.state = seed
        }

        public mutating func next() -> UInt64 {
            state &+= 0x9E3779B97F4A7C15
            var mixed = state
            mixed = (mixed ^ (mixed >> 30)) &* 0xBF58476D1CE4E5B9
            mixed = (mixed ^ (mixed >> 27)) &* 0x94D049BB133111EB
            return mixed ^ (mixed >> 31)
        }
    }
}

/// A deterministic SplitMix64 random number generator for reproducible
/// sampling and simulation.
public typealias SeededRandomNumberGenerator = Numerica.Probability.SeededRandomNumberGenerator
