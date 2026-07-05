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
        .package(path: "..")
    ],
    targets: [
        .executableTarget(name: "BackendConfigurationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "CombinatoricsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "CorrelationCovarianceExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataProfilingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DataScienceExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DescriptiveStatisticsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "DistributionFittingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "HypothesisTestingExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "LinearAlgebraExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "OptimizationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "ProbabilityDistributionsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "RegressionExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SignalProcessingFiltersExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SignalProcessingTransformsExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "SimulationExample", dependencies: ["SwiftNumerica"]),
        .executableTarget(name: "TensorBasicsExample", dependencies: ["SwiftNumerica"]),
    ],
    swiftLanguageModes: [.v6]
)
