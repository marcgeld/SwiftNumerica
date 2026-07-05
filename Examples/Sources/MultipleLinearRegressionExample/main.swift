import SwiftNumerica

// Linear regression:
// https://en.wikipedia.org/wiki/Linear_regression
//
// This example fits a multiple linear regression model from a feature matrix.

let features = Tensor.matrix([[1, 0], [0, 1], [1, 1], [2, 1]])!
let target = Tensor.vector([6, 6, 9, 12])
let result = Numerica.Statistics.multipleLinearRegression(features: features, target: target)!

print("Feature matrix:", features.values)
print("Target:", target.values)
print("Coefficients:", result.coefficients)
print("Intercept:", result.intercept)
print("R squared:", result.rSquared)
print("Prediction:", result.predict(Tensor.vector([2, 2])) ?? .nan)
