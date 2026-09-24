import Foundation

public extension Numerica.Probability {
    /// A finite Zipf-Mandelbrot distribution over integer ranks `1...numberOfRanks`.
    ///
    /// Its probability mass is proportional to `1 / (rank + offset)^exponent`.
    struct ZipfMandelbrotDistribution: Sendable {
        /// The number of ranked outcomes in the distribution.
        public let numberOfRanks: Int

        /// The power-law exponent, usually denoted `s`.
        public let exponent: Double

        /// The rank offset, usually denoted `q`.
        public let offset: Double

        /// The normalizing constant `C` such that `pmf(rank) = C / (rank + q)^s`.
        public let normalizationConstant: Double

        private let probabilities: [Double]

        /// The analytical mean rank.
        public var mean: Double {
            probabilities.enumerated().reduce(0) { $0 + Double($1.offset + 1) * $1.element }
        }

        /// The analytical variance of the rank.
        public var variance: Double {
            let distributionMean = mean
            return probabilities.enumerated().reduce(0) { total, item in
                let delta = Double(item.offset + 1) - distributionMean
                return total + delta * delta * item.element
            }
        }

        /// Creates a finite Zipf-Mandelbrot distribution.
        ///
        /// - Parameters:
        ///   - numberOfRanks: The number of supported ranks, starting at `1`.
        ///   - exponent: A finite positive power-law exponent.
        ///   - offset: A finite nonnegative rank offset.
        /// - Returns: `nil` when any parameter is invalid.
        public init?(numberOfRanks: Int, exponent: Double = 1, offset: Double = 0) {
            guard numberOfRanks > 0,
                  exponent.isFinite, exponent > 0,
                  offset.isFinite, offset >= 0 else { return nil }

            let base = 1 + offset
            let weights = (1...numberOfRanks).map { rank in
                Foundation.pow(base / (Double(rank) + offset), exponent)
            }
            let totalWeight = weights.reduce(0, +)
            let normalizationConstant = Foundation.pow(base, exponent) / totalWeight
            guard totalWeight.isFinite,
                  totalWeight > 0,
                  normalizationConstant.isFinite,
                  normalizationConstant > 0 else { return nil }

            self.numberOfRanks = numberOfRanks
            self.exponent = exponent
            self.offset = offset
            self.normalizationConstant = normalizationConstant
            self.probabilities = weights.map { $0 / totalWeight }
        }

        /// Evaluates probability mass at a rank. Ranks outside the support have zero mass.
        public func pmf(_ rank: Int) -> Double {
            guard (1...numberOfRanks).contains(rank) else { return 0 }
            return probabilities[rank - 1]
        }

        /// Evaluates cumulative probability through `rank`.
        public func cdf(_ rank: Int) -> Double {
            guard rank >= 1 else { return 0 }
            guard rank < numberOfRanks else { return 1 }
            return probabilities.prefix(rank).reduce(0, +)
        }

        /// Returns the smallest supported rank whose cumulative probability reaches `probability`.
        public func inverseCDF(_ probability: Double) -> Int? {
            guard probability.isFinite, (0...1).contains(probability) else { return nil }
            if probability == 0 { return 1 }

            var cumulative = 0.0
            for (index, mass) in probabilities.enumerated() {
                cumulative += mass
                if cumulative >= probability { return index + 1 }
            }
            return numberOfRanks
        }

        /// Returns the probability mass at a numeric rank; non-integers have zero mass.
        public func probability(at value: Double) -> Double {
            guard value.isFinite,
                  value.rounded() == value,
                  value >= 1,
                  value <= Double(numberOfRanks) else { return 0 }
            return pmf(Int(value))
        }

        /// Draws a rank using the supplied random number generator.
        public func sample<T: RandomNumberGenerator>(using generator: inout T) -> Int {
            inverseCDF(Double.random(in: 0..<1, using: &generator)) ?? numberOfRanks
        }
    }
}

extension Numerica.Probability.ZipfMandelbrotDistribution: Numerica.Probability.DiscreteDistribution {}
