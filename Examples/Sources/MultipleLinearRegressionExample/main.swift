import SwiftNumerica

// Linear regression:
// https://en.wikipedia.org/wiki/Linear_regression
//
// This example fits a multiple linear regression model from a feature matrix.

let features = Tensor.matrix([[1, 0], [0, 1], [1, 1], [2, 1]])!
let target = Tensor.vector([6, 6, 9, 12])
let result = Numerica.Statistics.multipleLinearRegression(features: features, target: target)!
let prediction = result.predict(Tensor.vector([2, 2]))

print("Feature matrix:", features.values)
print("Target:", target.values)
print("Coefficients (expected [3, 3] for y = 3 + 3x1 + 3x2): \(result.coefficients)")
print("Intercept (expected 3): \(result.intercept)")
print("R squared (expected perfect fit = 1): \(result.rSquared)")
print("Prediction for [2, 2] (expected 3 + 3 x 2 + 3 x 2 = 15): \(prediction ?? .nan)")
