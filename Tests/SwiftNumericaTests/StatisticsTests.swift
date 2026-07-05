import Testing

@testable import SwiftNumerica

@Test func meanReturnsNilForEmptyTensor() {
    #expect(Numerica.Statistics.mean(.vector([])) == nil)
}

@Test func meanReturnsAverageForPositiveValues() throws {
    let mean = try #require(Numerica.Statistics.mean(.vector([1, 2, 3, 4])))
    #expect(mean.isApproximatelyEqual(to: 2.5))
}

@Test func pureSwiftAndAccelerateProduceSameMean() throws {
    let tensor = Tensor.vector([1, 2, 3, 4])
    Numerica.configuration.backend = .pureSwift
    let pureSwift = try #require(Numerica.Statistics.mean(tensor))
    #expect(pureSwift.isApproximatelyEqual(to: 2.5))

    Numerica.configuration.backend = .accelerate
    let accelerate = try #require(Numerica.Statistics.mean(tensor))
    #expect(
        pureSwift.isApproximatelyEqual(to: accelerate, tolerance: 1e-12)
    )
}

@Test func meanReturnsAverageForNegativeValues() throws {
    let mean = try #require(Numerica.Statistics.mean(.vector([-2, -4, -6])))
    #expect(mean.isApproximatelyEqual(to: -4))
}

@Test func meanReturnsAverageForDecimalValues() throws {
    let mean = try #require(Numerica.Statistics.mean(.vector([1.5, 2.5, 3.0])))
    #expect(mean.isApproximatelyEqual(to: 7.0 / 3.0))
}

@Test func medianReturnsMiddleValue() throws {
    let median = try #require(Numerica.Statistics.median(.vector([5, 1, 3])))
    #expect(median.isApproximatelyEqual(to: 3))
}

@Test func modeReturnsRepeatedValues() {
    #expect(Numerica.Statistics.mode(.vector([1, 2, 2, 3])) == [2])
}

@Test func rangeReturnsMaximumMinusMinimum() throws {
    let range = try #require(Numerica.Statistics.range(.vector([4, -2, 8, 1])))
    #expect(range.isApproximatelyEqual(to: 10))
}

@Test func sumMinAndMaxSummarizeTensorValues() throws {
    let tensor = Tensor.vector([4, -2, 8, 1])
    #expect(try #require(Numerica.Statistics.sum(tensor)).isApproximatelyEqual(to: 11))
    #expect(try #require(Numerica.Statistics.min(tensor)).isApproximatelyEqual(to: -2))
    #expect(try #require(Numerica.Statistics.max(tensor)).isApproximatelyEqual(to: 8))
}

@Test func populationVarianceUsesPopulationDenominator() throws {
    let variance = try #require(
        Numerica.Statistics.populationVariance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(variance.isApproximatelyEqual(to: 4))
}

@Test func sampleVarianceUsesSampleDenominator() throws {
    let variance = try #require(
        Numerica.Statistics.sampleVariance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(variance.isApproximatelyEqual(to: 32.0 / 7.0))
    let convenience = try #require(
        Numerica.Statistics.variance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(convenience.isApproximatelyEqual(to: variance))
}

