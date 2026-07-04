import Foundation

public extension Numerica.Statistics {
    /// The result of a simple linear regression.
    struct LinearRegressionResult: Equatable, Sendable {
        /// The fitted slope.
        public let slope: Double

        /// The fitted intercept.
        public let intercept: Double

        /// The coefficient of determination.
        public let rSquared: Double

        /// Creates a linear regression result.
        public init(slope: Double, intercept: Double, rSquared: Double) {
            self.slope = slope
            self.intercept = intercept
            self.rSquared = rSquared
        }

        /// Predicts a response for a scalar predictor.
        public func predict(_ x: Double) -> Double {
            intercept + slope * x
        }

        /// Predicts responses for a vector tensor of predictors.
        public func predict(_ x: Tensor<Double>) -> Tensor<Double>? {
            guard x.rank == 1 else { return nil }
            return .vector(x.values.map(predict))
        }
    }

    /// Fits a simple linear regression model.
    ///
    /// - Parameters:
    ///   - x: The predictor tensor.
    ///   - y: The response tensor.
    /// - Returns: A linear regression result, or `nil` when the model is undefined.
    static func linearRegression(x: Tensor<Double>, y: Tensor<Double>) -> LinearRegressionResult? {
        try? BackendResolver.statisticsBackend().linearRegression(x: x, y: y)
    }

    /// The result of a multiple linear regression.
    struct MultipleLinearRegressionResult: Equatable, Sendable {
        /// The fitted coefficients, one per feature column.
        public let coefficients: [Double]

        /// The fitted intercept.
        public let intercept: Double

        /// The coefficient of determination.
        public let rSquared: Double

        /// Creates a multiple linear regression result.
        public init(coefficients: [Double], intercept: Double, rSquared: Double) {
            self.coefficients = coefficients
            self.intercept = intercept
            self.rSquared = rSquared
        }

        /// Predicts a response for a feature vector.
        public func predict(_ features: Tensor<Double>) -> Double? {
            guard features.rank == 1, features.count == coefficients.count else { return nil }
            return intercept + zip(coefficients, features.values).map(*).reduce(0, +)
        }
    }

    /// Fits a multiple linear regression model using a rank-2 feature tensor.
    ///
    /// Each row is an observation and each column is a feature.
    static func multipleLinearRegression(
        features: Tensor<Double>,
        target: Tensor<Double>
    ) -> MultipleLinearRegressionResult? {
        try? BackendResolver.statisticsBackend().multipleLinearRegression(features: features, target: target)
    }

    /// The result of a binary logistic regression.
    struct LogisticRegressionResult: Equatable, Sendable {
        /// The fitted coefficients, one per feature column.
        public let coefficients: [Double]

        /// The fitted intercept.
        public let intercept: Double

        /// The number of training iterations.
        public let iterations: Int

        /// The gradient descent learning rate.
        public let learningRate: Double

        /// Creates a logistic regression result.
        public init(coefficients: [Double], intercept: Double, iterations: Int, learningRate: Double) {
            self.coefficients = coefficients
            self.intercept = intercept
            self.iterations = iterations
            self.learningRate = learningRate
        }

        /// Predicts the positive-class probability for a feature vector.
        public func predictProbability(_ features: Tensor<Double>) -> Double? {
            guard features.rank == 1, features.count == coefficients.count else { return nil }
            let linearScore = intercept + zip(coefficients, features.values).map(*).reduce(0, +)
            if linearScore >= 0 {
                let z = Foundation.exp(-linearScore)
                return 1 / (1 + z)
            }
            let z = Foundation.exp(linearScore)
            return z / (1 + z)
        }

        /// Predicts a binary class label for a feature vector.
        public func predict(_ features: Tensor<Double>, threshold: Double = 0.5) -> Int? {
            guard let probability = predictProbability(features) else { return nil }
            return probability >= threshold ? 1 : 0
        }
    }

    /// Fits a binary logistic regression model using batch gradient descent.
    ///
    /// Targets must be encoded as `0` and `1`.
    static func logisticRegression(
        features: Tensor<Double>,
        target: Tensor<Double>,
        learningRate: Double = 0.1,
        iterations: Int = 1_000
    ) -> LogisticRegressionResult? {
        try? BackendResolver.statisticsBackend().logisticRegression(
            features: features,
            target: target,
            learningRate: learningRate,
            iterations: iterations
        )
    }

