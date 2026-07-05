import Testing
@testable import SwiftNumerica

@Suite(.serialized)
struct BackendSelectionTests {
    @Test func defaultBackendIsAutomatic() {
        Numerica.configuration = NumericaConfiguration()
        #expect(Numerica.configuration.backend == .automatic)
    }

    @Test func pureSwiftBackendProducesCorrectResults() throws {
        Numerica.configuration.backend = .pureSwift
        let mean = try #require(Numerica.Statistics.mean(.vector([1, 2, 3, 4])))
        #expect(mean.isApproximatelyEqual(to: 2.5))
        #expect(Numerica.Combinatorics.combinations(n: 10, r: 3) == 120)
    }

    @Test func automaticBackendProducesReferenceResults() throws {
        Numerica.configuration.backend = .automatic
        let resolved = try Numerica.resolvedBackend()
        #expect(resolved == (ComputeBackend.accelerate.isAvailable ? .accelerate : .pureSwift))
        let variance = try #require(Numerica.Statistics.populationVariance(.vector([2, 4, 4, 4, 5, 5, 7, 9])))
        #expect(variance.isApproximatelyEqual(to: 4))
    }

    @Test func selectableBackendsAreNumericallyEquivalent() throws {
        let tensor = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

        Numerica.configuration.backend = .pureSwift
        let pureMean = try #require(Numerica.Statistics.mean(tensor))
        let pureVariance = try #require(Numerica.Statistics.populationVariance(tensor))

        Numerica.configuration.backend = .accelerate
        let accelerateMean = try #require(Numerica.Statistics.mean(tensor))
        let accelerateVariance = try #require(Numerica.Statistics.populationVariance(tensor))

        #expect(accelerateMean.isApproximatelyEqual(to: pureMean))
        #expect(accelerateVariance.isApproximatelyEqual(to: pureVariance))

    }

