import SwiftNumerica

// Distribution fitting:
// https://en.wikipedia.org/wiki/Maximum_likelihood_estimation
//
// This example estimates distribution parameters from sample tensors and then
// uses a Kolmogorov-Smirnov test to compare a sample with a fitted model.

let normalSample = Tensor.vector([8, 9, 10, 11, 12])
let uniformSample = Tensor.vector([-2, 0, 1, 3])
let exponentialSample = Tensor.vector([0.25, 0.5, 1.0, 1.25])

let normal = Numerica.Statistics.DistributionAnalysis.fitNormal(normalSample)
let uniform = Numerica.Statistics.DistributionAnalysis.fitUniform(uniformSample)
let exponential = Numerica.Statistics.DistributionAnalysis.fitExponential(exponentialSample)

print("Fitted normal mean/std (expected mean 10, sample std sqrt(2) = 1.4142135623730951): \(normal?.mean ?? .nan) \(normal?.standardDeviation ?? .nan)")
print("Fitted uniform bounds (expected min -2, max 3): \(uniform?.lowerBound ?? .nan) \(uniform?.upperBound ?? .nan)")
print("Fitted exponential rate (expected 1 / sample mean 0.75 = 1.3333333333333333): \(exponential?.rate ?? .nan)")

if let normal {
    let result = HypothesisTesting.kolmogorovSmirnovTest(normalSample, distribution: normal)
    let statistic = result?.statistic
    let pValue = result?.pValue
    print("Kolmogorov-Smirnov statistic (expected approximately 0.16025000815237345): \(statistic ?? .nan)")
    print("Kolmogorov-Smirnov p-value (expected approximately 0.9983903404822662): \(pValue ?? .nan)")
}
