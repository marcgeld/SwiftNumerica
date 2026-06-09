internal enum BackendResolver {
    private static let pureSwiftStatistics = PureSwiftStatisticsBackend()
    private static let accelerateStatistics = AccelerateStatisticsBackend()
    private static let mlxStatistics = MLXStatisticsBackend()

    private static let pureSwiftCombinatorics = PureSwiftCombinatoricsBackend()
    private static let accelerateCombinatorics = AccelerateCombinatoricsBackend()
    private static let mlxCombinatorics = MLXCombinatoricsBackend()

    internal static func statisticsBackend() throws -> any StatisticsBackend {
        switch try resolvedBackend() {
        case .pureSwift:
            pureSwiftStatistics
        case .accelerate:
            accelerateStatistics
        case .mlx:
            mlxStatistics
        case .automatic:
            pureSwiftStatistics
        }
    }

    internal static func combinatoricsBackend() throws -> any CombinatoricsBackend {
        switch try resolvedBackend() {
        case .pureSwift:
            pureSwiftCombinatorics
        case .accelerate:
            accelerateCombinatorics
        case .mlx:
            mlxCombinatorics
        case .automatic:
            pureSwiftCombinatorics
        }
    }

    internal static func resolvedBackend() throws -> ComputeBackend {
        switch Numerica.configuration.backend {
        case .automatic:
            return automaticBackend()
        case .accelerate:
            guard BackendAvailability.isAccelerateAvailable else {
                throw BackendError.unavailable(.accelerate)
            }
            return .accelerate
        case .mlx:
            guard BackendAvailability.isMLXAvailable else {
                throw BackendError.unavailable(.mlx)
            }
            return .mlx
        case let backend:
            return backend
        }
    }

    private static func automaticBackend() -> ComputeBackend {
        if BackendAvailability.isMLXAvailable {
            return .mlx
        }
        if BackendAvailability.isAccelerateAvailable {
            return .accelerate
        }
        return .pureSwift
    }
}
