# SwiftNumerica

SwiftNumerica is a modern numerical computing, statistics, probability, and data analysis library for Swift. It is inspired by NumPy, SciPy, Swift Numerics, and MLX while staying idiomatic to Swift: value types, protocol-oriented design, composable namespaces, Swift Package Manager, Swift Testing, and DocC comments.

## Design Philosophy

The fundamental abstraction is `Tensor<Double>`. Numerical code must operate on tensors, not CSV files, TSV files, JSON tables, SQL tables, or DataFrames. Tabular systems may be added later as adapters, but the numerical core must remain independent of them.

The initial implementation is pure Swift and targets Apple Silicon first. Future backends may use Accelerate, SIMD, MLX, Metal, BLAS, or LAPACK without changing public APIs.

## Tensor-First Architecture

`Tensor<Double>` stores dense row-major values plus a validated `Shape`. Scalars are rank-0 tensors, vectors are rank-1 tensors, matrices are rank-2 tensors, and multidimensional tensors use rank 3 or greater.

Factory methods:

```swift
let scalar = Tensor.scalar(3.14)
let vector = Tensor.vector([1, 2, 3])
let matrix = Tensor.matrix([[1, 2], [3, 4]])
```

Tensors can be reshaped without reordering row-major storage:

```swift
let tensor = Tensor.vector([1, 2, 3, 4, 5, 6])
let matrixLike = try tensor.reshaped(to: [2, 3])
```

Reshape dimensions must be positive integers, except `[]`, which represents a scalar tensor. The product of the requested shape must equal the tensor value count. Invalid shapes throw `TensorError.invalidShape`; incompatible element counts throw `TensorError.incompatibleShape`.

All statistics and data profiling APIs accept `Tensor<Double>`.

## Package Structure

```text
Sources/
└── SwiftNumerica
    ├── Numerica.swift
    ├── Tensor
    │   ├── Tensor.swift
    │   ├── Shape.swift
    │   ├── TensorIndex.swift
    │   ├── Vector.swift
    │   └── Matrix.swift
    ├── Statistics
    │   ├── Descriptive
    │   ├── Correlation
    │   ├── Regression
    │   └── DistributionAnalysis
    ├── Probability
    ├── Combinatorics
    ├── DataProfiling
    └── Internal
        ├── Backends
        ├── Protocols
        └── Validation
```

## Backend Architecture

Public APIs call internal backend protocols through `BackendResolver`. Public APIs must never instantiate backend implementations directly and must never expose backend implementation details.

## Compute Backends

SwiftNumerica supports runtime-selectable compute backends for benchmarking, numerical verification, regression testing, implementation comparison, and future hardware acceleration.

Available backend options:

- `ComputeBackend.pureSwift`: the pure Swift reference implementation. This backend must always be available and is the correctness baseline.
- `ComputeBackend.accelerate`: always uses Accelerate-backed implementations for operations implemented in that backend. Selecting it explicitly fails availability resolution with `BackendError.unavailable(.accelerate)` when Accelerate cannot be imported.
- `ComputeBackend.automatic`: automatic backend selection. The priority is Accelerate, then PureSwift.
- `ComputeBackend.mlx`: reserved for future MLX implementations. Selecting it explicitly fails availability resolution with `BackendError.unavailable(.mlx)` until MLX support exists.

Users can switch backends at runtime:

```swift
Numerica.configuration.backend = .pureSwift
let reference = Numerica.Statistics.mean(Tensor.vector([1, 2, 3]))

Numerica.configuration.backend = .accelerate
let resolved = try Numerica.resolvedBackend()
let accelerated = Numerica.Statistics.mean(Tensor.vector([1, 2, 3]))

Numerica.configuration.backend = .automatic
```

Runtime switching exists so future benchmark and validation modules can run identical tensors through PureSwift, Accelerate, MLX, and other backends. Accelerated backends must produce numerically equivalent results to PureSwift within documented tolerances. Backend-specific optimizations belong behind internal backend protocols such as `StatisticsBackend`, `TensorBackend`, `LinearAlgebraBackend`, and `ProbabilityBackend`.

