import SwiftNumerica

// Logistic regression:
// https://en.wikipedia.org/wiki/Logistic_regression
//
// This example fits a binary classifier and prints probability and class output.

let features = Tensor.matrix([[0], [1], [2], [3]])!
let target = Tensor.vector([0, 0, 1, 1])
let result = Numerica.Statistics.logisticRegression(features: features, target: target, learningRate: 0.5, iterations: 2_000)!
let modelResult = LogisticRegression(learningRate: 0.5, iterations: 2_000)!.fit(features: features, target: target)!
let probability = result.predictProbability(Tensor.vector([3]))
let predictedClass = modelResult.predict(Tensor.vector([3]))

print("Coefficients (expected positive coefficient for larger feature values): \(result.coefficients)")
print("Intercept (expected negative intercept for this separated sample): \(result.intercept)")
print("Iterations (expected configured iterations = 2000): \(result.iterations)")
print("Learning rate (expected configured learning rate = 0.5): \(result.learningRate)")
print("Probability for feature [3] (expected approximately 0.999987151069753): \(probability ?? .nan)")
print("Class for feature [3] (expected probability >= 0.5 -> class 1): \(predictedClass ?? -1)")
