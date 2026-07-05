import SwiftNumerica

// Regression:
// https://en.wikipedia.org/wiki/Regression_analysis
//
// This example fits simple linear, multiple linear, polynomial, and logistic
// regression models, then uses their prediction APIs.

let x = Tensor.vector([1, 2, 3])
let y = Tensor.vector([3, 5, 7])
let simple = Numerica.Statistics.linearRegression(x: x, y: y)!
let simpleModel = LinearRegression().fit(x, y)!
let simpleScalarPrediction = simple.predict(4)
let simpleVectorPrediction = simple.predict(Tensor.vector([4, 5]))
let simpleModelPrediction = simpleModel.predict(4)

print("Simple linear slope/intercept/r2 (expected 2, 1, 1): \(simple.slope) \(simple.intercept) \(simple.rSquared)")
print("Simple predict scalar/vector (expected 9 and [9, 11]): \(simpleScalarPrediction) \(simpleVectorPrediction?.values ?? [])")
print("Model fit predict (expected 9): \(simpleModelPrediction)")

let features = Tensor.matrix([[1, 0], [0, 1], [1, 1], [2, 1]])!
let target = Tensor.vector([6, 6, 9, 12])
let multiple = Numerica.Statistics.multipleLinearRegression(features: features, target: target)!
let multiplePrediction = multiple.predict(Tensor.vector([2, 2]))
print("Multiple coefficients/intercept/r2 (expected [3, 3], 3, 1): \(multiple.coefficients) \(multiple.intercept) \(multiple.rSquared)")
print("Multiple predict for [2, 2] (expected 15): \(multiplePrediction ?? .nan)")

let polynomial = Numerica.Statistics.polynomialRegression(x: Tensor.vector([-1, 0, 1]), y: Tensor.vector([2, 1, 6]), degree: 2)!
let polynomialModel = PolynomialRegression(degree: 2)!.fit(Tensor.vector([-1, 0, 1]), Tensor.vector([2, 1, 6]))!
let polynomialScalarPrediction = polynomial.predict(2)
let polynomialVectorPrediction = polynomialModel.predict(Tensor.vector([2, 3]))
print("Polynomial degree/coefficients/r2 (expected 2, approximately [1, 2, 3], 1): \(polynomial.degree) \(polynomial.coefficients) \(polynomial.rSquared)")
print("Polynomial predict scalar/vector (expected 17 and [17, 34]): \(polynomialScalarPrediction) \(polynomialVectorPrediction?.values ?? [])")

let logisticFeatures = Tensor.matrix([[0], [1], [2], [3]])!
let logisticTarget = Tensor.vector([0, 0, 1, 1])
let logistic = Numerica.Statistics.logisticRegression(features: logisticFeatures, target: logisticTarget, learningRate: 0.5, iterations: 2_000)!
let logisticModel = LogisticRegression(learningRate: 0.5, iterations: 2_000)!.fit(features: logisticFeatures, target: logisticTarget)!
let logisticProbability = logistic.predictProbability(Tensor.vector([3]))
let logisticClass = logisticModel.predict(Tensor.vector([3]))
print("Logistic coefficients/intercept (expected positive coefficient and negative intercept): \(logistic.coefficients) \(logistic.intercept)")
print("Logistic probability/class for [3] (expected probability near 1 and class 1): \(logisticProbability ?? .nan) \(logisticClass ?? -1)")
