public extension Numerica.Statistics {
    /// Distribution fitting routines.
    enum DistributionAnalysis {
        /// Fits a normal distribution using maximum-likelihood estimates.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: A normal distribution, or `nil` for empty, non-finite, or constant data.
        public static func fitNormal(_ sample: Tensor<Double>) -> Numerica.Probability.NormalDistribution? {
            guard finiteValues(sample) != nil,
                  let mean = Numerica.Statistics.mean(sample),
                  let variance = Numerica.Statistics.populationVariance(sample),
                  variance > 0 else { return nil }

            return Numerica.Probability.NormalDistribution(
                mean: mean,
                standardDeviation: variance.squareRoot()
            )
        }

        /// Fits a uniform distribution using the observed minimum and maximum.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: A uniform distribution, or `nil` for empty, non-finite, or constant data.
        public static func fitUniform(_ sample: Tensor<Double>) -> Numerica.Probability.UniformDistribution? {
            guard let values = finiteValues(sample),
                  let minimum = values.min(),
                  let maximum = values.max(),
                  maximum > minimum else { return nil }

            return Numerica.Probability.UniformDistribution(lowerBound: minimum, upperBound: maximum)
        }

        /// Fits an exponential distribution using the maximum-likelihood rate estimate.
        ///
        /// - Parameter sample: The observed sample.
        /// - Returns: An exponential distribution, or `nil` when values are negative, non-finite, or mean zero.
        public static func fitExponential(_ sample: Tensor<Double>) -> Numerica.Probability.ExponentialDistribution? {
            guard let values = finiteValues(sample),
                  values.allSatisfy({ $0 >= 0 }),
                  let mean = Numerica.Statistics.mean(sample),
                  mean > 0 else { return nil }

            return Numerica.Probability.ExponentialDistribution(rate: 1 / mean)
        }

        private static func finiteValues(_ sample: Tensor<Double>) -> [Double]? {
            guard !sample.values.isEmpty,
                  sample.values.allSatisfy(\.isFinite) else { return nil }
            return sample.values
        }
    }
}
