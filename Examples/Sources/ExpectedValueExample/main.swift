import SwiftNumerica

// Expected value:
// https://en.wikipedia.org/wiki/Expected_value
//
// This example computes the expected value of a discrete outcome distribution.

let values = Tensor.vector([0, 10, 20])
let probabilities = Tensor.vector([0.2, 0.5, 0.3])
let expectedValue = Numerica.Probability.ExpectedValue.discrete(values: values, probabilities: probabilities)

print("Values:", values.values)
print("Probabilities:", probabilities.values)
print("Expected value:", expectedValue ?? .nan)
