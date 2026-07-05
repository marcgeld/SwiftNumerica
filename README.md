# SwiftNumerica

SwiftNumerica is a modern numerical computing, statistics, probability, and data analysis library for Swift. It is inspired by NumPy, SciPy, and Swift Numerics while staying idiomatic to Swift: value types, protocol-oriented design, composable namespaces, Swift Package Manager, Swift Testing, and DocC comments.

## Design Philosophy

The fundamental abstraction is `Tensor<Double>`. Numerical code must operate on tensors, not CSV files, TSV files, JSON tables, SQL tables, or DataFrames. Tabular systems may be added later as adapters, but the numerical core must remain independent of them.

The initial implementation is pure Swift and targets Apple Silicon first. Future backends may use Accelerate, SIMD, Metal, BLAS, or LAPACK without changing public APIs. MLX interoperability lives in an optional adapter package so the core library does not depend on MLX.

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
    │   ├── Tests
    │   └── DistributionAnalysis
    ├── Probability
    ├── Optimization
    ├── LinearAlgebra
    ├── Simulation
    ├── Combinatorics
    ├── DataProfiling
    └── Internal
        ├── Backends
        ├── Protocols
        └── Validation
Adapters/
└── SwiftNumericaMLX
    └── Optional MLX conversion package
```

## Backend Architecture

Public APIs call internal backend protocols through `BackendResolver`. Public APIs must never instantiate backend implementations directly and must never expose backend implementation details.

## Compute Backends

SwiftNumerica supports runtime-selectable compute backends for benchmarking, numerical verification, regression testing, implementation comparison, and future hardware acceleration.

Available backend options:

- `ComputeBackend.pureSwift`: the pure Swift reference implementation. This backend must always be available and is the correctness baseline.
- `ComputeBackend.accelerate`: always uses Accelerate-backed implementations for operations implemented in that backend. Selecting it explicitly fails availability resolution with `BackendError.unavailable(.accelerate)` when Accelerate cannot be imported.
- `ComputeBackend.automatic`: automatic backend selection. The priority is Accelerate, then PureSwift.

Users can switch backends at runtime:

```swift
Numerica.configuration.backend = .pureSwift
let reference = Numerica.Statistics.mean(Tensor.vector([1, 2, 3]))

Numerica.configuration.backend = .accelerate
let resolved = try Numerica.resolvedBackend()
let accelerated = Numerica.Statistics.mean(Tensor.vector([1, 2, 3]))

Numerica.configuration.backend = .automatic
```

Runtime switching exists so future benchmark and validation modules can run identical tensors through PureSwift, Accelerate, and other core backends. Accelerated backends must produce numerically equivalent results to PureSwift within documented tolerances. Backend-specific optimizations belong behind internal backend protocols such as `StatisticsBackend`, `TensorBackend`, `LinearAlgebraBackend`, and `ProbabilityBackend`.

## Optional MLX Adapter

The core `SwiftNumerica` package intentionally has no MLX dependency. MLX interoperability lives in a separate package at [Adapters/SwiftNumericaMLX](Adapters/SwiftNumericaMLX), which can be built independently and imported only by projects that need MLX arrays.

```swift
import SwiftNumerica
import SwiftNumericaMLX

let tensor = Tensor.vector([1, 2, 3])
let array = tensor.mlxArray()
let roundTrip = Tensor<Double>(mlxArray: array)
```

Existing optional-returning numerical APIs preserve their current signatures. Code that needs explicit backend availability errors should call `try Numerica.resolvedBackend()` after changing `Numerica.configuration.backend`.

## Current Status

Implemented:

- `Tensor<Double>`, `Shape`, `TensorIndex`, `Vector`, and `Matrix`
- Tensor reshaping with row-major storage preservation
- Descriptive statistics: sum, min, max, mean, median, mode, range, population/sample variance, population/sample standard deviation, skewness, excess kurtosis, quantile, percentile, interquartile range, and z-score
- Correlation and covariance: Pearson, Spearman, population/sample covariance, and convenience correlation/covariance aliases
- Statistical tests: Welch t-test, paired t-test, chi-square goodness-of-fit, one-way ANOVA, and two-sided Mann-Whitney U
- Regression: simple linear, multiple linear, polynomial, and binary logistic regression with lightweight functions and model-oriented estimators
- Optimization: `minimize` and `maximize` with gradient descent, Newton-Raphson, LBFGS, and Nelder-Mead
- Linear algebra: `Matrix`, `Vector`, determinant, inverse, solve, and real symmetric eigenvalues/eigenvectors
- Simulation: Monte Carlo simulations, additive random walks, and finite-state Markov chains
- Combinatorics: factorial, combinations, permutations
- Probability: tensor-based discrete expected value plus normal, uniform, Poisson, exponential, binomial, beta, gamma, and hypergeometric distributions with CDFs, inverse CDFs, analytical moments, and random sampling
- Data profiling: Benford, Zipf, Pareto, normality, uniformity, outliers, correlation matrices, trends, growth rates, and `DatasetProfiler.profile(_:)`

## Example Usage

```swift
import SwiftNumerica

let values = Tensor.vector([1, 2, 3, 4, 5])
let mean = values.mean()
let p95 = values.percentile(95)
let profile = DatasetProfiler.profile(values)

let normal = Numerica.Probability.NormalDistribution()
let densityAtZero = normal?.pdf(0)
let simulatedValues = normal?.sample(count: 1_000)

let test = tTest(.vector([8, 9, 10]), .vector([1, 2, 3]))
let pValue = test?.pValue

let solution = minimize(
    function: { point in
        let x = point[0] - 3
        let y = point[1] + 2
        return x * x + y * y
    },
    initialGuess: [0, 0]
)

let matrix = Matrix([[4, 7], [2, 6]])!
let determinant = matrix.determinant()
let inverse = matrix.inverse()
let linearSolution = matrix.solve(Vector([1, 0]))

let monteCarlo = MonteCarloSimulation(iterations: 10_000)
let estimate = monteCarlo?.run {
    Double.random(in: 0...1)
}

let walk = RandomWalk(initialValue: 0)
let path = walk?.simulate(steps: 100) {
    Bool.random() ? 1 : -1
}

let weather = MarkovChain(
    states: ["sunny", "rainy"],
    transitionProbabilities: [
        [0.8, 0.2],
        [0.4, 0.6],
    ]
)
let forecast = weather?.simulate(startingAt: "sunny", steps: 7)

let linear = LinearRegression()
let line = linear.fit(.vector([1, 2, 3]), .vector([3, 5, 7]))

let polynomial = PolynomialRegression(degree: 2)
let curve = polynomial?.fit(.vector([-1, 0, 1]), .vector([2, 1, 6]))

let features = Tensor.matrix([[0], [1], [2], [3]])!
let target = Tensor.vector([0, 0, 1, 1])
let classifier = LogisticRegression(learningRate: 0.5, iterations: 2_000)?
    .fit(features: features, target: target)
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
- `MLX Adapter` builds the optional `Adapters/SwiftNumericaMLX` package separately when adapter or core sources change.
- `Release` can run when a `v*` tag is pushed or manually through `workflow_dispatch`.
- Manual releases require an existing semantic tag such as `v0.1.0`.
- Release builds run `swift build -c release` and `swift test` before creating the GitHub Release.

The release workflow uses the repository `GITHUB_TOKEN` with `contents: write` permission to publish GitHub Releases.

## Roadmap

See [ROADMAP.md](ROADMAP.md) for the detailed phase plan.

Near-term priorities:

- Grow data-science adapters without weakening the tensor-first numerical core.

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
