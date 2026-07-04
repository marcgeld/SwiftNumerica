public extension Tensor where Scalar == Double {
    /// Returns the sum of the tensor values.
    func sum() -> Double? {
        Numerica.Statistics.sum(self)
    }

    /// Returns the minimum tensor value.
    func min() -> Double? {
        Numerica.Statistics.min(self)
    }

    /// Returns the maximum tensor value.
    func max() -> Double? {
        Numerica.Statistics.max(self)
    }

    /// Returns the arithmetic mean of the tensor values.
    func mean() -> Double? {
        Numerica.Statistics.mean(self)
    }

    /// Returns the median of the tensor values.
    func median() -> Double? {
        Numerica.Statistics.median(self)
    }

    /// Returns the mode values of the tensor.
    func mode() -> [Double] {
        Numerica.Statistics.mode(self)
    }

    /// Returns the statistical range of the tensor values.
    func range() -> Double? {
        Numerica.Statistics.range(self)
    }

    /// Returns the sample variance of the tensor values.
    func variance() -> Double? {
        Numerica.Statistics.variance(self)
    }

    /// Returns the population variance of the tensor values.
    func populationVariance() -> Double? {
        Numerica.Statistics.populationVariance(self)
    }

    /// Returns the sample variance of the tensor values.
    func sampleVariance() -> Double? {
        Numerica.Statistics.sampleVariance(self)
    }

    /// Returns the sample standard deviation of the tensor values.
    func standardDeviation() -> Double? {
        Numerica.Statistics.standardDeviation(self)
    }

    /// Returns the population standard deviation of the tensor values.
    func populationStandardDeviation() -> Double? {
        Numerica.Statistics.populationStandardDeviation(self)
    }

    /// Returns the sample standard deviation of the tensor values.
    func sampleStandardDeviation() -> Double? {
        Numerica.Statistics.sampleStandardDeviation(self)
    }

    /// Returns the population skewness of the tensor values.
    func skewness() -> Double? {
        Numerica.Statistics.skewness(self)
    }

    /// Returns the excess population kurtosis of the tensor values.
    func kurtosis() -> Double? {
        Numerica.Statistics.kurtosis(self)
    }

    /// Returns a linearly interpolated quantile of the tensor values.
    func quantile(_ probability: Double) -> Double? {
        Numerica.Statistics.quantile(self, probability: probability)
    }

    /// Returns a percentile of the tensor values.
    func percentile(_ percentile: Double) -> Double? {
        Numerica.Statistics.percentile(self, percentile: percentile)
    }

    /// Returns the interquartile range of the tensor values.
    func interquartileRange() -> Double? {
        Numerica.Statistics.interquartileRange(self)
    }

    /// Returns the sample covariance with another tensor.
    func covariance(with other: Tensor<Double>) -> Double? {
        Numerica.Statistics.covariance(self, other)
    }

    /// Returns the population covariance with another tensor.
    func populationCovariance(with other: Tensor<Double>) -> Double? {
        Numerica.Statistics.populationCovariance(self, other)
    }

    /// Returns the sample covariance with another tensor.
    func sampleCovariance(with other: Tensor<Double>) -> Double? {
        Numerica.Statistics.sampleCovariance(self, other)
    }

    /// Returns the Pearson correlation coefficient with another tensor.
    func correlation(with other: Tensor<Double>) -> Double? {
        Numerica.Statistics.correlation(self, other)
    }
}
