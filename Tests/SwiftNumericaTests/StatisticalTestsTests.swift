import Testing

@testable import SwiftNumerica

@Test func welchTTestDetectsDifferentIndependentMeans() throws {
    let result = try #require(
        HypothesisTesting.welchTTest(
            .vector([8, 9, 10, 11, 12]),
            .vector([1, 2, 3, 4, 5])
        )
    )

    #expect(result.statistic.isApproximatelyEqual(to: 7))
    #expect(result.pValue < 0.001)
    #expect(result.confidenceInterval?.lowerBound ?? 0 > 3)
    #expect(result.confidenceInterval?.upperBound ?? 0 > result.confidenceInterval?.lowerBound ?? 0)
    #expect(result.degreesOfFreedom?.isApproximatelyEqual(to: 8) == true)
    #expect(result.effectSize?.isApproximatelyEqual(to: 4.427188724235731) == true)
    #expect(result.method == "Welch two-sample t-test")
}

@Test func oneSidedWelchTTestUsesAlternativeHypothesis() throws {
    let result = try #require(
        Numerica.Statistics.HypothesisTesting.welchTTest(
            .vector([8, 9, 10, 11, 12]),
            .vector([1, 2, 3, 4, 5]),
            alternative: .greater
        )
    )

    #expect(result.pValue < 0.001)
}

@Test func pairedTTestUsesPairwiseDifferences() throws {
    let result = try #require(
        HypothesisTesting.pairedTTest(
            .vector([5, 7, 8, 10, 11]),
            .vector([1, 2, 3, 4, 5])
        )
    )

    #expect(result.statistic > 0)
    #expect(result.pValue < 0.001)
    #expect(result.confidenceInterval?.lowerBound ?? 0 > 0)
    #expect(result.degreesOfFreedom?.isApproximatelyEqual(to: 4) == true)
    #expect(result.method == "Paired t-test")
}

@Test func pairedTTestReturnsNilForMismatchedPairs() {
    let result = HypothesisTesting.pairedTTest(.vector([1, 2]), .vector([1]))

    #expect(result == nil)
}

@Test func chiSquareTestComputesGoodnessOfFit() throws {
    let result = try #require(
        HypothesisTesting.chiSquareGoodnessOfFit(observed: .vector([20, 5, 5]))
    )

    #expect(result.statistic.isApproximatelyEqual(to: 15))
    #expect(result.pValue < 0.001)
    #expect(result.confidenceInterval == nil)
    #expect(result.degreesOfFreedom?.isApproximatelyEqual(to: 2) == true)
    #expect(result.effectSize?.isApproximatelyEqual(to: (15.0 / 30.0).squareRoot()) == true)
}

@Test func chiSquareTestReturnsOneForPerfectUniformFit() throws {
    let result = try #require(
        HypothesisTesting.chiSquareGoodnessOfFit(observed: .vector([10, 10, 10]))
    )

    #expect(result.statistic.isApproximatelyEqual(to: 0))
    #expect(result.pValue.isApproximatelyEqual(to: 1))
}

@Test func oneWayANOVADetectsDifferentGroupMeans() throws {
    let result = try #require(
        HypothesisTesting.oneWayANOVA([
            .vector([1, 2, 1]),
            .vector([5, 6, 5]),
            .vector([9, 10, 9]),
        ])
    )

    #expect(result.statistic > 80)
    #expect(result.pValue < 0.001)
    #expect(result.degreesOfFreedom?.isApproximatelyEqual(to: 2) == true)
    #expect(result.denominatorDegreesOfFreedom?.isApproximatelyEqual(to: 6) == true)
    #expect(result.effectSize ?? 0 > 0.95)
}

@Test func mannWhitneyUDetectsSeparatedSamples() throws {
    let result = try #require(
        HypothesisTesting.mannWhitneyU(
            .vector([1, 2, 3, 4, 5]),
            .vector([9, 10, 11, 12, 13])
        )
    )

    #expect(result.statistic.isApproximatelyEqual(to: 0))
    #expect(result.pValue < 0.02)
    #expect(result.effectSize?.isApproximatelyEqual(to: -1) == true)
}

@Test func mannWhitneyUHandlesTiesWithAverageRanks() throws {
    let result = try #require(
        HypothesisTesting.mannWhitneyU(
            .vector([1, 2, 2]),
            .vector([2, 3, 4])
        )
    )

    #expect(result.statistic.isApproximatelyEqual(to: 1))
    #expect((0...1).contains(result.pValue))
}
