internal struct MLXStatisticsBackend: StatisticsBackend {
    private let reference = PureSwiftStatisticsBackend()

    // TODO: Replace delegation with MLX-backed implementations while preserving
    // numerical equivalence with the PureSwift reference backend.
    internal func mean(_ tensor: Tensor<Double>) -> Double? { reference.mean(tensor) }
    internal func median(_ tensor: Tensor<Double>) -> Double? { reference.median(tensor) }
    internal func mode(_ tensor: Tensor<Double>) -> [Double] { reference.mode(tensor) }
    internal func range(_ tensor: Tensor<Double>) -> Double? { reference.range(tensor) }
    internal func populationVariance(_ tensor: Tensor<Double>) -> Double? {
        reference.populationVariance(tensor)
    }
    internal func sampleVariance(_ tensor: Tensor<Double>) -> Double? {
        reference.sampleVariance(tensor)
    }
    internal func populationStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        reference.populationStandardDeviation(tensor)
    }
    internal func sampleStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        reference.sampleStandardDeviation(tensor)
    }
    internal func skewness(_ tensor: Tensor<Double>) -> Double? { reference.skewness(tensor) }
    internal func kurtosis(_ tensor: Tensor<Double>) -> Double? { reference.kurtosis(tensor) }
    internal func quantile(_ tensor: Tensor<Double>, probability: Double) -> Double? {
        reference.quantile(tensor, probability: probability)
    }
    internal func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double? {
        reference.zScore(value: value, mean: mean, standardDeviation: standardDeviation)
    }
    internal func pearsonCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        reference.pearsonCorrelation(x, y)
    }
    internal func spearmanCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        reference.spearmanCorrelation(x, y)
    }
    internal func linearRegression(x: Tensor<Double>, y: Tensor<Double>) -> Numerica.Statistics
        .LinearRegressionResult?
    { reference.linearRegression(x: x, y: y) }
    internal func multipleLinearRegression(features: Tensor<Double>, target: Tensor<Double>)
        -> Numerica.Statistics.MultipleLinearRegressionResult?
    { reference.multipleLinearRegression(features: features, target: target) }
    internal func logisticRegression(
        features: Tensor<Double>, target: Tensor<Double>, learningRate: Double, iterations: Int
    ) -> Numerica.Statistics.LogisticRegressionResult? {
        reference.logisticRegression(
            features: features, target: target, learningRate: learningRate, iterations: iterations)
    }
}
