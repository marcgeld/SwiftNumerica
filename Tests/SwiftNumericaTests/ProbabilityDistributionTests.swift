import Foundation
import Testing
@testable import SwiftNumerica

@Test func normalDistributionComputesDensityAndDistribution() throws {
    let distribution = try #require(Numerica.Probability.NormalDistribution())
    #expect(distribution.pdf(0).isApproximatelyEqual(to: 0.3989422804014327))
    #expect(distribution.cdf(0).isApproximatelyEqual(to: 0.5, tolerance: 1e-7))
    #expect(distribution.mean.isApproximatelyEqual(to: 0))
    #expect(distribution.variance.isApproximatelyEqual(to: 1))
    #expect(try #require(distribution.inverseCDF(0.5)).isApproximatelyEqual(to: 0, tolerance: 1e-7))
}

@Test func normalDistributionSamplesFiniteValues() throws {
    let distribution = try #require(Numerica.Probability.NormalDistribution())
    let samples = distribution.sample(count: 10)

    #expect(samples.count == 10)
    #expect(samples.allSatisfy { $0.isFinite })
    #expect(distribution.sample(count: 0).isEmpty)
}

@Test func uniformDistributionComputesDensityAndDistribution() throws {
    let distribution = try #require(Numerica.Probability.UniformDistribution(lowerBound: 0, upperBound: 10))
    #expect(distribution.pdf(5).isApproximatelyEqual(to: 0.1))
    #expect(distribution.cdf(5).isApproximatelyEqual(to: 0.5))
    #expect(distribution.mean.isApproximatelyEqual(to: 5))
    #expect(distribution.variance.isApproximatelyEqual(to: 100.0 / 12.0))
    #expect(try #require(distribution.inverseCDF(0.25)).isApproximatelyEqual(to: 2.5))
}

@Test func uniformDistributionSamplesWithinBounds() throws {
    let distribution = try #require(Numerica.Probability.UniformDistribution(lowerBound: -2, upperBound: 3))
    let samples = distribution.sample(count: 20)

    #expect(samples.count == 20)
    #expect(samples.allSatisfy { (-2...3).contains($0) })
}

@Test func binomialDistributionComputesMassAndDistribution() throws {
    let distribution = try #require(Numerica.Probability.BinomialDistribution(trials: 10, probabilityOfSuccess: 0.5))
    #expect(distribution.pmf(3).isApproximatelyEqual(to: 0.1171875))
    #expect(distribution.cdf(10).isApproximatelyEqual(to: 1))
    #expect(distribution.mean.isApproximatelyEqual(to: 5))
    #expect(distribution.variance.isApproximatelyEqual(to: 2.5))
    #expect(distribution.inverseCDF(0.5) == 5)
}

@Test func binomialDistributionSamplesWithinSupport() throws {
    let distribution = try #require(Numerica.Probability.BinomialDistribution(trials: 10, probabilityOfSuccess: 0.5))
    let samples = distribution.sample(count: 20)

    #expect(samples.count == 20)
    #expect(samples.allSatisfy { (0...10).contains($0) })
}

@Test func poissonDistributionComputesMass() throws {
    let distribution = try #require(Numerica.Probability.PoissonDistribution(lambda: 3))
    #expect(distribution.pmf(2).isApproximatelyEqual(to: 0.22404180765538775))
    #expect(distribution.mean.isApproximatelyEqual(to: 3))
    #expect(distribution.variance.isApproximatelyEqual(to: 3))
    #expect(distribution.inverseCDF(0.5) == 3)
}

@Test func poissonDistributionSamplesNonNegativeCounts() throws {
    let distribution = try #require(Numerica.Probability.PoissonDistribution(lambda: 3))
    let samples = distribution.sample(count: 20)

    #expect(samples.count == 20)
    #expect(samples.allSatisfy { $0 >= 0 })
}

@Test func hypergeometricDistributionComputesMass() throws {
    let distribution = try #require(Numerica.Probability.HypergeometricDistribution(
        populationSize: 52,
        successStates: 4,
        draws: 5
    ))
    #expect(distribution.pmf(1).isApproximatelyEqual(to: 0.2994736356085229))
    #expect(distribution.mean.isApproximatelyEqual(to: 5.0 * 4.0 / 52.0))
    #expect(distribution.inverseCDF(0.5) == 0)
}

@Test func hypergeometricDistributionSamplesWithinSupport() throws {
    let distribution = try #require(Numerica.Probability.HypergeometricDistribution(
        populationSize: 52,
        successStates: 4,
        draws: 5
    ))
    let samples = distribution.sample(count: 20)

    #expect(samples.count == 20)
    #expect(samples.allSatisfy { (0...4).contains($0) })
}

@Test func exponentialDistributionComputesDensityDistributionMomentsAndQuantiles() throws {
    let distribution = try #require(Numerica.Probability.ExponentialDistribution(rate: 2))

    #expect(distribution.pdf(0.5).isApproximatelyEqual(to: 2 / Foundation.exp(1), tolerance: 1e-12))
    #expect(distribution.cdf(0.5).isApproximatelyEqual(to: 1 - 1 / Foundation.exp(1), tolerance: 1e-12))
    #expect(distribution.mean.isApproximatelyEqual(to: 0.5))
    #expect(distribution.variance.isApproximatelyEqual(to: 0.25))
    #expect(try #require(distribution.inverseCDF(distribution.cdf(0.5))).isApproximatelyEqual(to: 0.5))
    #expect(distribution.sample(count: 5).allSatisfy { $0 >= 0 })
}

@Test func gammaDistributionComputesDensityDistributionMomentsAndQuantiles() throws {
    let distribution = try #require(Numerica.Probability.GammaDistribution(shape: 2, scale: 2))

    #expect(distribution.pdf(2).isApproximatelyEqual(to: 0.18393972058572117, tolerance: 1e-12))
    #expect(distribution.cdf(2).isApproximatelyEqual(to: 0.26424111765711533, tolerance: 1e-10))
    #expect(distribution.mean.isApproximatelyEqual(to: 4))
    #expect(distribution.variance.isApproximatelyEqual(to: 8))
    #expect(try #require(distribution.inverseCDF(distribution.cdf(2))).isApproximatelyEqual(to: 2, tolerance: 1e-8))
    #expect(distribution.sample(count: 5).allSatisfy { $0 >= 0 })
}

@Test func betaDistributionComputesDensityDistributionMomentsAndQuantiles() throws {
    let distribution = try #require(Numerica.Probability.BetaDistribution(alpha: 2, beta: 2))

    #expect(distribution.pdf(0.5).isApproximatelyEqual(to: 1.5, tolerance: 1e-12))
    #expect(distribution.cdf(0.5).isApproximatelyEqual(to: 0.5, tolerance: 1e-12))
    #expect(distribution.mean.isApproximatelyEqual(to: 0.5))
    #expect(distribution.variance.isApproximatelyEqual(to: 0.05))
    #expect(try #require(distribution.inverseCDF(0.5)).isApproximatelyEqual(to: 0.5, tolerance: 1e-8))
    #expect(distribution.sample(count: 5).allSatisfy { (0...1).contains($0) })
}
