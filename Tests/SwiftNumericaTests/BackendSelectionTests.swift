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

        if ComputeBackend.mlx.isAvailable {
            Numerica.configuration.backend = .mlx
            let mlxMean = try #require(Numerica.Statistics.mean(tensor))
            let mlxVariance = try #require(Numerica.Statistics.populationVariance(tensor))
            #expect(mlxMean.isApproximatelyEqual(to: pureMean))
            #expect(mlxVariance.isApproximatelyEqual(to: pureVariance))
        }
    }

    @Test func explicitUnavailableBackendThrowsDuringResolution() {
        guard !ComputeBackend.mlx.isAvailable else { return }

        Numerica.configuration.backend = .mlx
        #expect(throws: BackendError.unavailable(.mlx)) {
            try Numerica.resolvedBackend()
        }
    }

    @Test func pureSwiftAndAccelerateDescriptiveStatisticsAreEquivalent() throws {
        let tensor = Tensor.vector([2, 4, 4, 4, 5, 5, 7, 9])

        Numerica.configuration.backend = .pureSwift
        let pureRange = try #require(Numerica.Statistics.range(tensor))
        let purePopulationVariance = try #require(Numerica.Statistics.populationVariance(tensor))
        let pureSampleVariance = try #require(Numerica.Statistics.sampleVariance(tensor))
        let purePopulationStandardDeviation = try #require(
            Numerica.Statistics.populationStandardDeviation(tensor))
        let pureSampleStandardDeviation = try #require(
            Numerica.Statistics.sampleStandardDeviation(tensor))

        Numerica.configuration.backend = .accelerate
        let accelerateRange = try #require(Numerica.Statistics.range(tensor))
        let acceleratePopulationVariance = try #require(Numerica.Statistics.populationVariance(tensor))
        let accelerateSampleVariance = try #require(Numerica.Statistics.sampleVariance(tensor))
        let acceleratePopulationStandardDeviation = try #require(
            Numerica.Statistics.populationStandardDeviation(tensor))
        let accelerateSampleStandardDeviation = try #require(
            Numerica.Statistics.sampleStandardDeviation(tensor))

        #expect(accelerateRange.isApproximatelyEqual(to: pureRange))
        #expect(acceleratePopulationVariance.isApproximatelyEqual(to: purePopulationVariance))
        #expect(accelerateSampleVariance.isApproximatelyEqual(to: pureSampleVariance))
        #expect(acceleratePopulationStandardDeviation.isApproximatelyEqual(to: purePopulationStandardDeviation))
        #expect(accelerateSampleStandardDeviation.isApproximatelyEqual(to: pureSampleStandardDeviation))
    }
}
