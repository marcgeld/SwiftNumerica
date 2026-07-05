import SwiftNumerica

// Polynomial regression:
// https://en.wikipedia.org/wiki/Polynomial_regression
//
// This example fits a quadratic curve and evaluates scalar and vector inputs.

let x = Tensor.vector([-1, 0, 1])
let y = Tensor.vector([2, 1, 6])
let result = Numerica.Statistics.polynomialRegression(x: x, y: y, degree: 2)!
let modelResult = PolynomialRegression(degree: 2)!.fit(x, y)!
let scalarPrediction = result.predict(2)
let vectorPrediction = modelResult.predict(Tensor.vector([2, 3]))

print("Degree (expected quadratic degree = 2): \(result.degree)")
print("Coefficients (expected approximately [1, 2, 3] for 1 + 2x + 3x^2): \(result.coefficients)")
print("R squared (expected perfect fit = 1): \(result.rSquared)")
print("Scalar prediction for x = 2 (expected 1 + 2 x 2 + 3 x 2^2 = 17): \(scalarPrediction)")
print("Vector prediction for x = [2, 3] (expected [17, 34]): \(vectorPrediction?.values ?? [])")
