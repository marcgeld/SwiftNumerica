import SwiftNumerica

// Polynomial regression:
// https://en.wikipedia.org/wiki/Polynomial_regression
//
// This example fits a quadratic curve and evaluates scalar and vector inputs.

let x = Tensor.vector([-1, 0, 1])
let y = Tensor.vector([2, 1, 6])
let result = Numerica.Statistics.polynomialRegression(x: x, y: y, degree: 2)!
let modelResult = PolynomialRegression(degree: 2)!.fit(x, y)!

print("Degree:", result.degree)
print("Coefficients:", result.coefficients)
print("R squared:", result.rSquared)
print("Scalar prediction:", result.predict(2))
print("Vector prediction:", modelResult.predict(Tensor.vector([2, 3]))?.values ?? [])
