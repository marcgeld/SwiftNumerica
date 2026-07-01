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

    internal func skewness(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty,
              let mean = mean(tensor),
              let standardDeviation = populationStandardDeviation(tensor),
              standardDeviation != 0 else { return nil }

        #if canImport(Accelerate)
        let centered = centeredValues(tensor.values, mean: mean)
        let secondPowers = multiplied(centered, centered)
        let thirdPowers = multiplied(secondPowers, centered)
        let standardDeviationCubed = standardDeviation * standardDeviation * standardDeviation
        return sum(thirdPowers) / Double(tensor.count) / standardDeviationCubed
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func kurtosis(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty,
              let mean = mean(tensor),
              let standardDeviation = populationStandardDeviation(tensor),
              standardDeviation != 0 else { return nil }

        #if canImport(Accelerate)
        let centered = centeredValues(tensor.values, mean: mean)
        let secondPowers = multiplied(centered, centered)
        let fourthPowers = multiplied(secondPowers, secondPowers)
        let standardDeviationSquared = standardDeviation * standardDeviation
        let standardDeviationFourth = standardDeviationSquared * standardDeviationSquared
        return sum(fourthPowers) / Double(tensor.count) / standardDeviationFourth - 3
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func quantile(_ tensor: Tensor<Double>, probability: Double) -> Double? {
        reference.quantile(tensor, probability: probability)
    }
    internal func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double? {
        reference.zScore(value: value, mean: mean, standardDeviation: standardDeviation)
    }

    internal func pearsonCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        guard x.count == y.count, x.count > 1,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        #if canImport(Accelerate)
        let xCentered = centeredValues(x.values, mean: xMean)
        let yCentered = centeredValues(y.values, mean: yMean)
        let numerator = dot(xCentered, yCentered)
        let denominator = (sumOfSquares(xCentered) * sumOfSquares(yCentered)).squareRoot()
        guard denominator != 0 else { return nil }
        return numerator / denominator
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func spearmanCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        reference.spearmanCorrelation(x, y)
    }

    internal func linearRegression(x: Tensor<Double>, y: Tensor<Double>) -> Numerica.Statistics
        .LinearRegressionResult?
    {
        guard x.count == y.count, x.count > 1,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        #if canImport(Accelerate)
        let xCentered = centeredValues(x.values, mean: xMean)
        let yCentered = centeredValues(y.values, mean: yMean)
        let numerator = dot(xCentered, yCentered)
        let denominator = sumOfSquares(xCentered)
        guard denominator != 0 else { return nil }

        let slope = numerator / denominator
        let intercept = yMean - slope * xMean
        let ySumSquares = sumOfSquares(yCentered)
        let rSquared = ySumSquares == 0
            ? 0
            : (numerator * numerator) / (denominator * ySumSquares)
        return .init(slope: slope, intercept: intercept, rSquared: rSquared)
        #else
        return accelerateUnavailable()
        #endif
    }

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

    #if canImport(Accelerate)
    private func centeredValues(_ values: [Double], mean: Double) -> [Double] {
        var offset = -mean
        var result = Array(repeating: 0.0, count: values.count)
        values.withUnsafeBufferPointer { source in
            result.withUnsafeMutableBufferPointer { destination in
                vDSP_vsaddD(
                    source.baseAddress!, 1,
                    &offset,
                    destination.baseAddress!, 1,
                    vDSP_Length(source.count)
                )
            }
        }
        return result
    }

    private func multiplied(_ left: [Double], _ right: [Double]) -> [Double] {
        var result = Array(repeating: 0.0, count: left.count)
        left.withUnsafeBufferPointer { leftBuffer in
            right.withUnsafeBufferPointer { rightBuffer in
                result.withUnsafeMutableBufferPointer { resultBuffer in
                    vDSP_vmulD(
                        leftBuffer.baseAddress!, 1,
                        rightBuffer.baseAddress!, 1,
                        resultBuffer.baseAddress!, 1,
                        vDSP_Length(leftBuffer.count)
                    )
                }
            }
        }
        return result
    }

    private func dot(_ left: [Double], _ right: [Double]) -> Double {
        var result = 0.0
        left.withUnsafeBufferPointer { leftBuffer in
            right.withUnsafeBufferPointer { rightBuffer in
                vDSP_dotprD(
                    leftBuffer.baseAddress!, 1,
                    rightBuffer.baseAddress!, 1,
                    &result,
                    vDSP_Length(leftBuffer.count)
                )
            }
        }
        return result
    }

    private func sum(_ values: [Double]) -> Double {
        var result = 0.0
        values.withUnsafeBufferPointer { buffer in
            vDSP_sveD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
    }

    private func sumOfSquares(_ values: [Double]) -> Double {
        var result = 0.0
        values.withUnsafeBufferPointer { buffer in
            vDSP_svesqD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
    }
    #endif
}