@Test func populationStandardDeviationIsSquareRootOfPopulationVariance() throws {
    let standardDeviation = try #require(
        Numerica.Statistics.populationStandardDeviation(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(standardDeviation.isApproximatelyEqual(to: 2))
}

@Test func sampleStandardDeviationIsSquareRootOfSampleVariance() throws {
    let standardDeviation = try #require(
        Numerica.Statistics.sampleStandardDeviation(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(standardDeviation.isApproximatelyEqual(to: (32.0 / 7.0).squareRoot()))
    let convenience = try #require(
        Numerica.Statistics.standardDeviation(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(convenience.isApproximatelyEqual(to: standardDeviation))
}

@Test func skewnessOfSymmetricValuesIsZero() throws {
    let skewness = try #require(Numerica.Statistics.skewness(.vector([-1, 0, 1])))
    #expect(skewness.isApproximatelyEqual(to: 0))
}

@Test func kurtosisOfTwoPointDistributionIsNegativeTwo() throws {
    let kurtosis = try #require(Numerica.Statistics.kurtosis(.vector([-1, 1])))
    #expect(kurtosis.isApproximatelyEqual(to: -2))
}

@Test func quantileInterpolatesValues() throws {
    let quantile = try #require(Numerica.Statistics.quantile(.vector([0, 10]), probability: 0.25))
    #expect(quantile.isApproximatelyEqual(to: 2.5))
}

@Test func percentileUsesZeroToOneHundredScale() throws {
    let percentile = try #require(Numerica.Statistics.percentile(.vector([0, 10]), percentile: 25))
    #expect(percentile.isApproximatelyEqual(to: 2.5))
}

@Test func interquartileRangeReturnsUpperMinusLowerQuartile() throws {
    let iqr = try #require(Numerica.Statistics.interquartileRange(.vector([1, 2, 3, 4, 5])))
    #expect(iqr.isApproximatelyEqual(to: 2))
}

@Test func zScoreIsZeroWhenValueEqualsMean() throws {
    let zScore = try #require(Numerica.Statistics.zScore(value: 10, mean: 10, standardDeviation: 2))
    #expect(zScore.isApproximatelyEqual(to: 0))
}

@Test func zScoreIsPositiveWhenValueIsAboveMean() throws {
    let zScore = try #require(Numerica.Statistics.zScore(value: 14, mean: 10, standardDeviation: 2))
    #expect(zScore.isApproximatelyEqual(to: 2))
}

@Test func zScoreIsNegativeWhenValueIsBelowMean() throws {
    let zScore = try #require(Numerica.Statistics.zScore(value: 6, mean: 10, standardDeviation: 2))
    #expect(zScore.isApproximatelyEqual(to: -2))
}

@Test func pearsonCorrelationDetectsPerfectPositiveAssociation() throws {
    let correlation = try #require(
        Numerica.Statistics.pearsonCorrelation(.vector([1, 2, 3]), .vector([2, 4, 6])))
    #expect(correlation.isApproximatelyEqual(to: 1))
}

@Test func covarianceUsesExpectedDenominator() throws {
    let x = Tensor.vector([1, 2, 3])
    let y = Tensor.vector([2, 4, 6])
    let population = try #require(Numerica.Statistics.populationCovariance(x, y))
    let sample = try #require(Numerica.Statistics.sampleCovariance(x, y))

    #expect(population.isApproximatelyEqual(to: 4.0 / 3.0))
    #expect(sample.isApproximatelyEqual(to: 2))
    #expect(try #require(Numerica.Statistics.covariance(x, y)).isApproximatelyEqual(to: sample))
    #expect(try #require(Numerica.Statistics.correlation(x, y)).isApproximatelyEqual(to: 1))
}

@Test func spearmanCorrelationUsesRanks() throws {
    let correlation = try #require(
        Numerica.Statistics.spearmanCorrelation(.vector([10, 20, 30]), .vector([1, 2, 3])))
    #expect(correlation.isApproximatelyEqual(to: 1))
}

@Test func linearRegressionReturnsSlopeInterceptAndRSquared() throws {
    let result = try #require(
        Numerica.Statistics.linearRegression(x: .vector([1, 2, 3]), y: .vector([2, 4, 6])))
    #expect(result.slope.isApproximatelyEqual(to: 2))
    #expect(result.intercept.isApproximatelyEqual(to: 0))
    #expect(result.rSquared.isApproximatelyEqual(to: 1))
}

