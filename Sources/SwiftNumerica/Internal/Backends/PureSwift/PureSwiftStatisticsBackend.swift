import Foundation

internal struct PureSwiftStatisticsBackend: StatisticsBackend {
    internal func sum(_ tensor: Tensor<Double>) -> Double? {
        guard InputValidation.isNonEmpty(tensor) else { return nil }
        return tensor.values.reduce(0, +)
    }

    internal func min(_ tensor: Tensor<Double>) -> Double? {
        tensor.values.min()
    }

    internal func max(_ tensor: Tensor<Double>) -> Double? {
        tensor.values.max()
    }

    internal func mean(_ tensor: Tensor<Double>) -> Double? {
        guard InputValidation.isNonEmpty(tensor) else { return nil }
        return tensor.values.reduce(0, +) / Double(tensor.count)
    }

    internal func median(_ tensor: Tensor<Double>) -> Double? {
        let sorted = tensor.values.sorted()
        guard !sorted.isEmpty else { return nil }
        let middle = sorted.count / 2
        if sorted.count.isMultiple(of: 2) {
            return (sorted[middle - 1] + sorted[middle]) / 2
        }
        return sorted[middle]
    }

    internal func mode(_ tensor: Tensor<Double>) -> [Double] {
        guard !tensor.values.isEmpty else { return [] }
        let counts = Dictionary(grouping: tensor.values, by: { $0 }).mapValues(\.count)
        guard let maximumCount = counts.values.max(), maximumCount > 1 else { return [] }
        return counts.filter { $0.value == maximumCount }.map(\.key).sorted()
    }

    internal func range(_ tensor: Tensor<Double>) -> Double? {
        guard let minimum = tensor.values.min(), let maximum = tensor.values.max() else { return nil }
        return maximum - minimum
    }

    internal func populationVariance(_ tensor: Tensor<Double>) -> Double? {
        guard let mean = mean(tensor) else { return nil }
        return tensor.values.map { differenceSquared($0, mean: mean) }.reduce(0, +) / Double(tensor.count)
    }

    internal func sampleVariance(_ tensor: Tensor<Double>) -> Double? {
        guard tensor.count > 1, let mean = mean(tensor) else { return nil }
        return tensor.values.map { differenceSquared($0, mean: mean) }.reduce(0, +) / Double(tensor.count - 1)
    }

