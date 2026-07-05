# Expected Example Output

This file records the expected results for the standalone examples.

Floating point values should be read with normal numerical tolerance. Dictionary
print order is not part of Swift's API contract, so examples that print
dictionaries should match by keys and values rather than by textual order.
Examples that intentionally call no-argument random sampling print stable
properties such as `is finite` or sample counts instead of exact random values.

## BackendConfigurationExample

- Default backend starts as `automatic`.
- Pure Swift mean is `2.5`.
- Automatic and Accelerate means are `2.5` when Accelerate is available.
- Reset backend is `automatic`.

## CombinatoricsExample

```text
5! (expected 120): 120
10 choose 3 (expected 120): 120
10 permute 3 (expected 720): 720
```

## ContinuousDistributionsExample

- Normal PDF at `0` is approximately `0.39894228040143265`.
- Normal CDF at `1.96` is approximately `0.9750021738917761`.
- Normal inverse CDF at `0.975` is approximately `1.9599628032746725`.
- Uniform PDF/CDF/inverse at the shown inputs are `0.5`, `0.5`, and `0.5`.
- Exponential mean and variance for rate `2` are `0.5` and `0.25`.
- Beta mean and variance for alpha/beta `2, 2` are `0.5` and `0.05`.
- Gamma mean and variance for shape/scale `2, 2` are `4.0` and `8.0`.
- No-argument sample prints `true` for finite output.
- Sample helper counts print `3`.

## CorrelationCovarianceExample

```text
Population covariance: 4.0
Sample covariance: 5.0
Covariance alias: 5.0
Pearson correlation: 1.0
Spearman correlation: 1.0
Correlation alias: 1.0
Value-style covariance: 5.0
Value-style correlation: 1.0
```

## DataProfilingLawsExample

- Benford mean absolute deviation is approximately `0.0606533352604528`.
- Zipf analysis produces `8` entries for the sample data.
- Pareto top 20 percent share is approximately `0.9777777777777777`.
- Pareto-like is `true`.

## DataProfilingQualityExample

- Normality mean is `140.625`.
- Normality skewness is approximately `2.2276616272887173`.
- Uniform chi-square statistic is `17.0`.
- Outliers are `[100.0, 1000.0]`.
- Trend slope is approximately `89.3452380952381`.
- Growth rates are `[1.0, 0.5, 0.3333333333333333, 0.25, 1.0, 9.0, 9.0]`.
- Dataset summary mean is `3.75`.
- Correlation matrix entries are all `1.0`.

## DataProfilingExample

- Benford MAD is approximately `0.0606533352604528`.
- Zipf entries count is `8`.
- Pareto top 20 percent share is approximately `0.9777777777777777`.
- Normality skewness is approximately `2.2276616272887173`.
- Uniform chi-square is `17.0`.
- Outlier values are `[100.0, 1000.0]`.
- Dataset summary mean is `3.75`.

## DataScienceCSVExample

- Columns are `["group", "value", "note"]`.
- Row count is `3`.
- Column count is `3`.
- Note column is `["first", "second", "third"]`.
- Numeric value column is `[1.0, 3.0, 10.0]`.
- Tensor values are `[1.0, 3.0, 10.0]`.
- Reloaded CSV rows match the imported rows.

## DataScienceGroupingExample

- Summary count is `3`.
- Summary mean is approximately `4.666666666666667`.
- Group keys are `["a", "b"]`.
- Tensor table CSV is:

```text
x,y
1.0,2.0
3.0,4.0
```

- Numeric table CSV is:

```text
x,y
1.0,3.0
2.0,4.0
```

## DataScienceExample

- Numeric column is `[1.0, 3.0, 10.0]`.
- Summary mean is approximately `4.666666666666667`.
- All numeric summaries contain `["value"]`.
- Group keys are `["a", "b"]`.
- Reloaded CSV rows match the imported rows.

## DescriptiveCentralTendencyExample

