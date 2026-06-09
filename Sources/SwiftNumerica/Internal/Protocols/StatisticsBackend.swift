internal protocol StatisticsBackend: Sendable {
    func mean(_ tensor: Tensor<Double>) -> Double?
    func median(_ tensor: Tensor<Double>) -> Double?
    func mode(_ tensor: Tensor<Double>) -> [Double]
    func range(_ tensor: Tensor<Double>) -> Double?
    func populationVariance(_ tensor: Tensor<Double>) -> Double?
    func sampleVariance(_ tensor: Tensor<Double>) -> Double?
    func populationStandardDeviation(_ tensor: Tensor<Double>) -> Double?
    func sampleStandardDeviation(_ tensor: Tensor<Double>) -> Double?
    func skewness(_ tensor: Tensor<Double>) -> Double?
    func kurtosis(_ tensor: Tensor<Double>) -> Double?
    func quantile(_ tensor: Tensor<Double>, probability: Double) -> Double?
    func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double?
    func pearsonCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double?
    func spearmanCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double?
    func linearRegression(x: Tensor<Double>, y: Tensor<Double>) -> Numerica.Statistics.LinearRegressionResult?
    func multipleLinearRegression(features: Tensor<Double>, target: Tensor<Double>) -> Numerica.Statistics.MultipleLinearRegressionResult?
    func logisticRegression(features: Tensor<Double>, target: Tensor<Double>, learningRate: Double, iterations: Int) -> Numerica.Statistics.LogisticRegressionResult?
}
