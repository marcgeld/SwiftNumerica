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

print("Simple linear slope/intercept/r2:", simple.slope, simple.intercept, simple.rSquared)
print("Simple predict scalar/vector:", simple.predict(4), simple.predict(Tensor.vector([4, 5]))?.values ?? [])
print("Model fit predict:", simpleModel.predict(4))

let features = Tensor.matrix([[1, 0], [0, 1], [1, 1], [2, 1]])!
let target = Tensor.vector([6, 6, 9, 12])
let multiple = Numerica.Statistics.multipleLinearRegression(features: features, target: target)!
print("Multiple coefficients/intercept/r2:", multiple.coefficients, multiple.intercept, multiple.rSquared)
print("Multiple predict:", multiple.predict(Tensor.vector([2, 2])) ?? .nan)

let polynomial = Numerica.Statistics.polynomialRegression(x: Tensor.vector([-1, 0, 1]), y: Tensor.vector([2, 1, 6]), degree: 2)!
let polynomialModel = PolynomialRegression(degree: 2)!.fit(Tensor.vector([-1, 0, 1]), Tensor.vector([2, 1, 6]))!
print("Polynomial degree/coefficients/r2:", polynomial.degree, polynomial.coefficients, polynomial.rSquared)
print("Polynomial predict scalar/vector:", polynomial.predict(2), polynomialModel.predict(Tensor.vector([2, 3]))?.values ?? [])

let logisticFeatures = Tensor.matrix([[0], [1], [2], [3]])!
let logisticTarget = Tensor.vector([0, 0, 1, 1])
let logistic = Numerica.Statistics.logisticRegression(features: logisticFeatures, target: logisticTarget, learningRate: 0.5, iterations: 2_000)!
let logisticModel = LogisticRegression(learningRate: 0.5, iterations: 2_000)!.fit(features: logisticFeatures, target: logisticTarget)!
print("Logistic coefficients/intercept:", logistic.coefficients, logistic.intercept)
print("Logistic probability/class:", logistic.predictProbability(Tensor.vector([3])) ?? .nan, logisticModel.predict(Tensor.vector([3])) ?? -1)

