import SwiftNumerica

// Simple linear regression:
// https://en.wikipedia.org/wiki/Simple_linear_regression
//
// This example fits a line and uses scalar and vector prediction APIs.

let x = Tensor.vector([1, 2, 3])
let y = Tensor.vector([3, 5, 7])
let result = Numerica.Statistics.linearRegression(x: x, y: y)!
let modelResult = LinearRegression().fit(x, y)!

print("Slope:", result.slope)
print("Intercept:", result.intercept)
print("R squared:", result.rSquared)
print("Scalar prediction:", result.predict(4))
print("Vector prediction:", result.predict(Tensor.vector([4, 5]))?.values ?? [])
print("Model fit prediction:", modelResult.predict(4))
