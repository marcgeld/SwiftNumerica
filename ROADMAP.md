# SwiftNumerica Roadmap

SwiftNumerica aims to fill the practical scientific-computing gap between
Swift Numerics and SciPy with a native Swift API, strong typing, value
semantics, and Apple Silicon optimization. The package should feel familiar to
scientific-computing users without copying Python's dynamic API style or trying
to become a full SciPy clone.

## Design Goals

- Provide an idiomatic, native Swift API.
- Optimize for Apple Silicon and use Accelerate where it provides clear value.
- Prefer strong types, protocol-oriented design, value semantics, and `Sendable`
  data structures.
- Avoid Python-style dynamic APIs, untyped dictionaries, and stringly typed
  configuration.
- Focus on practical statistics, probability, optimization, simulation, signal
  processing, and linear algebra workflows.
- Keep the numerical core tensor-first. DataFrame, CSV, SQL, and file-format
  integration belongs in adapters or clearly separated integration modules.
- Keep MLX as an optional adapter package, not a dependency of the SwiftNumerica
  core library.

## Prioritization

### Phase 1: Core Statistics

Status: implemented.

Core statistics should provide both namespace APIs and ergonomic value-style
entry points where that does not compromise clarity.

Target operations:

- `mean`
- `median`
- `mode`
- `variance`
- `standardDeviation`
- `min`
- `max`
- `sum`
- `quantile`
- `percentile`
- `interquartileRange`
- `skewness`
- `kurtosis`
- `covariance`
- `correlation`

Example target API:

```swift
let m = data.mean()
let p95 = data.percentile(95)
```

### Phase 2: Probability Distributions

Status: implemented for the target scalar distribution APIs. Future work can add
batch tensor APIs and more advanced numerical methods where useful.

Distributions should be value types with explicit parameters and no dynamic
configuration. Scalar APIs should come first; tensorized batch APIs can be added
where Accelerate or SIMD creates a meaningful improvement.

Target distributions:

- `NormalDistribution`
- `UniformDistribution`
- `PoissonDistribution`
- `ExponentialDistribution`
- `BinomialDistribution`
- `BetaDistribution`
- `GammaDistribution`

Each distribution should provide:

- `pdf(_:)` or `pmf(_:)`
- `cdf(_:)`
- `inverseCDF(_:)`
- `sample()`
- `mean`
- `variance`

Example target API:

```swift
let normal = NormalDistribution(mean: 0, standardDeviation: 1)
let p = normal.cdf(1.96)
```

### Phase 3: Hypothesis Testing

Status: implemented for the target scalar/tensor test APIs with a dedicated
`Numerica.Statistics.HypothesisTesting` namespace, alternative hypotheses,
degrees-of-freedom metadata, effect sizes where available, and typed result
objects. Future work can add exact small-sample methods where useful.

Statistical tests should return strongly typed result objects rather than loose
tuples or dictionaries.

Target tests:

- `welchTTest`
- `pairedTTest`
- `chiSquareGoodnessOfFit`
- `oneWayANOVA`
- `mannWhitneyU`
- `kolmogorovSmirnovTest`

Result objects should expose:

- `method`
- `statistic`
- `pValue`
- `confidenceInterval`
- `degreesOfFreedom`
- `effectSize`

Example target API:

```swift
if let result = HypothesisTesting.welchTTest(sampleA, sampleB) {
    print(result.pValue)
}
```

### Phase 4: Regression

Status: implemented for lightweight namespace functions and model-oriented
estimators. Future work can add diagnostics, regularization, and richer model
summaries.

Regression APIs should support a model-oriented interface while preserving the
current lightweight namespace functions where useful.

Target models:

- `LinearRegression`
- `PolynomialRegression`
- `LogisticRegression`

Example target API:

```swift
let model = LinearRegression()
let result = model.fit(x, y)
```

### Phase 5: Numerical Optimization

Status: implemented for unconstrained scalar objective functions over `[Double]`.
Future work can add bounds, constraints, analytical gradients, and richer
diagnostics.

Optimization should prioritize common, practical algorithms with clear failure
states and typed results.

Target entry points:

- `minimize`
- `maximize`

Target algorithms:

- Gradient Descent
- Newton-Raphson
- LBFGS
- Nelder-Mead

Example target API:

```swift
if let solution = minimize(
    function: rosenbrock,
    initialGuess: [0, 0]
) {
    print(solution.value)
}
```

### Phase 6: Linear Algebra

Status: implemented for dense `Matrix` and `Vector` APIs, determinant, inverse,
linear system solving, and real symmetric eigenvalues/eigenvectors. Future work
can add LAPACK-backed specializations, nonsymmetric eigenvalue support, matrix
factorizations, and batched operations.

Linear algebra should provide Swift-friendly `Matrix` and `Vector` APIs backed
by Accelerate, BLAS, and LAPACK where beneficial.

Target operations:

- `Matrix`
- `Vector`
- `determinant`
- `inverse`
- `solve`
- `eigenvalues`
- `eigenvectors`

Example target API:

```swift
let matrix = Matrix([[4, 7], [2, 6]])!
let x = matrix.solve(Vector([1, 0]))
```

### Phase 7: Simulation

Status: implemented for Monte Carlo expected-value estimation, one-dimensional
additive random walks, and finite-state discrete-time Markov chains. Future work
can add higher-dimensional walks, stochastic processes, event simulation, and
batch summaries.

Simulation APIs should compose with distributions and tensors while keeping
randomness explicit and testable.

Target APIs:

- `MonteCarloSimulation`
- `RandomWalk`
- `MarkovChain`

Example target API:

```swift
let simulation = MonteCarloSimulation(iterations: 10_000)
let estimate = simulation?.run {
    Double.random(in: 0...1)
}
```