    internal func populationStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        populationVariance(tensor).map { $0.squareRoot() }
    }

    internal func sampleStandardDeviation(_ tensor: Tensor<Double>) -> Double? {
        sampleVariance(tensor).map { $0.squareRoot() }
    }

    internal func skewness(_ tensor: Tensor<Double>) -> Double? {
        guard let mean = mean(tensor),
              let standardDeviation = populationStandardDeviation(tensor),
              standardDeviation != 0 else { return nil }
        let thirdMoment = tensor.values.map { value in
            let standardized = (value - mean) / standardDeviation
            return standardized * standardized * standardized
        }.reduce(0, +) / Double(tensor.count)
        return thirdMoment
    }

    internal func kurtosis(_ tensor: Tensor<Double>) -> Double? {
        guard let mean = mean(tensor),
              let standardDeviation = populationStandardDeviation(tensor),
              standardDeviation != 0 else { return nil }
        let fourthMoment = tensor.values.map { value in
            let standardized = (value - mean) / standardDeviation
            return standardized * standardized * standardized * standardized
        }.reduce(0, +) / Double(tensor.count)
        return fourthMoment - 3
    }

    internal func quantile(_ tensor: Tensor<Double>, probability: Double) -> Double? {
        guard (0...1).contains(probability) else { return nil }
        let sorted = tensor.values.sorted()
        guard !sorted.isEmpty else { return nil }
        let position = Double(sorted.count - 1) * probability
        let lowerIndex = Int(position.rounded(.down))
        let upperIndex = Int(position.rounded(.up))
        guard lowerIndex != upperIndex else { return sorted[lowerIndex] }
        let weight = position - Double(lowerIndex)
        return sorted[lowerIndex] * (1 - weight) + sorted[upperIndex] * weight
    }

    internal func percentile(_ tensor: Tensor<Double>, percentile: Double) -> Double? {
        guard (0...100).contains(percentile) else { return nil }
        return quantile(tensor, probability: percentile / 100)
    }

    internal func interquartileRange(_ tensor: Tensor<Double>) -> Double? {
        guard let lower = quantile(tensor, probability: 0.25),
              let upper = quantile(tensor, probability: 0.75) else { return nil }
        return upper - lower
    }

    internal func zScore(value: Double, mean: Double, standardDeviation: Double) -> Double? {
        guard standardDeviation != 0 else { return nil }
        return (value - mean) / standardDeviation
    }

    internal func populationCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        covariance(x, y, denominator: x.count)
    }

    internal func sampleCovariance(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        guard x.count > 1 else { return nil }
        return covariance(x, y, denominator: x.count - 1)
    }

    internal func pearsonCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        guard x.count == y.count, x.count > 1,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        var numerator = 0.0
        var xSumSquares = 0.0
        var ySumSquares = 0.0
        for index in x.values.indices {
            let xDifference = x.values[index] - xMean
            let yDifference = y.values[index] - yMean
            numerator += xDifference * yDifference
            xSumSquares += xDifference * xDifference
            ySumSquares += yDifference * yDifference
        }

        let denominator = (xSumSquares * ySumSquares).squareRoot()
        guard denominator != 0 else { return nil }
        return numerator / denominator
    }

    internal func spearmanCorrelation(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Double? {
        guard x.count == y.count, x.count > 1 else { return nil }
        let xRanks = Tensor.vector(ranks(for: x.values))
        let yRanks = Tensor.vector(ranks(for: y.values))
        return pearsonCorrelation(xRanks, yRanks)
    }

    internal func linearRegression(x: Tensor<Double>, y: Tensor<Double>) -> Numerica.Statistics.LinearRegressionResult? {
        guard x.count == y.count, x.count > 1,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        var numerator = 0.0
        var denominator = 0.0
        for index in x.values.indices {
            let xDifference = x.values[index] - xMean
            numerator += xDifference * (y.values[index] - yMean)
            denominator += xDifference * xDifference
        }

        guard denominator != 0 else { return nil }
        let slope = numerator / denominator
        let intercept = yMean - slope * xMean
        let r = pearsonCorrelation(x, y) ?? 0
        return .init(slope: slope, intercept: intercept, rSquared: r * r)
    }

    internal func multipleLinearRegression(features: Tensor<Double>, target: Tensor<Double>) -> Numerica.Statistics.MultipleLinearRegressionResult? {
        guard let dimensions = matrixDimensions(features),
              target.count == dimensions.rows,
              dimensions.rows > dimensions.columns else { return nil }

        let design = designMatrix(from: features, rows: dimensions.rows, columns: dimensions.columns)
        let transposed = transpose(design)
        let normalMatrix = multiply(transposed, design)
        let normalTarget = multiply(transposed, target.values)
        guard let beta = LinearSystemMath.solve(normalMatrix, normalTarget) else { return nil }

        let predictions = design.map { row in dot(row, beta) }
        let targetMean = target.values.reduce(0, +) / Double(target.count)
        let residualSumSquares = zip(target.values, predictions).map { actual, prediction -> Double in
            let difference = actual - prediction
            return difference * difference
        }.reduce(0.0) { $0 + $1 }
        let totalSumSquares = target.values.map { value -> Double in
            let difference = value - targetMean
            return difference * difference
        }.reduce(0.0) { $0 + $1 }
        let rSquared = totalSumSquares == 0 ? 1 : 1 - residualSumSquares / totalSumSquares

        return .init(
            coefficients: Array(beta.dropFirst()),
            intercept: beta[0],
            rSquared: rSquared
        )
    }

    internal func logisticRegression(
        features: Tensor<Double>,
        target: Tensor<Double>,
        learningRate: Double,
        iterations: Int
    ) -> Numerica.Statistics.LogisticRegressionResult? {
        guard let dimensions = matrixDimensions(features),
              target.count == dimensions.rows,
              learningRate > 0,
              iterations > 0,
              target.values.allSatisfy({ $0 == 0 || $0 == 1 }) else { return nil }

        let design = designMatrix(from: features, rows: dimensions.rows, columns: dimensions.columns)
        var weights = Array(repeating: 0.0, count: dimensions.columns + 1)
        let sampleCount = Double(dimensions.rows)

        for _ in 0..<iterations {
            var gradients = Array(repeating: 0.0, count: weights.count)
            for rowIndex in 0..<dimensions.rows {
                let prediction = sigmoid(dot(design[rowIndex], weights))
                let error = prediction - target.values[rowIndex]
                for weightIndex in weights.indices {
                    gradients[weightIndex] += error * design[rowIndex][weightIndex]
                }
            }
            for weightIndex in weights.indices {
                weights[weightIndex] -= learningRate * gradients[weightIndex] / sampleCount
            }
        }

        return .init(
            coefficients: Array(weights.dropFirst()),
            intercept: weights[0],
            iterations: iterations,
            learningRate: learningRate
        )
    }

    private func differenceSquared(_ value: Double, mean: Double) -> Double {
        let difference = value - mean
        return difference * difference
    }

    private func covariance(_ x: Tensor<Double>, _ y: Tensor<Double>, denominator: Int) -> Double? {
        guard x.count == y.count, x.count > 0,
              let xMean = mean(x),
              let yMean = mean(y) else { return nil }

        var sum = 0.0
        for index in x.values.indices {
            sum += (x.values[index] - xMean) * (y.values[index] - yMean)
        }
        return sum / Double(denominator)
    }

    private func ranks(for values: [Double]) -> [Double] {
        let sorted = values.enumerated().sorted { $0.element < $1.element }
        var ranks = Array(repeating: 0.0, count: values.count)
        var index = 0

        while index < sorted.count {
            var upper = index
            while upper + 1 < sorted.count && sorted[upper + 1].element == sorted[index].element {
                upper += 1
            }
            let averageRank = (Double(index + 1) + Double(upper + 1)) / 2
            for rankIndex in index...upper {
                ranks[sorted[rankIndex].offset] = averageRank
            }
            index = upper + 1
        }

        return ranks
    }

    private func matrixDimensions(_ tensor: Tensor<Double>) -> (rows: Int, columns: Int)? {
        guard tensor.rank == 2, tensor.shape.dimensions.count == 2 else { return nil }
        return (tensor.shape.dimensions[0], tensor.shape.dimensions[1])
    }

    private func designMatrix(from tensor: Tensor<Double>, rows: Int, columns: Int) -> [[Double]] {
        (0..<rows).map { row in
            [1.0] + (0..<columns).map { column in
                tensor.values[row * columns + column]
            }
        }
    }

    private func transpose(_ matrix: [[Double]]) -> [[Double]] {
        guard let firstRow = matrix.first else { return [] }
        return firstRow.indices.map { column in
            matrix.map { $0[column] }
        }
    }

    private func multiply(_ left: [[Double]], _ right: [[Double]]) -> [[Double]] {
        guard let rightColumnCount = right.first?.count else { return [] }
        let rightTransposed = transpose(right)
        return left.map { row in
            (0..<rightColumnCount).map { column in
                dot(row, rightTransposed[column])
            }
        }
    }

    private func multiply(_ matrix: [[Double]], _ vector: [Double]) -> [Double] {
        matrix.map { row in dot(row, vector) }
    }

    private func dot(_ left: [Double], _ right: [Double]) -> Double {
        zip(left, right).map(*).reduce(0, +)
    }

    private func sigmoid(_ value: Double) -> Double {
        if value >= 0 {
            let z = Foundation.exp(-value)
            return 1 / (1 + z)
        }
        let z = Foundation.exp(value)
        return z / (1 + z)
    }

}
