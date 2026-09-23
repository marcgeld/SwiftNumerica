public extension Tensor where Scalar == Double {
    /// Returns the sum of the tensor values.
    func sum() throws -> Double? {
        try Numerica.Statistics.sum(self)
    }

    /// Returns the minimum tensor value.
    func min() throws -> Double? {
        try Numerica.Statistics.min(self)
    }

    /// Returns the maximum tensor value.
    func max() throws -> Double? {
        try Numerica.Statistics.max(self)
    }

    /// Returns the arithmetic mean of the tensor values.
    func mean() throws -> Double? {
        try Numerica.Statistics.mean(self)
    }

    /// Returns the median of the tensor values.
    func median() throws -> Double? {
        try Numerica.Statistics.median(self)
    }

    /// Returns the mode values of the tensor.
    func mode() throws -> [Double] {
        try Numerica.Statistics.mode(self)
    }

    /// Returns the statistical range of the tensor values.
    func range() throws -> Double? {
        try Numerica.Statistics.range(self)
    }

    /// Returns the sample variance of the tensor values.
    func variance() throws -> Double? {
        try Numerica.Statistics.variance(self)
    }

    /// Returns the population variance of the tensor values.
    func populationVariance() throws -> Double? {
        try Numerica.Statistics.populationVariance(self)
    }

    /// Returns the sample variance of the tensor values.
    func sampleVariance() throws -> Double? {
        try Numerica.Statistics.sampleVariance(self)
    }

    /// Returns the sample standard deviation of the tensor values.
    func standardDeviation() throws -> Double? {
        try Numerica.Statistics.standardDeviation(self)
    }

    /// Returns the population standard deviation of the tensor values.
    func populationStandardDeviation() throws -> Double? {
        try Numerica.Statistics.populationStandardDeviation(self)
    }

    /// Returns the sample standard deviation of the tensor values.
    func sampleStandardDeviation() throws -> Double? {
        try Numerica.Statistics.sampleStandardDeviation(self)
    }

    /// Estimates a two-sided confidence interval for the tensor's sample mean.
    ///
    /// Uses the Student's t distribution and requires at least two finite values.
    func meanConfidenceInterval(confidenceLevel: Double = 0.95) throws
        -> Numerica.Statistics.HypothesisTesting.ConfidenceInterval? {
        try Numerica.Statistics.HypothesisTesting.meanConfidenceInterval(
            self,
            confidenceLevel: confidenceLevel
        )
    }

    /// Returns the population skewness of the tensor values.
    func skewness() throws -> Double? {
        try Numerica.Statistics.skewness(self)
    }

    /// Returns the excess population kurtosis of the tensor values.
    func kurtosis() throws -> Double? {
        try Numerica.Statistics.kurtosis(self)
    }

    /// Returns a linearly interpolated quantile of the tensor values.
    func quantile(_ probability: Double) throws -> Double? {
        try Numerica.Statistics.quantile(self, probability: probability)
    }

    /// Returns a percentile of the tensor values.
    func percentile(_ percentile: Double) throws -> Double? {
        try Numerica.Statistics.percentile(self, percentile: percentile)
    }

    /// Returns the interquartile range of the tensor values.
    func interquartileRange() throws -> Double? {
        try Numerica.Statistics.interquartileRange(self)
    }

    /// Returns the sample covariance with another tensor.
    func covariance(with other: Tensor<Double>) throws -> Double? {
        try Numerica.Statistics.covariance(self, other)
    }

    /// Returns the population covariance with another tensor.
    func populationCovariance(with other: Tensor<Double>) throws -> Double? {
        try Numerica.Statistics.populationCovariance(self, other)
    }

    /// Returns the sample covariance with another tensor.
    func sampleCovariance(with other: Tensor<Double>) throws -> Double? {
        try Numerica.Statistics.sampleCovariance(self, other)
    }

    /// Returns the Pearson correlation coefficient with another tensor.
    func correlation(with other: Tensor<Double>) throws -> Double? {
        try Numerica.Statistics.correlation(self, other)
    }
}
