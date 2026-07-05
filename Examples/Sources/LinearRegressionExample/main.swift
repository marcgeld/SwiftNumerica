import SwiftNumerica

// Simple linear regression:
// https://en.wikipedia.org/wiki/Simple_linear_regression
//
// This example fits a line and uses scalar and vector prediction APIs.

let x = Tensor.vector([1, 2, 3])
let y = Tensor.vector([3, 5, 7])
let result = Numerica.Statistics.linearRegression(x: x, y: y)!
let modelResult = LinearRegression().fit(x, y)!
let scalarPrediction = result.predict(4)
let vectorPrediction = result.predict(Tensor.vector([4, 5]))
let modelPrediction = modelResult.predict(4)

print("Slope (expected line y = 2x + 1, slope = 2): \(result.slope)")
print("Intercept (expected line y = 2x + 1, intercept = 1): \(result.intercept)")
print("R squared (expected perfect fit = 1): \(result.rSquared)")
print("Scalar prediction for x = 4 (expected 2 x 4 + 1 = 9): \(scalarPrediction)")
print("Vector prediction for x = [4, 5] (expected [9, 11]): \(vectorPrediction?.values ?? [])")
print("Model fit prediction for x = 4 (expected 9): \(modelPrediction)")