    @Test func pureSwiftAndAccelerateDescriptiveStatisticsAreEquivalent() throws {
        let tensor = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

        Numerica.configuration.backend = .pureSwift
        let pureSum = try #require(Numerica.Statistics.sum(tensor))
        let pureMin = try #require(Numerica.Statistics.min(tensor))
        let pureMax = try #require(Numerica.Statistics.max(tensor))
        let pureRange = try #require(Numerica.Statistics.range(tensor))
        let purePopulationVariance = try #require(Numerica.Statistics.populationVariance(tensor))
        let pureSampleVariance = try #require(Numerica.Statistics.sampleVariance(tensor))
        let purePopulationStandardDeviation = try #require(
            Numerica.Statistics.populationStandardDeviation(tensor))
        let pureSampleStandardDeviation = try #require(
            Numerica.Statistics.sampleStandardDeviation(tensor))

        Numerica.configuration.backend = .accelerate
        let accelerateSum = try #require(Numerica.Statistics.sum(tensor))
        let accelerateMin = try #require(Numerica.Statistics.min(tensor))
        let accelerateMax = try #require(Numerica.Statistics.max(tensor))
        let accelerateRange = try #require(Numerica.Statistics.range(tensor))
        let acceleratePopulationVariance = try #require(Numerica.Statistics.populationVariance(tensor))
        let accelerateSampleVariance = try #require(Numerica.Statistics.sampleVariance(tensor))
        let acceleratePopulationStandardDeviation = try #require(
            Numerica.Statistics.populationStandardDeviation(tensor))
        let accelerateSampleStandardDeviation = try #require(
            Numerica.Statistics.sampleStandardDeviation(tensor))

        #expect(accelerateSum.isApproximatelyEqual(to: pureSum))
        #expect(accelerateMin.isApproximatelyEqual(to: pureMin))
        #expect(accelerateMax.isApproximatelyEqual(to: pureMax))
        #expect(accelerateRange.isApproximatelyEqual(to: pureRange))
        #expect(acceleratePopulationVariance.isApproximatelyEqual(to: purePopulationVariance))
        #expect(accelerateSampleVariance.isApproximatelyEqual(to: pureSampleVariance))
        #expect(acceleratePopulationStandardDeviation.isApproximatelyEqual(to: purePopulationStandardDeviation))
        #expect(accelerateSampleStandardDeviation.isApproximatelyEqual(to: pureSampleStandardDeviation))
    }

    @Test func pureSwiftAndAccelerateMomentsAreEquivalent() throws {
        let tensor = Tensor.vector([1, 2, 2, 3, 5, 8, 13])

        Numerica.configuration.backend = .pureSwift
        let pureSkewness = try #require(Numerica.Statistics.skewness(tensor))
        let pureKurtosis = try #require(Numerica.Statistics.kurtosis(tensor))

        Numerica.configuration.backend = .accelerate
        let accelerateSkewness = try #require(Numerica.Statistics.skewness(tensor))
        let accelerateKurtosis = try #require(Numerica.Statistics.kurtosis(tensor))

        #expect(accelerateSkewness.isApproximatelyEqual(to: pureSkewness))
        #expect(accelerateKurtosis.isApproximatelyEqual(to: pureKurtosis))
    }

    @Test func pureSwiftAndAccelerateCorrelationAndRegressionAreEquivalent() throws {
        let x = Tensor.vector([1, 2, 3, 5, 8, 13])
        let y = Tensor.vector([2, 5, 7, 11, 17, 26])

        Numerica.configuration.backend = .pureSwift
        let pureCorrelation = try #require(Numerica.Statistics.pearsonCorrelation(x, y))
        let purePopulationCovariance = try #require(Numerica.Statistics.populationCovariance(x, y))
        let pureSampleCovariance = try #require(Numerica.Statistics.sampleCovariance(x, y))
        let pureRegression = try #require(Numerica.Statistics.linearRegression(x: x, y: y))

        Numerica.configuration.backend = .accelerate
        let accelerateCorrelation = try #require(Numerica.Statistics.pearsonCorrelation(x, y))
        let acceleratePopulationCovariance = try #require(Numerica.Statistics.populationCovariance(x, y))
        let accelerateSampleCovariance = try #require(Numerica.Statistics.sampleCovariance(x, y))
        let accelerateRegression = try #require(Numerica.Statistics.linearRegression(x: x, y: y))

        #expect(accelerateCorrelation.isApproximatelyEqual(to: pureCorrelation))
        #expect(acceleratePopulationCovariance.isApproximatelyEqual(to: purePopulationCovariance))
        #expect(accelerateSampleCovariance.isApproximatelyEqual(to: pureSampleCovariance))
        #expect(accelerateRegression.slope.isApproximatelyEqual(to: pureRegression.slope))
        #expect(accelerateRegression.intercept.isApproximatelyEqual(to: pureRegression.intercept))
        #expect(accelerateRegression.rSquared.isApproximatelyEqual(to: pureRegression.rSquared))
    }

    @Test func pureSwiftAndAccelerateOrderStatisticsAreEquivalent() throws {
        let evenTensor = Tensor.vector([9, 2, 7, 4, 5, 4, 4, 2])
        let oddTensor = Tensor.vector([3, 1, 4, 1, 5, 9, 2])

        Numerica.configuration.backend = .pureSwift
        let pureEvenMedian = try #require(Numerica.Statistics.median(evenTensor))
        let pureOddMedian = try #require(Numerica.Statistics.median(oddTensor))
        let pureQuantile = try #require(Numerica.Statistics.quantile(evenTensor, probability: 0.35))
        let purePercentile = try #require(Numerica.Statistics.percentile(evenTensor, percentile: 90))
        let pureInterquartileRange = try #require(Numerica.Statistics.interquartileRange(evenTensor))

        Numerica.configuration.backend = .accelerate
        let accelerateEvenMedian = try #require(Numerica.Statistics.median(evenTensor))
        let accelerateOddMedian = try #require(Numerica.Statistics.median(oddTensor))
        let accelerateQuantile = try #require(Numerica.Statistics.quantile(evenTensor, probability: 0.35))
        let acceleratePercentile = try #require(Numerica.Statistics.percentile(evenTensor, percentile: 90))
        let accelerateInterquartileRange = try #require(
            Numerica.Statistics.interquartileRange(evenTensor))

        #expect(accelerateEvenMedian.isApproximatelyEqual(to: pureEvenMedian))
        #expect(accelerateOddMedian.isApproximatelyEqual(to: pureOddMedian))
        #expect(accelerateQuantile.isApproximatelyEqual(to: pureQuantile))
        #expect(acceleratePercentile.isApproximatelyEqual(to: purePercentile))
        #expect(accelerateInterquartileRange.isApproximatelyEqual(to: pureInterquartileRange))
    }

    @Test func pureSwiftAndAccelerateSpearmanCorrelationIsEquivalent() throws {
        let x = Tensor.vector([1, 2, 2, 3, 5, 8, 8, 13])
        let y = Tensor.vector([2, 1, 4, 3, 7, 12, 11, 20])

        Numerica.configuration.backend = .pureSwift
        let pureSpearman = try #require(Numerica.Statistics.spearmanCorrelation(x, y))

        Numerica.configuration.backend = .accelerate
        let accelerateSpearman = try #require(Numerica.Statistics.spearmanCorrelation(x, y))

        #expect(accelerateSpearman.isApproximatelyEqual(to: pureSpearman))
    }

    @Test func pureSwiftAndAccelerateMultipleLinearRegressionIsEquivalent() throws {
        let features = try #require(
            Tensor.matrix([[1, 2], [2, 1], [3, 4], [4, 3], [5, 7], [6, 5]]))
        let target = Tensor.vector([6, 5, 12, 11, 20, 17])

        Numerica.configuration.backend = .pureSwift
        let pureModel = try #require(
            Numerica.Statistics.multipleLinearRegression(features: features, target: target))

        Numerica.configuration.backend = .accelerate
        let accelerateModel = try #require(
            Numerica.Statistics.multipleLinearRegression(features: features, target: target))

        #expect(accelerateModel.coefficients.count == pureModel.coefficients.count)
        for (accelerateCoefficient, pureCoefficient) in zip(
            accelerateModel.coefficients, pureModel.coefficients)
        {
            #expect(accelerateCoefficient.isApproximatelyEqual(to: pureCoefficient, tolerance: 1e-9))
        }
        #expect(accelerateModel.intercept.isApproximatelyEqual(to: pureModel.intercept, tolerance: 1e-9))
        #expect(accelerateModel.rSquared.isApproximatelyEqual(to: pureModel.rSquared, tolerance: 1e-9))
    }

    @Test func pureSwiftAndAccelerateLogisticRegressionIsEquivalent() throws {
        let features = try #require(Tensor.matrix([[0], [1], [2], [3], [4], [5]]))
        let target = Tensor.vector([0, 0, 0, 1, 1, 1])

        Numerica.configuration.backend = .pureSwift
        let pureModel = try #require(
            Numerica.Statistics.logisticRegression(
                features: features, target: target, learningRate: 0.5, iterations: 500))

        Numerica.configuration.backend = .accelerate
        let accelerateModel = try #require(
            Numerica.Statistics.logisticRegression(
                features: features, target: target, learningRate: 0.5, iterations: 500))

        #expect(accelerateModel.coefficients.count == pureModel.coefficients.count)
        for (accelerateCoefficient, pureCoefficient) in zip(
            accelerateModel.coefficients, pureModel.coefficients)
        {
            #expect(accelerateCoefficient.isApproximatelyEqual(to: pureCoefficient, tolerance: 1e-9))
        }
        #expect(accelerateModel.intercept.isApproximatelyEqual(to: pureModel.intercept, tolerance: 1e-9))
    }

    @Test func accelerateVarianceIsNumericallyStableForLargeOffsets() throws {
        let offset = 100_000_000.0
        let tensor = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9].map { $0 + offset })

        Numerica.configuration.backend = .pureSwift
        let pureVariance = try #require(Numerica.Statistics.populationVariance(tensor))

        Numerica.configuration.backend = .accelerate
        let accelerateVariance = try #require(Numerica.Statistics.populationVariance(tensor))

        #expect(pureVariance.isApproximatelyEqual(to: 4, tolerance: 1e-6))
        #expect(accelerateVariance.isApproximatelyEqual(to: 4, tolerance: 1e-6))
        #expect(accelerateVariance.isApproximatelyEqual(to: pureVariance, tolerance: 1e-6))
    }
}
