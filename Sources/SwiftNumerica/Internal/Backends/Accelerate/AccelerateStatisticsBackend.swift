#if canImport(Accelerate)
import Accelerate
#endif

internal struct AccelerateStatisticsBackend: StatisticsBackend {
    private let reference = PureSwiftStatisticsBackend()

    internal func mean(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        var result = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_meanvD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func median(_ tensor: Tensor<Double>) -> Double? { reference.median(tensor) }
    internal func mode(_ tensor: Tensor<Double>) -> [Double] { reference.mode(tensor) }

    internal func range(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        var minimum = 0.0
        var maximum = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_minvD(buffer.baseAddress!, 1, &minimum, vDSP_Length(buffer.count))
            vDSP_maxvD(buffer.baseAddress!, 1, &maximum, vDSP_Length(buffer.count))
        }
        return maximum - minimum
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func populationVariance(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        guard let mean = mean(tensor) else {
            return nil
        }
        var meanSquare = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_measqvD(buffer.baseAddress!, 1, &meanSquare, vDSP_Length(buffer.count))
        }
        return max(0, meanSquare - mean * mean)
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func sampleVariance(_ tensor: Tensor<Double>) -> Double? {
        guard tensor.count > 1,
              let populationVariance = populationVariance(tensor) else {
            return nil
        }

        return populationVariance * Double(tensor.count) / Double(tensor.count - 1)
    }

    internal func populationStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        populationVariance(tensor).map { $0.squareRoot() }
    }

    internal func sampleStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        sampleVariance(tensor).map { $0.squareRoot() }
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

    private func accelerateUnavailable<T>() -> T {
        preconditionFailure(
            "Accelerate backend was resolved while Accelerate is unavailable. BackendResolver must throw BackendError.unavailable(.accelerate) before this backend is used."
        )
    }
}
