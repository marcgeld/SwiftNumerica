# SwiftNumerica Example Coverage

This document maps SwiftNumerica's public API symbols to standalone executable
examples. Each target is runnable with `swift run <TargetName>` from this
directory.

Coverage is intentionally practical: broad overview examples remain available,
while focused examples provide smaller copy-pasteable entry points for the main
public symbols.

## Runtime And Namespaces

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `ComputeBackend` | enum | `BackendConfigurationExample` |
| `ComputeBackend.isAvailable` | property | `BackendConfigurationExample` |
| `BackendError` | enum | `BackendConfigurationExample` |
| `NumericaConfiguration` | struct | `BackendConfigurationExample` |
| `NumericaConfiguration.backend` | property | `BackendConfigurationExample` |
| `Numerica.configuration` | property | `BackendConfigurationExample` |
| `Numerica.resolvedBackend()` | function | `BackendConfigurationExample` |
| `Numerica.Statistics` | namespace | `DescriptiveStatisticsExample`, `HypothesisTestingExample`, `RegressionExample` |
| `Numerica.Probability` | namespace | `ProbabilityDistributionsExample` |
| `Numerica.Combinatorics` | namespace | `CombinatoricsExample` |
| `Numerica.DataProfiling` | namespace | `DataProfilingExample` |
| `Numerica.Optimization` | namespace | `OptimizationExample` |
| `Numerica.LinearAlgebra` | namespace | `LinearAlgebraExample` |
| `Numerica.Simulation` | namespace | `SimulationExample` |
| `Numerica.SignalProcessing` | namespace | `SignalProcessingTransformsExample`, `SignalProcessingFiltersExample`, `SignalProcessingConvolutionExample` |
| `Numerica.DataScience` | namespace | `DataScienceExample` |

## Tensor, Vector, And Matrix

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Shape` | struct | `TensorBasicsExample` |
| `Shape.dimensions` | property | `TensorBasicsExample` |
| `Shape.rank` | property | `TensorBasicsExample` |
| `Shape.count` | property | `TensorBasicsExample` |
| `Shape.init(_:)` | initializer | `TensorBasicsExample` |
| `Shape == [Int]` | operator | `TensorBasicsExample` |
| `[Int] == Shape` | operator | `TensorBasicsExample` |
| `Tensor` | struct | `TensorBasicsExample` |
| `Tensor.shape` | property | `TensorBasicsExample` |
| `Tensor.values` | property | all tensor-based examples |
| `Tensor.rank` | property | `TensorBasicsExample` |
| `Tensor.count` | property | `TensorBasicsExample` |
| `Tensor.init(_:shape:)` | initializer | `TensorBasicsExample` |
| `Tensor.reshaped(to:)` | method | `TensorBasicsExample` |
| `Tensor.scalar(_:)` | factory | `TensorBasicsExample` |
| `Tensor.vector(_:)` | factory | most examples |
| `Tensor.matrix(_:)` | factory | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Tensor.multidimensional(_:dimensions:)` | factory | `TensorBasicsExample` |
| `TensorError` | enum | `TensorBasicsExample` |
| `TensorIndex` | struct | `TensorBasicsExample` |
| `TensorIndex.coordinates` | property | `TensorBasicsExample` |
| `TensorIndex.init(_:)` | initializer | `TensorBasicsExample` |
| `Vector` | struct | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Vector.tensor` | property | `TensorBasicsExample` |
| `Vector.values` | property | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Vector.count` | property | `TensorBasicsExample` |
| `Vector.init(_:)` | initializer | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Vector.init(_ tensor:)` | initializer | `TensorBasicsExample` |
| `Vector.subscript(_:)` | subscript | `TensorBasicsExample` |
| `Matrix` | struct | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Matrix.tensor` | property | `TensorBasicsExample` |
| `Matrix.values` | property | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Matrix.rowCount` | property | `TensorBasicsExample` |
| `Matrix.columnCount` | property | `TensorBasicsExample` |
| `Matrix.rows` | property | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Matrix.isSquare` | property | `TensorBasicsExample` |
| `Matrix.init(_ rows:)` | initializer | `TensorBasicsExample`, `LinearAlgebraExample` |
| `Matrix.init(values:rows:columns:)` | initializer | `TensorBasicsExample` |
| `Matrix.init(_ tensor:)` | initializer | `TensorBasicsExample` |
| `Matrix.subscript(row:column:)` | subscript | `TensorBasicsExample` |