```text
Sum: 40.0
Minimum: 2.0
Maximum: 9.0
Mean: 5.0
Median: 4.5
Mode: [4.0]
Value-style mean: 5.0
Value-style median: 4.5
```

## DescriptiveDispersionExample

```text
Range: 7.0
Population variance: 4.0
Sample variance: 4.571428571428571
Variance alias: 4.571428571428571
Population standard deviation: 2.0
Sample standard deviation: 2.138089935299395
Standard deviation alias: 2.138089935299395
Z-score for 9: 2.0
```

## DescriptiveOrderStatisticsExample

```text
First quartile: 4.0
Median percentile: 4.5
95th percentile: 8.299999999999999
Interquartile range: 1.5
Value-style interquartile range: 1.5
```

## DescriptiveShapeExample

```text
Skewness: 1.1419277952951876
Excess kurtosis: -0.10357001972386737
Value-style skewness: 1.1419277952951876
Value-style kurtosis: -0.10357001972386737
```

## DescriptiveStatisticsExample

- Sum/min/max/range are `40.0`, `2.0`, `9.0`, and `7.0`.
- Mean/median/mode are `5.0`, `4.5`, and `[4.0]`.
- Population variance and standard deviation are `4.0` and `2.0`.
- Sample variance and standard deviation are approximately
  `4.571428571428571` and `2.138089935299395`.
- 95th percentile is approximately `8.299999999999999`.
- Interquartile range is `1.5`.
- Z-score for `9` is `2.0`.

## DiscreteDistributionsExample

- Binomial PMF/CDF/inverse at the shown inputs are `0.24609375`,
  `0.623046875`, and `5`.
- Poisson PMF/CDF/inverse are approximately `0.22404180765538775`,
  `0.6472318887822313`, and `3`.
- Hypergeometric PMF/CDF/inverse are approximately `0.2994736356080894`,
  `0.958315633945886`, and `0`.
- No-argument sample prints `true` for support membership.
- Sample helper counts print `3`.

## DistributionFittingExample

```text
Fitted normal mean/std: 10.0 1.4142135623730951
Fitted uniform bounds: -2.0 3.0
Fitted exponential rate: 1.3333333333333333
Kolmogorov-Smirnov statistic: 0.16025000815237345
Kolmogorov-Smirnov p-value: 0.9983903404822662
```

## ExpectedValueExample

```text
Expected value: 11.0
```

## HypothesisTestingExample

- Welch statistic is `7.0`, p-value is approximately
  `5.631927456339891e-05`, and degrees of freedom are `8.0`.
- Paired t-test statistic is approximately `13.89758457944607`.
- Chi-square statistic is `15.0`.
- One-way ANOVA statistic is approximately `144.00000000000006`.
- Mann-Whitney U statistic is `25.0`.
- One-sample Kolmogorov-Smirnov statistic is approximately
  `0.17467806950096965`.

## LinearAlgebraExample

- Determinant is `10.0`.
- Inverse values are approximately `[0.6, -0.7, -0.2, 0.4]`.
- Solve values are approximately `[0.6, -0.2]`.
- Eigenvalues are `[3.0, 1.0]`.
- Eigenvectors are approximately
  `[0.7071067811865475, 0.7071067811865476, 0.7071067811865476, -0.7071067811865475]`.

## LinearRegressionExample

```text
Slope: 2.0
Intercept: 1.0
R squared: 1.0
Scalar prediction: 9.0
Vector prediction: [9.0, 11.0]
Model fit prediction: 9.0
```

## LogisticRegressionExample

- Iterations are `2000`.
- Learning rate is `0.5`.
- Probability for feature `[3]` is approximately `0.999987151069753`.
- Predicted class is `1`.

## MarkovChainExample

- States are `["sunny", "rainy"]`.
- Next seeded state is `sunny`.
- Seeded path is `["sunny", "sunny", "sunny", "sunny", "rainy", "rainy"]`.
- Unseeded path count is `6`.
- Unseeded state count total is `6`.

