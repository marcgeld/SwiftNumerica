import Testing
@testable import SwiftNumerica

@Test func benfordAnalysisComputesDigitFrequencies() throws {
    let analysis = try #require(Numerica.DataProfiling.benfordAnalysis(.vector([10, 11, 20, 30])))
    #expect(analysis.observedFrequencies[1]?.isApproximatelyEqual(to: 0.5) == true)
}

@Test func outlierAnalysisFindsExtremeValues() throws {
    let analysis = try #require(Numerica.DataProfiling.outlierAnalysis(.vector([1, 2, 2, 3, 100])))
    #expect(analysis.outliers == [100])
}

@Test func trendAnalysisDetectsIncreasingSeries() throws {
    let analysis = try #require(Numerica.DataProfiling.trendAnalysis(.vector([1, 2, 3, 4])))
    #expect(analysis.isIncreasing)
}

@Test func datasetProfilerBuildsSummaryAndCorrelationMatrix() throws {
    let tensor = try #require(Tensor.matrix([[1, 2], [2, 4], [3, 6]]))
    let profile = DatasetProfiler.profile(tensor)
    #expect(profile.summaryStatistics.mean?.isApproximatelyEqual(to: 3) == true)
    let matrix = try #require(profile.correlationMatrix)
    #expect(matrix[0][1]?.isApproximatelyEqual(to: 1) == true)
}