### Phase 8: Data Science Integration

Status: implemented for lightweight `DataTable` adapters, CSV import/export,
optional `TabularData.DataFrame` bridges, statistical summaries, and group-by
aggregations. Future work can add richer type inference, missing-value policies,
streaming readers, and typed schema helpers.

Data science integration should not weaken the tensor-first numerical core.
Adapters may bridge between SwiftNumerica and tabular data, but algorithms
should continue to operate on typed numerical structures.

Target integrations:

- `TabularData.DataFrame`
- CSV import/export
- Statistical summaries
- Group-by aggregations

Example target API:

```swift
let table = DataTable.importCSV("""
group,value
a,1
a,3
b,10
""")

let grouped = table?.grouped(by: "group")
let summaries = grouped?.summaries()
let values = table?.numericColumn("value")
```

### Phase 9: Signal Processing

Status: implemented for tensor-first one-dimensional signal APIs, including
`Signal`, FFT/IFFT, convolution, correlation, autocorrelation, moving average,
window functions, detrending, normalization, zero-crossing rate, peak detection,
periodogram, magnitude/phase spectra, FIR filters, and direct-form biquad
filtering. Future work can add Accelerate/vDSP specializations behind the same
public API where they improve runtime or allocations.

Signal processing should provide practical one-dimensional DSP operations over
`Tensor<Double>` and lightweight value types. APIs should stay strongly typed,
avoid hidden global state, and use Accelerate/vDSP where it provides clear
runtime or allocation wins.

Initial target APIs:

- `Signal`
- `fft`
- `inverseFFT`
- `convolve`
- `correlate`
- `autocorrelation`
- `movingAverage`
- `detrend`
- `normalize`
- `zeroCrossingRate`
- `peakDetection`

Window functions:

- `rectangularWindow`
- `hannWindow`
- `hammingWindow`
- `blackmanWindow`

Filtering:

- `lowPassFilter`
- `highPassFilter`
- `bandPassFilter`
- `bandStopFilter`
- Biquad/IIR filter helpers

Spectral analysis:

- `periodogram`
- Power spectral density helpers
- Magnitude and phase spectrum helpers

Future work can add resampling, interpolation, overlap-add convolution,
short-time Fourier transforms, spectrograms, multichannel signal helpers, and
dedicated vDSP FFT/convolution kernels.

Example target API:

```swift
let signal = Signal(samples: waveform, sampleRate: 44_100)
let spectrum = signal.fft()
let smoothed = signal.movingAverage(windowSize: 9)
let peaks = signal.peaks()
```

### Phase 10: Standalone Executable Examples

Status: implemented with standalone examples and a symbol-to-example coverage
matrix. The examples cover public API families across tensors, statistics,
probability, hypothesis testing, regression, optimization, linear algebra,
simulation, signal processing, data science, data profiling, combinatorics, and
backend configuration.

Examples live in a separate Swift package under `Examples/`. Each example is an
executable target with its own complete `main.swift`, imports `SwiftNumerica`,
uses deterministic input data, prints output and interpretation, and links to a
stable educational reference such as Wikipedia when available.

`Examples/COVERAGE.md` maps public symbols to the executable target that
demonstrates them. `Examples/EXPECTED_OUTPUT.md` records the expected results
for each executable target, using approximate language for floating point output
and semantic checks for intentionally random helpers.

Implemented example targets:

- `BackendConfigurationExample`
- `CombinatoricsExample`
- `ContinuousDistributionsExample`
- `CorrelationCovarianceExample`
- `DataProfilingLawsExample`
- `DataProfilingQualityExample`
- `DataProfilingExample`
- `DataScienceCSVExample`
- `DataScienceGroupingExample`
- `DataScienceExample`
- `DescriptiveCentralTendencyExample`
- `DescriptiveDispersionExample`
- `DescriptiveOrderStatisticsExample`
- `DescriptiveShapeExample`
- `DescriptiveStatisticsExample`
- `DiscreteDistributionsExample`
- `DistributionFittingExample`
- `ExpectedValueExample`
- `HypothesisTestingExample`
- `LinearAlgebraExample`
- `LinearRegressionExample`
- `LogisticRegressionExample`
- `MarkovChainExample`
- `MonteCarloSimulationExample`
- `MultipleLinearRegressionExample`
- `OptimizationExample`
- `PolynomialRegressionExample`
- `ProbabilityDistributionsExample`
- `RandomWalkExample`
- `RegressionExample`
- `SignalProcessingConvolutionExample`
- `SignalProcessingFiltersExample`
- `SignalProcessingTransformsExample`
- `SimulationExample`
- `TensorBasicsExample`

Example usage:

```bash
cd Examples
swift run SignalProcessingTransformsExample
```

Future work should keep `Examples/COVERAGE.md` and
`Examples/EXPECTED_OUTPUT.md` current whenever public symbols or example output
change.

## Backend Strategy

- Keep PureSwift implementations as the correctness baseline.
- Use Accelerate for vectorized statistics, linear algebra, and batch
  probability operations where it reduces runtime or allocations.
- Use Accelerate/vDSP for FFT, convolution, correlation, windowing, and
  filtering when it improves performance without leaking backend details.
- Prefer SIMD for small fixed-width operations when it improves clarity and
  performance.
- Keep MLX interoperability in `Adapters/SwiftNumericaMLX` so users can convert
  tensors to MLX arrays without making MLX a transitive dependency of the core
  package.
- Keep backend details internal. Public APIs should remain backend-independent.
- Validate accelerated implementations against PureSwift within documented
  tolerances.

## Success Criterion

SwiftNumerica should become the default Swift package for statistics,
probability, optimization, signal processing, and scientific computing on Apple
Silicon.
