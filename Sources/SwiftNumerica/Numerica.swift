/// A compute backend that can execute SwiftNumerica operations.
public enum ComputeBackend: Sendable {
    /// The pure Swift reference backend.
    case pureSwift

    /// The Accelerate backend.
    case accelerate

    /// Automatically selects the fastest available backend.
    case automatic
}

public extension ComputeBackend {
    /// Returns whether the backend is currently available in this process.
    var isAvailable: Bool {
        switch self {
        case .pureSwift:
            true
        case .accelerate:
            BackendAvailability.isAccelerateAvailable
        case .automatic:
            true
        }
    }
}

/// Errors produced while resolving compute backends.
public enum BackendError: Error, Equatable, Sendable {
    /// The requested backend is not available in the current runtime.
    case unavailable(ComputeBackend)
}

/// Runtime configuration for SwiftNumerica.
public struct NumericaConfiguration: Sendable {
    /// The active compute backend.
    public var backend: ComputeBackend

    /// Creates a configuration.
    ///
    /// - Parameter backend: The active compute backend. Defaults to `.automatic`.
    public init(backend: ComputeBackend = .automatic) {
        self.backend = backend
    }
}

/// A namespace for numerical computing, statistics, probability, combinatorics,
/// and linear algebra APIs.
public enum Numerica {
    /// The process-wide SwiftNumerica runtime configuration.
    public nonisolated(unsafe) static var configuration = NumericaConfiguration()

    /// Returns the backend that will be used for the current configuration.
    ///
    /// - Throws: `BackendError.unavailable` when an explicitly selected backend
    ///   is not available.
    public static func resolvedBackend() throws -> ComputeBackend {
        try BackendResolver.resolvedBackend()
    }
}

public extension Numerica {
    /// Statistical routines such as descriptive statistics, correlation,
    /// regression, and hypothesis testing.
    enum Statistics {}
}

public extension Numerica {
    /// Probability models, distributions, random variables, and expected values.
    enum Probability {}
}

public extension Numerica {
    /// Counting utilities including factorials, combinations, and permutations.
    enum Combinatorics {}
}

public extension Numerica {
    /// Data profiling primitives for numerical tensors.
    enum DataProfiling {}
}

public extension Numerica {
    /// Numerical optimization routines such as minimization and maximization.
    enum Optimization {}
}

public extension Numerica {
    /// Linear algebra routines for vectors and dense matrices.
    enum LinearAlgebra {}
}

public extension Numerica {
    /// Simulation routines including Monte Carlo, random walks, and Markov chains.
    enum Simulation {}
}

public extension Numerica {
    /// Data science adapters for CSV, tabular data, summaries, and grouping.
    enum DataScience {}
}