## MonteCarloSimulationExample

- Random estimates are deterministic with the fixed generator.
- Random mean is approximately `0.3235705269230825`.
- Random variance is approximately `0.06407711642300115`.
- Random standard error is approximately `0.11320522640143532`.
- Deterministic mean is `0.5`.

## MultipleLinearRegressionExample

```text
Coefficients: [3.0, 3.0]
Intercept: 3.0
R squared: 1.0
Prediction: 15.0
```

## OptimizationExample

- All algorithms converge near the solution `[3, -2]`.
- Gradient descent converges within `1e-3` of `[3, -2]`.
- Newton-Raphson, LBFGS, and Nelder-Mead converge within floating point
  tolerance of `[3, -2]`.
- Minimized objective value is approximately `0`.
- Maximized value for `-bowl` is approximately `0`.

## PolynomialRegressionExample

```text
Degree: 2
Coefficients: [1.0000000000000004, 2.0, 2.9999999999999996]
R squared: 1.0
Scalar prediction: 17.0
Vector prediction: [17.0, 34.0]
```

## ProbabilityDistributionsExample

- Expected value is `1.1`.
- Normal PDF/CDF/inverse at the shown inputs are approximately
  `0.39894228040143265`, `0.9750021738917761`, and `1.9599628032746725`.
- Uniform PDF/CDF/inverse are all `0.5`.
- Exponential mean/variance are `0.5` and `0.25`.
- Beta mean/variance are `0.5` and `0.05`.
- Gamma mean/variance are `4.0` and `8.0`.
- Binomial inverse is `5`, Poisson inverse is `3`, and Hypergeometric inverse
  is `0`.

## RandomWalkExample

- Random path with the fixed generator is `[0.0, -1.0, -2.0, -1.0, 0.0, 1.0]`.
- Distribution-driven path starts at `0.0` and contains `6` values.
- Deterministic final value is `5.0`.

## RegressionExample

- Simple linear slope/intercept/r-squared are `2.0`, `1.0`, and `1.0`.
- Multiple regression coefficients/intercept/r-squared are `[3.0, 3.0]`,
  `3.0`, and `1.0`.
- Polynomial degree is `2` and scalar prediction at `2` is `17.0`.
- Logistic predicted class is `1`.

## SignalProcessingConvolutionExample

```text
Convolution: [0.25, 1.0, 2.0, 3.0, 2.75, 1.0]
Correlation: [0.25, 1.0, 2.0, 3.0, 2.75, 1.0]
Autocorrelation: [4.0, 11.0, 20.0, 30.0, 20.0, 11.0, 4.0]
Moving average: [1.5, 2.0, 3.0, 3.5]
Rectangular window: [1.0, 1.0, 1.0, 1.0]
```

## SignalProcessingFiltersExample

- Biquad identity output is `[0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0]`.
- Value-style biquad output matches the direct `apply` output.
- FIR filter outputs are deterministic floating point vectors for the shown
  cutoff frequencies and filter length.

## SignalProcessingTransformsExample

- FFT magnitudes are approximately `[0.0, 2.0, 0.0, 2.0]`.
- Reconstructed samples are approximately `[1.0, 0.0, -1.0, 0.0]`.
- Periodogram is approximately `[0.0, 1.0, 0.0, 1.0]`.
- Zero crossing rate is `1.0`.
- Peak list is empty.

## SimulationExample

- Monte Carlo constant mean is `0.5`.
- Deterministic random walk final value is `5.0`.
- Next weather state with the fixed generator is `sunny`.
- Weather path count is `6`.
- State count total is `6`.

## TensorBasicsExample

- Scalar rank is `0`.
- Vector shape is `[4]`.
- Matrix tensor shape is `[2, 2]`.
- Reshaped vector shape is `[2, 2]`.
- Shape equality check is `true`.
- Tensor index is `[1, 0]`.
- Vector wrapper count is `4` and second value is `2.0`.
- Matrix dimensions are `2 x 2`.
