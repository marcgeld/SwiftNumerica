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

@Test func populationVarianceUsesPopulationDenominator() throws {
    let variance = try #require(
        Numerica.Statistics.populationVariance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(variance.isApproximatelyEqual(to: 4))
}

@Test func sampleVarianceUsesSampleDenominator() throws {
    let variance = try #require(
        Numerica.Statistics.sampleVariance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
    #expect(variance.isApproximatelyEqual(to: 32.0 / 7.0))
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

extension Double {
    func isApproximatelyEqual(to expected: Double, tolerance: Double = 1e-12) -> Bool {
        abs(self - expected) <= tolerance
    }
}