    /// The result of a polynomial regression.
    struct PolynomialRegressionResult: Equatable, Sendable {
        /// Coefficients in ascending power order.
        ///
        /// `coefficients[0]` is the intercept, `coefficients[1]` is the linear
        /// coefficient, and so on.
        public let coefficients: [Double]

        /// The polynomial degree.
        public let degree: Int

        /// The coefficient of determination.
        public let rSquared: Double

        /// Creates a polynomial regression result.
        public init(coefficients: [Double], degree: Int, rSquared: Double) {
            self.coefficients = coefficients
            self.degree = degree
            self.rSquared = rSquared
        }

        /// Predicts a response for a scalar predictor.
        public func predict(_ x: Double) -> Double {
            var result = 0.0
            var power = 1.0
            for coefficient in coefficients {
                result += coefficient * power
                power *= x
            }
            return result
        }

        /// Predicts responses for a vector tensor of predictors.
        public func predict(_ x: Tensor<Double>) -> Tensor<Double>? {
            guard x.rank == 1 else { return nil }
            return .vector(x.values.map(predict))
        }
    }

    /// Fits a polynomial regression model using a one-dimensional predictor.
    static func polynomialRegression(
        x: Tensor<Double>,
        y: Tensor<Double>,
        degree: Int
    ) -> PolynomialRegressionResult? {
        PolynomialRegression(degree: degree)?.fit(x, y)
    }
}

/// A model-oriented simple linear regression estimator.
public struct LinearRegression: Equatable, Sendable {
    /// Creates a linear regression estimator.
    public init() {}

    /// Fits a simple linear regression model.
    public func fit(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Numerica.Statistics.LinearRegressionResult? {
        Numerica.Statistics.linearRegression(x: x, y: y)
    }
}

/// A model-oriented polynomial regression estimator.
public struct PolynomialRegression: Equatable, Sendable {
    /// The polynomial degree.
    public let degree: Int

    /// Creates a polynomial regression estimator.
    ///
    /// - Parameter degree: The polynomial degree. Must be non-negative.
    public init?(degree: Int) {
        guard degree >= 0 else { return nil }
        self.degree = degree
    }

    /// Fits a polynomial regression model.
    public func fit(_ x: Tensor<Double>, _ y: Tensor<Double>) -> Numerica.Statistics.PolynomialRegressionResult? {
        guard x.rank == 1,
              y.rank == 1,
              x.count == y.count,
              x.count > degree,
              x.values.allSatisfy(\.isFinite),
              y.values.allSatisfy(\.isFinite) else { return nil }

        if degree == 0 {
            guard let mean = Numerica.Statistics.mean(y) else { return nil }
            let totalSumSquares = y.values.map { value in
                let difference = value - mean
                return difference * difference
            }.reduce(0.0) { $0 + $1 }
            return .init(coefficients: [mean], degree: degree, rSquared: totalSumSquares == 0 ? 1 : 0)
        }

        let rows = x.values.map { value in
            (1...degree).map { power in Foundation.pow(value, Double(power)) }
        }
        guard let features = Tensor.matrix(rows),
              let result = Numerica.Statistics.multipleLinearRegression(features: features, target: y) else {
            return nil
        }

        return .init(
            coefficients: [result.intercept] + result.coefficients,
            degree: degree,
            rSquared: result.rSquared
        )
    }
}

/// A model-oriented binary logistic regression estimator.
public struct LogisticRegression: Equatable, Sendable {
    /// The gradient descent learning rate.
    public let learningRate: Double

    /// The number of training iterations.
    public let iterations: Int

    /// Creates a logistic regression estimator.
    public init?(learningRate: Double = 0.1, iterations: Int = 1_000) {
        guard learningRate > 0, iterations > 0 else { return nil }
        self.learningRate = learningRate
        self.iterations = iterations
    }

    /// Fits a binary logistic regression model.
    public func fit(
        features: Tensor<Double>,
        target: Tensor<Double>
    ) -> Numerica.Statistics.LogisticRegressionResult? {
        Numerica.Statistics.logisticRegression(
            features: features,
            target: target,
            learningRate: learningRate,
            iterations: iterations
        )
    }
}
