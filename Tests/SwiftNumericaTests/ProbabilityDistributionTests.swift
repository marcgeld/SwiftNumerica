import Testing
@testable import SwiftNumerica

@Test func normalDistributionComputesDensityAndDistribution() throws {
    let distribution = try #require(Numerica.Probability.NormalDistribution())
    #expect(distribution.pdf(0).isApproximatelyEqual(to: 0.3989422804014327))
    #expect(distribution.cdf(0).isApproximatelyEqual(to: 0.5, tolerance: 1e-7))
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