Existing optional-returning numerical APIs preserve their current signatures. Code that needs explicit backend availability errors should call `try Numerica.resolvedBackend()` after changing `Numerica.configuration.backend`.

## Current Status

Implemented:

- `Tensor<Double>`, `Shape`, `TensorIndex`, `Vector`, and `Matrix`
- Tensor reshaping with row-major storage preservation
- Descriptive statistics: mean, median, mode, range, population/sample variance, population/sample standard deviation, skewness, excess kurtosis, quantile, z-score
- Correlation: Pearson and Spearman
- Regression: simple linear regression, multiple linear regression, and binary logistic regression
- Combinatorics: factorial, combinations, permutations
- Probability: tensor-based discrete expected value plus normal, uniform, binomial, hypergeometric, and Poisson distributions with random sampling
- Data profiling: Benford, Zipf, Pareto, normality, uniformity, outliers, correlation matrices, trends, growth rates, and `DatasetProfiler.profile(_:)`

## Example Usage

```swift
import SwiftNumerica

let values = Tensor.vector([1, 2, 3, 4, 5])
let mean = Numerica.Statistics.mean(values)
let p90 = Numerica.Statistics.quantile(values, probability: 0.9)
let profile = DatasetProfiler.profile(values)

let normal = Numerica.Probability.NormalDistribution()
let densityAtZero = normal?.pdf(0)
let simulatedValues = normal?.sample(count: 1_000)

let features = Tensor.matrix([[0], [1], [2], [3]])!
let target = Tensor.vector([0, 0, 1, 1])
let classifier = Numerica.Statistics.logisticRegression(features: features, target: target)
```

## Using SwiftNumerica From Another Package

SwiftNumerica exposes a Swift Package Manager library product named `SwiftNumerica`.

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ExampleProject",
    dependencies: [
        .package(url: "https://github.com/<owner>/SwiftNumerica.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "ExampleProject",
            dependencies: [
                .product(name: "SwiftNumerica", package: "SwiftNumerica")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
```

The CI workflow validates this packaging contract by creating a separate consumer package, importing `SwiftNumerica`, and running a small executable.

## Continuous Integration And Releases

GitHub Actions workflows live in `.github/workflows`.

- `CI` builds the package, runs tests, and validates package consumption from another Swift package in one job.
- `Release` can run when a `v*` tag is pushed or manually through `workflow_dispatch`.
- Manual releases require an existing semantic tag such as `v0.1.0`.
- Release builds run `swift build -c release` and `swift test` before creating the GitHub Release.

The release workflow uses the repository `GITHUB_TOKEN` with `contents: write` permission to publish GitHub Releases.

## Roadmap

- Accelerate, SIMD, MLX, Metal, BLAS, and LAPACK backends
- Matrix operations, PCA, SVD, and decompositions
- Additional probability distributions and fitting routines
- Regularized, generalized, and multiclass regression models
- More statistical tests and distribution fitting
- Adapter packages for DataFrames, CSV, SQL, and other data sources

## Contribution Guidelines

- Preserve `Tensor<Double>` as the numerical core.
- Keep public APIs backend-independent.
- Route backend-backed public APIs through `BackendResolver`.
- Treat PureSwift as the reference implementation for backend validation.
- Prefer value types, `Sendable`, composition, and protocols.
- Add DocC comments for public APIs.
- Add Swift Testing coverage for implemented functionality.
- Reuse mathematical primitives instead of duplicating formulas.
- Update this README whenever architecture, modules, or design decisions change.

## Rules For Future Contributors And AI Agents

README.md is the authoritative architecture document. If implementation and README disagree, update the implementation to match README unless explicitly instructed otherwise. Do not introduce DataFrame, CSV, JSON table, SQL table, or file-format assumptions into the core library. Those belong in adapters.
