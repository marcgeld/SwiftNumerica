import SwiftNumerica

// Logistic regression:
// https://en.wikipedia.org/wiki/Logistic_regression
//
// This example fits a binary classifier and prints probability and class output.

let features = Tensor.matrix([[0], [1], [2], [3]])!
let target = Tensor.vector([0, 0, 1, 1])
let result = Numerica.Statistics.logisticRegression(features: features, target: target, learningRate: 0.5, iterations: 2_000)!
let modelResult = LogisticRegression(learningRate: 0.5, iterations: 2_000)!.fit(features: features, target: target)!

print("Coefficients:", result.coefficients)
print("Intercept:", result.intercept)
print("Iterations:", result.iterations)
print("Learning rate:", result.learningRate)
print("Probability:", result.predictProbability(Tensor.vector([3])) ?? .nan)
print("Class:", modelResult.predict(Tensor.vector([3])) ?? -1)
