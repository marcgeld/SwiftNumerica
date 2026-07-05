#if canImport(Accelerate)
import Accelerate
#endif

internal struct AccelerateStatisticsBackend: StatisticsBackend {
    private let reference = PureSwiftStatisticsBackend()

    internal func sum(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        var result = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_sveD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func min(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        var result = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_minvD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func max(_ tensor: Tensor<Double>) -> Double? {
        guard !tensor.values.isEmpty else {
            return nil
        }

        #if canImport(Accelerate)
        var result = 0.0
        tensor.values.withUnsafeBufferPointer { buffer in
            vDSP_maxvD(buffer.baseAddress!, 1, &result, vDSP_Length(buffer.count))
        }
        return result
        #else
        return accelerateUnavailable()
        #endif
    }

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

    // Sort-dominated statistics (median, quantiles, Spearman ranks) delegate
    // to the reference implementation: vDSP_vsortD benchmarks slower than
    // Swift's standard sort, so Accelerate offers no win for these.
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
        guard !tensor.values.isEmpty,
              let mean = mean(tensor) else {
            return nil
        }

        #if canImport(Accelerate)
        // Two-pass centered sum of squares matches the PureSwift reference and
        // avoids the catastrophic cancellation of the E[x^2] - mean^2 form for
        // data with a large mean relative to its spread.
        let centered = centeredValues(tensor.values, mean: mean)
        return sumOfSquares(centered) / Double(tensor.count)
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

    internal func percentile(_ tensor: Tensor<Double>, percentile: Double) -> Double? {
        reference.percentile(tensor, percentile: percentile)
    }

    internal func interquartileRange(_ tensor: Tensor<Double>) -> Double? {
        reference.interquartileRange(tensor)
    }

    internal func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double? {
        reference.zScore(value: value, mean: mean, standardDeviation: standardDeviation)
    }

    internal func populationCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        #if canImport(Accelerate)
        covariance(x, y, denominator: x.count)
        #else
        accelerateUnavailable()
        #endif
    }

    internal func sampleCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        guard x.count > 1 else { return nil }
        #if canImport(Accelerate)
        return covariance(x, y, denominator: x.count - 1)
        #else
        return accelerateUnavailable()
        #endif
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
    {
        guard let dimensions = matrixDimensions(features),
              target.count == dimensions.rows,
              dimensions.rows > dimensions.columns else { return nil }

        #if canImport(Accelerate)
        let rows = dimensions.rows
        let columns = dimensions.columns + 1
        let design = designMatrix(from: features, rows: rows, columns: dimensions.columns)
        let transposed = transposedMatrix(design, rows: rows, columns: columns)
        let normalMatrix = matrixProduct(
            transposed, rows: columns, columns: rows,
            design, columns: columns
        )
        let normalTarget = matrixProduct(
            transposed, rows: columns, columns: rows,
            target.values, columns: 1
        )
        let normalRows = (0..<columns).map { row in
            Array(normalMatrix[(row * columns)..<((row + 1) * columns)])
        }
        guard let beta = LinearSystemMath.solve(normalRows, normalTarget) else { return nil }

        let predictions = matrixProduct(design, rows: rows, columns: columns, beta, columns: 1)
        var residuals = [Double](repeating: 0, count: rows)
        predictions.withUnsafeBufferPointer { predictionBuffer in
            target.values.withUnsafeBufferPointer { targetBuffer in
                residuals.withUnsafeMutableBufferPointer { residualBuffer in
                    vDSP_vsubD(
                        predictionBuffer.baseAddress!, 1,
                        targetBuffer.baseAddress!, 1,
                        residualBuffer.baseAddress!, 1,
                        vDSP_Length(rows)
                    )
                }
            }
        }
        let residualSumSquares = sumOfSquares(residuals)
        guard let targetMean = mean(target) else { return nil }
        let totalSumSquares = sumOfSquares(centeredValues(target.values, mean: targetMean))
        let rSquared = totalSumSquares == 0 ? 1 : 1 - residualSumSquares / totalSumSquares

        return .init(
            coefficients: Array(beta.dropFirst()),
            intercept: beta[0],
            rSquared: rSquared
        )
        #else
        return accelerateUnavailable()
        #endif
    }

    internal func logisticRegression(
        features: Tensor<Double>, target: Tensor<Double>, learningRate: Double, iterations: Int
    ) -> Numerica.Statistics.LogisticRegressionResult? {
        guard let dimensions = matrixDimensions(features),
              target.count == dimensions.rows,
              learningRate > 0,
              iterations > 0,
              target.values.allSatisfy({ $0 == 0 || $0 == 1 }) else { return nil }

        #if canImport(Accelerate)
        let rows = dimensions.rows
        let columns = dimensions.columns + 1
        let design = designMatrix(from: features, rows: rows, columns: dimensions.columns)
        let transposed = transposedMatrix(design, rows: rows, columns: columns)
        var weights = [Double](repeating: 0, count: columns)
        let stepScale = learningRate / Double(rows)

        for _ in 0..<iterations {
            let scores = matrixProduct(design, rows: rows, columns: columns, weights, columns: 1)
            let predictions = sigmoidValues(scores)
            var errors = [Double](repeating: 0, count: rows)
            target.values.withUnsafeBufferPointer { targetBuffer in
                predictions.withUnsafeBufferPointer { predictionBuffer in
                    errors.withUnsafeMutableBufferPointer { errorBuffer in
                        vDSP_vsubD(
                            targetBuffer.baseAddress!, 1,
                            predictionBuffer.baseAddress!, 1,
                            errorBuffer.baseAddress!, 1,
                            vDSP_Length(rows)
                        )
                    }
                }
            }
            let gradients = matrixProduct(transposed, rows: columns, columns: rows, errors, columns: 1)
            for weightIndex in weights.indices {
                weights[weightIndex] -= stepScale * gradients[weightIndex]
            }
        }

        return .init(
            coefficients: Array(weights.dropFirst()),
            intercept: weights[0],
            iterations: iterations,
            learningRate: learningRate
        )
        #else
        return accelerateUnavailable()
        #endif
    }

    private func accelerateUnavailable<T>() -> T {
        preconditionFailure(
            "Accelerate backend was resolved while Accelerate is unavailable. BackendResolver must throw BackendError.unavailable(.accelerate) before this backend is used."
        )
    }

    #if canImport(Accelerate)
    private func covariance(_ x: Tensor<Double>, _ y: Tensor<Double>, denominator: Int) -> Double? {
        guard x.count == y.count, x.count > 0,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        let xCentered = centeredValues(x.values, mean: xMean)
        let yCentered = centeredValues(y.values, mean: yMean)
        return dot(xCentered, yCentered) / Double(denominator)
    }

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

    private func matrixDimensions(_ tensor: Tensor<Double>) -> (rows: Int, columns: Int)? {
        guard tensor.rank == 2, tensor.shape.dimensions.count == 2 else { return nil }
        return (tensor.shape.dimensions[0], tensor.shape.dimensions[1])
    }

    /// Builds a row-major design matrix with a leading intercept column of ones.
    private func designMatrix(from tensor: Tensor<Double>, rows: Int, columns: Int) -> [Double] {
        var design = [Double](repeating: 1, count: rows * (columns + 1))
        for row in 0..<rows {
            for column in 0..<columns {
                design[row * (columns + 1) + column + 1] = tensor.values[row * columns + column]
            }
        }
        return design
    }

    private func transposedMatrix(_ matrix: [Double], rows: Int, columns: Int) -> [Double] {
        var result = [Double](repeating: 0, count: matrix.count)
        matrix.withUnsafeBufferPointer { source in
            result.withUnsafeMutableBufferPointer { destination in
                vDSP_mtransD(
                    source.baseAddress!, 1,
                    destination.baseAddress!, 1,
                    vDSP_Length(columns),
                    vDSP_Length(rows)
                )
            }
        }
        return result
    }

    /// Multiplies row-major `left` (`rows` x `columns`) by row-major `right`
    /// (`columns` x `rightColumns`).
    private func matrixProduct(
        _ left: [Double], rows: Int, columns: Int,
        _ right: [Double], columns rightColumns: Int
    ) -> [Double] {
        var result = [Double](repeating: 0, count: rows * rightColumns)
        left.withUnsafeBufferPointer { leftBuffer in
            right.withUnsafeBufferPointer { rightBuffer in
                result.withUnsafeMutableBufferPointer { resultBuffer in
                    vDSP_mmulD(
                        leftBuffer.baseAddress!, 1,
                        rightBuffer.baseAddress!, 1,
                        resultBuffer.baseAddress!, 1,
                        vDSP_Length(rows),
                        vDSP_Length(rightColumns),
                        vDSP_Length(columns)
                    )
                }
            }
        }
        return result
    }

    /// Computes `1 / (1 + exp(-x))` elementwise. The direct form is IEEE-safe:
    /// `exp` saturation yields exactly `0` and `1` at the extremes.
    private func sigmoidValues(_ values: [Double]) -> [Double] {
        let count = values.count
        var negated = [Double](repeating: 0, count: count)
        values.withUnsafeBufferPointer { buffer in
            vDSP_vnegD(buffer.baseAddress!, 1, &negated, 1, vDSP_Length(count))
        }
        var exponentials = [Double](repeating: 0, count: count)
        var elementCount = Int32(count)
        vvexp(&exponentials, negated, &elementCount)
        var one = 1.0
        var denominators = [Double](repeating: 0, count: count)
        vDSP_vsaddD(exponentials, 1, &one, &denominators, 1, vDSP_Length(count))
        var result = [Double](repeating: 0, count: count)
        vDSP_svdivD(&one, denominators, 1, &result, 1, vDSP_Length(count))
        return result
    }
    #endif
}
