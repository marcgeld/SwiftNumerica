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
}
