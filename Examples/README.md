# SwiftNumerica Examples

This package contains complete standalone executable examples for SwiftNumerica's
public API. Each example has its own `main.swift`, imports `SwiftNumerica`, uses
small deterministic input data, prints its output, and links to a relevant
reference when one is useful.

`COVERAGE.md` maps public symbols to the examples that demonstrate them.
`EXPECTED_OUTPUT.md` records the expected results for each executable example.

Run an example from this directory:

```bash
swift run SignalProcessingTransformsExample
```

Compare the printed output with `EXPECTED_OUTPUT.md`. Exact dictionary print
order is not guaranteed by Swift, and floating point values should be compared
with normal numerical tolerance.

Available examples:

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