@Test func multipleLinearRegressionFitsFeatureMatrix() throws {
    let features = try #require(
        Tensor.matrix([
            [1, 0],
            [0, 1],
            [1, 1],
            [2, 1],
        ]))
    let target = Tensor.vector([6, 6, 9, 12])
    let result = try #require(
        Numerica.Statistics.multipleLinearRegression(features: features, target: target))
    #expect(result.intercept.isApproximatelyEqual(to: 3))
    #expect(result.coefficients[0].isApproximatelyEqual(to: 3))
    #expect(result.coefficients[1].isApproximatelyEqual(to: 3))
    #expect(result.rSquared.isApproximatelyEqual(to: 1))
}

@Test func logisticRegressionSeparatesSimpleBinaryData() throws {
    let features = try #require(
        Tensor.matrix([
            [0],
            [1],
            [2],
            [3],
        ]))
    let target = Tensor.vector([0, 0, 1, 1])
    let result = try #require(
        Numerica.Statistics.logisticRegression(
            features: features,
            target: target,
            learningRate: 0.5,
            iterations: 2_000
        ))
    let lowPrediction = try #require(result.predict(.vector([0])))
    let highPrediction = try #require(result.predict(.vector([3])))
    #expect(lowPrediction == 0)
    #expect(highPrediction == 1)
}

@Test func tensorValueStyleStatisticsDelegateToNamespaceAPIs() throws {
    let values = Tensor.vector([1, 2, 3, 4, 5])

    #expect(try #require(values.sum()).isApproximatelyEqual(to: 15))
    #expect(try #require(values.mean()).isApproximatelyEqual(to: 3))
    #expect(try #require(values.variance()).isApproximatelyEqual(to: 2.5))
    #expect(try #require(values.standardDeviation()).isApproximatelyEqual(to: 2.5.squareRoot()))
    #expect(try #require(values.percentile(95)).isApproximatelyEqual(to: 4.8))
    #expect(try #require(values.interquartileRange()).isApproximatelyEqual(to: 2))
}

@Test func distributionAnalysisFitsContinuousDistributions() throws {
    let normal = try #require(
        Numerica.Statistics.DistributionAnalysis.fitNormal(.vector([8, 10, 12])))
    #expect(normal.mean.isApproximatelyEqual(to: 10))
    #expect(normal.standardDeviation.isApproximatelyEqual(to: (8.0 / 3.0).squareRoot()))

    let uniform = try #require(
        Numerica.Statistics.DistributionAnalysis.fitUniform(.vector([-2, 1, 4])))
    #expect(uniform.lowerBound.isApproximatelyEqual(to: -2))
    #expect(uniform.upperBound.isApproximatelyEqual(to: 4))

    let exponential = try #require(
        Numerica.Statistics.DistributionAnalysis.fitExponential(.vector([0.5, 1, 1.5])))
    #expect(exponential.rate.isApproximatelyEqual(to: 1))
}

@Test func distributionAnalysisRejectsInvalidFits() {
    #expect(Numerica.Statistics.DistributionAnalysis.fitNormal(.vector([2, 2, 2])) == nil)
    #expect(Numerica.Statistics.DistributionAnalysis.fitUniform(.vector([2, 2, 2])) == nil)
    #expect(Numerica.Statistics.DistributionAnalysis.fitExponential(.vector([-1, 1, 2])) == nil)
}

@Test func distributionAnalysisComputesKolmogorovSmirnovGoodnessOfFit() throws {
    let sample = Tensor.vector([0.1, 0.3, 0.5, 0.7, 0.9])
    let distribution = try #require(
        Numerica.Probability.UniformDistribution(lowerBound: 0, upperBound: 1))

    let result = try #require(
        Numerica.Statistics.DistributionAnalysis.kolmogorovSmirnovTest(
            sample,
            distribution: distribution
        ))

    #expect(result.sampleSize == 5)
    #expect(result.statistic.isApproximatelyEqual(to: 0.1, tolerance: 1e-12))
    #expect((0...1).contains(result.pValue))
}

extension Double {
    func isApproximatelyEqual(to expected: Double, tolerance: Double = 1e-12) -> Bool {
        abs(self - expected) <= tolerance
    }
}
