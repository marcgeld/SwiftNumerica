internal enum BackendResolver {
    private static let pureSwiftStatistics = PureSwiftStatisticsBackend()
    private static let accelerateStatistics = AccelerateStatisticsBackend()

    private static let pureSwiftCombinatorics = PureSwiftCombinatoricsBackend()
    private static let accelerateCombinatorics = AccelerateCombinatoricsBackend()

    private static let pureSwiftLinearAlgebra = PureSwiftLinearAlgebraBackend()
    private static let accelerateLinearAlgebra = AccelerateLinearAlgebraBackend()

    internal static func statisticsBackend() throws -> any StatisticsBackend {
        switch try resolvedBackend() {
        case .pureSwift:
            pureSwiftStatistics
        case .accelerate:
            accelerateStatistics
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
        case .automatic:
            pureSwiftCombinatorics
        }
    }

    internal static func linearAlgebraBackend() throws -> any LinearAlgebraBackend {
        switch try resolvedBackend() {
        case .pureSwift:
            pureSwiftLinearAlgebra
        case .accelerate:
            accelerateLinearAlgebra
        case .automatic:
            pureSwiftLinearAlgebra
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
        case let backend:
            return backend
        }
    }

    private static func automaticBackend() -> ComputeBackend {
        if BackendAvailability.isAccelerateAvailable {
            return .accelerate
        }
        return .pureSwift
    }
}