## Descriptive Statistics

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Numerica.Statistics.sum(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.min(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.max(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.mean(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.median(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.mode(_:)` | function | `DescriptiveCentralTendencyExample` |
| `Numerica.Statistics.range(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.variance(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.populationVariance(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.sampleVariance(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.standardDeviation(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.populationStandardDeviation(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.sampleStandardDeviation(_:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.zScore(value:mean:standardDeviation:)` | function | `DescriptiveDispersionExample` |
| `Numerica.Statistics.quantile(_:probability:)` | function | `DescriptiveOrderStatisticsExample` |
| `Numerica.Statistics.percentile(_:percentile:)` | function | `DescriptiveOrderStatisticsExample` |
| `Numerica.Statistics.interquartileRange(_:)` | function | `DescriptiveOrderStatisticsExample` |
| `Numerica.Statistics.skewness(_:)` | function | `DescriptiveShapeExample` |
| `Numerica.Statistics.kurtosis(_:)` | function | `DescriptiveShapeExample` |
| `Tensor.sum()` | method | `DescriptiveStatisticsExample` |
| `Tensor.min()` | method | `DescriptiveStatisticsExample` |
| `Tensor.max()` | method | `DescriptiveStatisticsExample` |
| `Tensor.mean()` | method | `DescriptiveCentralTendencyExample` |
| `Tensor.median()` | method | `DescriptiveCentralTendencyExample` |
| `Tensor.mode()` | method | `DescriptiveStatisticsExample` |
| `Tensor.range()` | method | `DescriptiveStatisticsExample` |
| `Tensor.variance()` | method | `DescriptiveStatisticsExample` |
| `Tensor.populationVariance()` | method | `DescriptiveDispersionExample` |
| `Tensor.sampleVariance()` | method | `DescriptiveStatisticsExample` |
| `Tensor.standardDeviation()` | method | `DescriptiveStatisticsExample` |
| `Tensor.populationStandardDeviation()` | method | `DescriptiveDispersionExample` |
| `Tensor.sampleStandardDeviation()` | method | `DescriptiveStatisticsExample` |
| `Tensor.quantile(_:)` | method | `DescriptiveOrderStatisticsExample` |
| `Tensor.percentile(_:)` | method | `DescriptiveOrderStatisticsExample` |
| `Tensor.interquartileRange()` | method | `DescriptiveOrderStatisticsExample` |
| `Tensor.skewness()` | method | `DescriptiveShapeExample` |
| `Tensor.kurtosis()` | method | `DescriptiveShapeExample` |

## Correlation And Distribution Analysis

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Numerica.Statistics.covariance(_:_:)` | function | `CorrelationCovarianceExample` |
| `Numerica.Statistics.populationCovariance(_:_:)` | function | `CorrelationCovarianceExample` |
| `Numerica.Statistics.sampleCovariance(_:_:)` | function | `CorrelationCovarianceExample` |
| `Numerica.Statistics.correlation(_:_:)` | function | `CorrelationCovarianceExample` |
| `Numerica.Statistics.pearsonCorrelation(_:_:)` | function | `CorrelationCovarianceExample` |
| `Numerica.Statistics.spearmanCorrelation(_:_:)` | function | `CorrelationCovarianceExample` |
| `Tensor.covariance(with:)` | method | `CorrelationCovarianceExample` |
| `Tensor.populationCovariance(with:)` | method | `CorrelationCovarianceExample` |
| `Tensor.sampleCovariance(with:)` | method | `CorrelationCovarianceExample` |
| `Tensor.correlation(with:)` | method | `CorrelationCovarianceExample` |
| `Numerica.Statistics.DistributionAnalysis` | enum | `DistributionFittingExample` |
| `DistributionAnalysis.fitNormal(_:)` | function | `DistributionFittingExample` |
| `DistributionAnalysis.fitUniform(_:)` | function | `DistributionFittingExample` |
| `DistributionAnalysis.fitExponential(_:)` | function | `DistributionFittingExample` |

## Probability

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `ContinuousDistribution` | protocol | `ContinuousDistributionsExample` |
| `ContinuousDistribution.mean` | property | `ContinuousDistributionsExample` |
| `ContinuousDistribution.variance` | property | `ContinuousDistributionsExample` |
| `ContinuousDistribution.pdf(_:)` | method | `ContinuousDistributionsExample` |
| `ContinuousDistribution.cdf(_:)` | method | `ContinuousDistributionsExample` |
| `ContinuousDistribution.inverseCDF(_:)` | method | `ContinuousDistributionsExample` |
| `ContinuousDistribution.sample()` | method | `ContinuousDistributionsExample` |
| `ContinuousDistribution.sample(count:)` | method | `ContinuousDistributionsExample` |
| `ContinuousDistribution.sample(count:using:)` | method | `ContinuousDistributionsExample` |
| `DiscreteDistribution` | protocol | `DiscreteDistributionsExample` |
| `DiscreteDistribution.mean` | property | `DiscreteDistributionsExample` |
| `DiscreteDistribution.variance` | property | `DiscreteDistributionsExample` |
| `DiscreteDistribution.pmf(_:)` | method | `DiscreteDistributionsExample` |
| `DiscreteDistribution.cdf(_:)` | method | `DiscreteDistributionsExample` |
| `DiscreteDistribution.inverseCDF(_:)` | method | `DiscreteDistributionsExample` |
| `DiscreteDistribution.sample()` | method | `DiscreteDistributionsExample` |
| `DiscreteDistribution.sample(count:)` | method | `DiscreteDistributionsExample` |
| `DiscreteDistribution.sample(count:using:)` | method | `DiscreteDistributionsExample` |
| `ExpectedValue.discrete(values:probabilities:)` | function | `ExpectedValueExample` |
| `NormalDistribution` and members | type | `ContinuousDistributionsExample` |
| `UniformDistribution` and members | type | `ContinuousDistributionsExample` |
| `ExponentialDistribution` and members | type | `ContinuousDistributionsExample` |
| `BetaDistribution` and members | type | `ContinuousDistributionsExample` |
| `GammaDistribution` and members | type | `ContinuousDistributionsExample` |
| `BinomialDistribution` and members | type | `DiscreteDistributionsExample` |
| `PoissonDistribution` and members | type | `DiscreteDistributionsExample` |
| `HypergeometricDistribution` and members | type | `DiscreteDistributionsExample` |
| `SeededRandomNumberGenerator` | type | `ProbabilityDistributionsExample` |

Distribution member coverage includes public initializer parameters, stored
parameters, `mean`, `variance`, density or mass functions, `cdf`, `inverseCDF`,
`probability(at:)`, and `sample(using:)`.

## Hypothesis Testing

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `HypothesisTesting` | typealias | `HypothesisTestingExample` |
| `AlternativeHypothesis` | typealias | `HypothesisTestingExample` |
| `ConfidenceInterval` | typealias | `HypothesisTestingExample` |
| `HypothesisTestResult` | typealias | `HypothesisTestingExample` |
| `HypothesisTesting.ConfidenceInterval` and members | struct | `HypothesisTestingExample` |
| `HypothesisTesting.AlternativeHypothesis` | enum | `HypothesisTestingExample` |
| `HypothesisTesting.HypothesisTestResult` and members | struct | `HypothesisTestingExample` |
| `HypothesisTesting.welchTTest(_:_:alternative:confidenceLevel:)` | function | `HypothesisTestingExample` |
| `HypothesisTesting.pairedTTest(_:_:alternative:confidenceLevel:)` | function | `HypothesisTestingExample` |
| `HypothesisTesting.chiSquareGoodnessOfFit(observed:expected:)` | function | `HypothesisTestingExample` |
| `HypothesisTesting.oneWayANOVA(_:)` | function | `HypothesisTestingExample` |
| `HypothesisTesting.mannWhitneyU(_:_:alternative:)` | function | `HypothesisTestingExample` |
| `HypothesisTesting.kolmogorovSmirnovTest(_:distribution:)` | function | `HypothesisTestingExample`, `DistributionFittingExample` |

## Regression

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `LinearRegressionResult` and members | struct | `LinearRegressionExample` |
| `MultipleLinearRegressionResult` and members | struct | `MultipleLinearRegressionExample` |
| `LogisticRegressionResult` and members | struct | `LogisticRegressionExample` |
| `PolynomialRegressionResult` and members | struct | `PolynomialRegressionExample` |
| `Numerica.Statistics.linearRegression(x:y:)` | function | `LinearRegressionExample` |
| `LinearRegressionResult.predict(_:)` | method | `LinearRegressionExample` |
| `LinearRegressionResult.predict(_ tensor:)` | method | `LinearRegressionExample` |
| `Numerica.Statistics.multipleLinearRegression(features:target:)` | function | `MultipleLinearRegressionExample` |
| `MultipleLinearRegressionResult.predict(_:)` | method | `MultipleLinearRegressionExample` |
| `Numerica.Statistics.logisticRegression(features:target:learningRate:iterations:)` | function | `LogisticRegressionExample` |
| `LogisticRegressionResult.predictProbability(_:)` | method | `LogisticRegressionExample` |
| `LogisticRegressionResult.predict(_:threshold:)` | method | `LogisticRegressionExample` |
| `Numerica.Statistics.polynomialRegression(x:y:degree:)` | function | `PolynomialRegressionExample` |
| `PolynomialRegressionResult.predict(_:)` | method | `PolynomialRegressionExample` |
| `PolynomialRegressionResult.predict(_ tensor:)` | method | `PolynomialRegressionExample` |
| `LinearRegression.fit(_:_:)` | method | `LinearRegressionExample` |
| `PolynomialRegression.fit(_:_:)` | method | `PolynomialRegressionExample` |
| `LogisticRegression.fit(features:target:)` | method | `LogisticRegressionExample` |

## Optimization

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Numerica.Optimization.Algorithm` | enum | `OptimizationExample` |
| `Numerica.Optimization.Options` and members | struct | `OptimizationExample` |
| `Numerica.Optimization.TerminationReason` | enum | `OptimizationExample` |
| `Numerica.Optimization.Result` and members | struct | `OptimizationExample` |
| `Numerica.Optimization.minimize(function:initialGuess:gradient:options:)` | function | `OptimizationExample` |
| `Numerica.Optimization.maximize(function:initialGuess:gradient:options:)` | function | `OptimizationExample` |
| `minimize(function:initialGuess:gradient:options:)` | free function | `OptimizationExample` |
| `maximize(function:initialGuess:gradient:options:)` | free function | `OptimizationExample` |

## Linear Algebra

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Numerica.LinearAlgebra.determinant(_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.inverse(_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.solve(_:_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.solve(_:_:)` (matrix right-hand side) | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.choleskyDecomposition(_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.logDeterminant(_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.eigenvalues(_:)` | function | `LinearAlgebraExample` |
| `Numerica.LinearAlgebra.eigenvectors(_:)` | function | `LinearAlgebraExample` |
| `Matrix.determinant()` | method | `LinearAlgebraExample` |
| `Matrix.inverse()` | method | `LinearAlgebraExample` |
| `Matrix.solve(_:)` | method | `LinearAlgebraExample` |
| `Matrix.solve(_:)` (matrix right-hand side) | method | `LinearAlgebraExample` |
| `Matrix.choleskyDecomposition()` | method | `LinearAlgebraExample` |
| `Matrix.logDeterminant()` | method | `LinearAlgebraExample` |
| `Matrix.eigenvalues()` | method | `LinearAlgebraExample` |
| `Matrix.eigenvectors()` | method | `LinearAlgebraExample` |
| `determinant(_:)` | free function | `LinearAlgebraExample` |
| `inverse(_:)` | free function | `LinearAlgebraExample` |
| `solve(_:_:)` | free function | `LinearAlgebraExample` |
| `choleskyDecomposition(_:)` | free function | `LinearAlgebraExample` |
| `logDeterminant(_:)` | free function | `LinearAlgebraExample` |
| `eigenvalues(_:)` | free function | `LinearAlgebraExample` |
| `eigenvectors(_:)` | free function | `LinearAlgebraExample` |

## Simulation

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `MonteCarloSimulation` | typealias | `MonteCarloSimulationExample` |
| `MonteCarloSimulation.Result` and members | struct | `MonteCarloSimulationExample` |
| `MonteCarloSimulation.init(iterations:)` | initializer | `MonteCarloSimulationExample` |
| `MonteCarloSimulation.run(using:estimator:)` | method | `MonteCarloSimulationExample` |
| `MonteCarloSimulation.run(estimator:)` | method | `MonteCarloSimulationExample` |
| `RandomWalk` | typealias | `RandomWalkExample` |
| `RandomWalk.Result` and members | struct | `RandomWalkExample` |
| `RandomWalk.init(initialValue:)` | initializer | `RandomWalkExample` |
| `RandomWalk.simulate(steps:using:step:)` | method | `RandomWalkExample` |
| `RandomWalk.simulate(steps:using:increments:)` | method | `RandomWalkExample` |
| `RandomWalk.simulate(steps:step:)` | method | `RandomWalkExample` |
| `MarkovChain` | typealias | `MarkovChainExample` |
| `MarkovChain.Result` and members | struct | `MarkovChainExample` |
| `MarkovChain.init(states:transitionProbabilities:)` | initializer | `MarkovChainExample` |
| `MarkovChain.nextState(from:using:)` | method | `MarkovChainExample` |
| `MarkovChain.simulate(startingAt:steps:using:)` | method | `MarkovChainExample` |
| `MarkovChain.simulate(startingAt:steps:)` | method | `MarkovChainExample` |

## Signal Processing

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Signal` | typealias | `SignalProcessingTransformsExample` |
| `ComplexNumber` | typealias | `SignalProcessingTransformsExample` |
| `Peak` | typealias | `SignalProcessingTransformsExample` |
| `BiquadFilter` | typealias | `SignalProcessingFiltersExample` |
| `ComplexNumber.real` | property | `SignalProcessingTransformsExample` |
| `ComplexNumber.imaginary` | property | `SignalProcessingTransformsExample` |
| `ComplexNumber.magnitude` | property | `SignalProcessingTransformsExample` |
| `ComplexNumber.phase` | property | `SignalProcessingTransformsExample` |
| `Peak.index`, `Peak.value`, `Peak.prominence` | properties | `SignalProcessingTransformsExample` |
| `BiquadFilter` parameters | properties | `SignalProcessingFiltersExample` |
| `BiquadFilter.applied(to:)` | method | `SignalProcessingFiltersExample` |
| `Signal.samples`, `Signal.sampleRate`, `Signal.values`, `Signal.count` | properties | `SignalProcessingTransformsExample` |
| `Signal.fft()` | method | `SignalProcessingTransformsExample` |
| `Signal.movingAverage(windowSize:)` | method | `SignalProcessingTransformsExample` |
| `Signal.detrended()` | method | `SignalProcessingTransformsExample` |
| `Signal.normalized()` | method | `SignalProcessingTransformsExample` |
| `Signal.peaks(minimumProminence:)` | method | `SignalProcessingTransformsExample` |
| `Signal.periodogram()` | method | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.fft(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.inverseFFT(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.convolve(_:with:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.correlate(_:with:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.autocorrelation(_:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.movingAverage(_:windowSize:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.rectangularWindow(size:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.hannWindow(size:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.hammingWindow(size:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.blackmanWindow(size:)` | function | `SignalProcessingConvolutionExample` |
| `Numerica.SignalProcessing.detrend(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.normalize(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.zeroCrossingRate(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.peakDetection(_:minimumProminence:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.periodogram(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.magnitudeSpectrum(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.phaseSpectrum(_:)` | function | `SignalProcessingTransformsExample` |
| `Numerica.SignalProcessing.lowPassFilter(...)` | function | `SignalProcessingFiltersExample` |
| `Numerica.SignalProcessing.highPassFilter(...)` | function | `SignalProcessingFiltersExample` |
| `Numerica.SignalProcessing.bandPassFilter(...)` | function | `SignalProcessingFiltersExample` |
| `Numerica.SignalProcessing.bandStopFilter(...)` | function | `SignalProcessingFiltersExample` |
| `Numerica.SignalProcessing.apply(_:to:)` | function | `SignalProcessingFiltersExample` |
| `Tensor.fft()` | method | `SignalProcessingTransformsExample` |
| `Tensor.movingAverage(windowSize:)` | method | `SignalProcessingTransformsExample` |
| `Tensor.detrended()` | method | `SignalProcessingTransformsExample` |
| `Tensor.normalized()` | method | `SignalProcessingTransformsExample` |

## Combinatorics

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `Numerica.Combinatorics.factorial(_:)` | function | `CombinatoricsExample` |
| `Numerica.Combinatorics.combinations(n:r:)` | function | `CombinatoricsExample` |
| `Numerica.Combinatorics.permutations(n:r:)` | function | `CombinatoricsExample` |

## Data Profiling

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `BenfordAnalysis` and members | struct | `DataProfilingLawsExample` |
| `ZipfEntry` and members | struct | `DataProfilingLawsExample` |
| `ZipfAnalysis` and members | struct | `DataProfilingLawsExample` |
| `ParetoAnalysis` and members | struct | `DataProfilingLawsExample` |
| `NormalityAnalysis` and members | struct | `DataProfilingQualityExample` |
| `UniformityAnalysis` and members | struct | `DataProfilingQualityExample` |
| `OutlierAnalysis` and members | struct | `DataProfilingQualityExample` |
| `TrendAnalysis` and members | struct | `DataProfilingQualityExample` |
| `SummaryStatistics` and members | struct | `DataProfilingQualityExample` |
| `DatasetProfile` and members | struct | `DataProfilingQualityExample` |
| `DatasetProfiler.profile(_:)` | function | `DataProfilingQualityExample` |
| `Numerica.DataProfiling.benfordAnalysis(_:)` | function | `DataProfilingLawsExample` |
| `Numerica.DataProfiling.zipfAnalysis(_:)` | function | `DataProfilingLawsExample` |
| `Numerica.DataProfiling.paretoAnalysis(_:)` | function | `DataProfilingLawsExample` |
| `Numerica.DataProfiling.normalityAnalysis(_:)` | function | `DataProfilingQualityExample` |
| `Numerica.DataProfiling.uniformityAnalysis(_:bucketCount:)` | function | `DataProfilingQualityExample` |
| `Numerica.DataProfiling.outlierAnalysis(_:)` | function | `DataProfilingQualityExample` |
| `Numerica.DataProfiling.trendAnalysis(_:)` | function | `DataProfilingQualityExample` |
| `Numerica.DataProfiling.growthRates(_:)` | function | `DataProfilingQualityExample` |

## Data Science

| Public symbol | Kind | Example target |
| --- | --- | --- |
| `DataTable` | typealias | `DataScienceCSVExample`, `DataScienceGroupingExample` |
| `ColumnSummary` | typealias | `DataScienceGroupingExample` |
| `GroupedDataTable` | typealias | `DataScienceGroupingExample` |
| `DataTable.columns`, `DataTable.rows` | properties | `DataScienceCSVExample` |
| `DataTable.rowCount`, `DataTable.columnCount` | properties | `DataScienceCSVExample` |
| `DataTable.init(columns:rows:)` | initializer | `DataScienceGroupingExample` |
| `DataTable.init(tensor:columnNames:)` | initializer | `DataScienceGroupingExample` |
| `DataTable.init(numericColumns:)` | initializer | `DataScienceGroupingExample` |
| `DataTable.column(_:)` | method | `DataScienceCSVExample` |
| `DataTable.numericColumn(_:)` | method | `DataScienceCSVExample` |
| `DataTable.tensor(columns:)` | method | `DataScienceCSVExample` |
| `DataTable.summary(for:)` | method | `DataScienceGroupingExample` |
| `DataTable.summaries()` | method | `DataScienceGroupingExample` |
| `DataTable.grouped(by:)` | method | `DataScienceGroupingExample` |
| `DataTable.importCSV(_:hasHeader:)` | function | `DataScienceCSVExample` |
| `DataTable.importCSV(from:hasHeader:)` | function | `DataScienceCSVExample` |
| `DataTable.csvString(includeHeader:)` | method | `DataScienceCSVExample`, `DataScienceGroupingExample` |
| `DataTable.exportCSV(to:includeHeader:)` | method | `DataScienceCSVExample` |
| `ColumnSummary` members | properties | `DataScienceGroupingExample` |
| `GroupedDataTable.groupColumn`, `GroupedDataTable.groups` | properties | `DataScienceGroupingExample` |
| `GroupedDataTable.groupKeys` | property | `DataScienceGroupingExample` |
| `GroupedDataTable.summaries()` | method | `DataScienceGroupingExample` |
| `DataTable.init(dataFrame:stringColumns:numericColumns:)` | conditional initializer | See note below |

The TabularData bridge is public only when `TabularData` is available. It is
tracked here as a conditional symbol; the standalone examples avoid making the
examples package depend on platform-specific data-frame availability.
