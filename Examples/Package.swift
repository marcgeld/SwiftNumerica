// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftNumericaExamples",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    dependencies: [
        // Local development uses the parent package. If you copy only the
        // Examples package into another checkout and want to run it against the
        // GitHub version of SwiftNumerica, replace this line with:
        //
        // .package(url: "https://github.com/marcgeld/SwiftNumerica.git", branch: "main")
        //
        // or use a released version when one exists:
        //
        // .package(url: "https://github.com/marcgeld/SwiftNumerica.git", from: "1.0.0")
        .package(path: "..")
    ],
    targets: [
        .executableTarget(name: "BackendConfigurationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "CombinatoricsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "ContinuousDistributionsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "CorrelationCovarianceExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataProfilingLawsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataProfilingQualityExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataProfilingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataScienceCSVExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataScienceGroupingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataScienceExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveCentralTendencyExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveDispersionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveOrderStatisticsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveShapeExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveStatisticsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DiscreteDistributionsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DistributionFittingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "ExpectedValueExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "HypothesisTestingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "LinearAlgebraExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "LinearRegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "LogisticRegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "MarkovChainExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "MonteCarloSimulationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "MultipleLinearRegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "OptimizationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "PolynomialRegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "ProbabilityDistributionsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "RandomWalkExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "RegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SignalProcessingConvolutionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SignalProcessingFiltersExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SignalProcessingTransformsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SimulationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "TensorBasicsExample", dependencies: ["SwiftNumerica"]),
    ],
    swiftLanguageModes: [.v6]
)
