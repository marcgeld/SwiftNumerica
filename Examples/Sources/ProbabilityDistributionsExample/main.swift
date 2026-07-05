import SwiftNumerica

// Probability distributions:
// https://en.wikipedia.org/wiki/Probability_distribution
//
// This example evaluates continuous and discrete distributions using pdf/pmf,
// cdf, inverseCDF, analytical moments, probability aliases, and deterministic
// RNG-backed samples.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 0x1234_5678_9abc_def0

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

var generator = FixedGenerator()
let values = Tensor.vector([0, 1, 2])
let probabilities = Tensor.vector([0.2, 0.5, 0.3])
let expectedValue = Numerica.Probability.ExpectedValue.discrete(values: values, probabilities: probabilities)
print("Expected value (expected 0 x 0.2 + 1 x 0.5 + 2 x 0.3 = 1.1): \(expectedValue ?? .nan)")

let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
let normalOutput = (
    pdf: normal.pdf(0),
    cdf: normal.cdf(1.96),
    inverse: normal.inverseCDF(0.975),
    probability: normal.probability(at: 0),
    sample: normal.sample(using: &generator)
)
print("Normal pdf/cdf/inverse/mean/variance/probability/sample (expected approximately 0.398942, 0.975002, 1.959963, 0, 1, 0.398942, fixed sample): \(normalOutput.pdf) \(normalOutput.cdf) \(normalOutput.inverse ?? .nan) \(normal.mean) \(normal.variance) \(normalOutput.probability) \(normalOutput.sample)")

let uniform = Numerica.Probability.UniformDistribution(lowerBound: -1, upperBound: 1)!
let uniformOutput = (
    pdf: uniform.pdf(0),
    cdf: uniform.cdf(0),
    inverse: uniform.inverseCDF(0.75),
    probability: uniform.probability(at: 0),
    sample: uniform.sample(using: &generator)
)
print("Uniform pdf/cdf/inverse/mean/variance/probability/sample (expected 0.5, 0.5, 0.5, 0, 1/3, 0.5, fixed sample): \(uniformOutput.pdf) \(uniformOutput.cdf) \(uniformOutput.inverse ?? .nan) \(uniform.mean) \(uniform.variance) \(uniformOutput.probability) \(uniformOutput.sample)")

let exponential = Numerica.Probability.ExponentialDistribution(rate: 2)!
let exponentialOutput = (
    pdf: exponential.pdf(0.5),
    cdf: exponential.cdf(0.5),
    inverse: exponential.inverseCDF(0.5),
    probability: exponential.probability(at: 0.5),
    sample: exponential.sample(using: &generator)
)
print("Exponential pdf/cdf/inverse/mean/variance/probability/sample (expected approximately 0.735759, 0.632121, 0.346574, 0.5, 0.25, 0.735759, fixed sample): \(exponentialOutput.pdf) \(exponentialOutput.cdf) \(exponentialOutput.inverse ?? .nan) \(exponential.mean) \(exponential.variance) \(exponentialOutput.probability) \(exponentialOutput.sample)")

let beta = Numerica.Probability.BetaDistribution(alpha: 2, beta: 2)!
let betaOutput = (
    pdf: beta.pdf(0.5),
    cdf: beta.cdf(0.5),
    inverse: beta.inverseCDF(0.5),
    probability: beta.probability(at: 0.5),
    sample: beta.sample(using: &generator)
)
print("Beta pdf/cdf/inverse/mean/variance/probability/sample (expected 1.5, 0.5, 0.5, 0.5, 0.05, 1.5, fixed sample): \(betaOutput.pdf) \(betaOutput.cdf) \(betaOutput.inverse ?? .nan) \(beta.mean) \(beta.variance) \(betaOutput.probability) \(betaOutput.sample)")

let gamma = Numerica.Probability.GammaDistribution(shape: 2, scale: 2)!
let gammaOutput = (
    pdf: gamma.pdf(2),
    cdf: gamma.cdf(2),
    inverse: gamma.inverseCDF(0.5),
    probability: gamma.probability(at: 2),
    sample: gamma.sample(using: &generator)
)
print("Gamma pdf/cdf/inverse/mean/variance/probability/sample (expected approximately 0.183940, 0.264241, 3.356694, 4, 8, 0.183940, fixed sample): \(gammaOutput.pdf) \(gammaOutput.cdf) \(gammaOutput.inverse ?? .nan) \(gamma.mean) \(gamma.variance) \(gammaOutput.probability) \(gammaOutput.sample)")

let binomial = Numerica.Probability.BinomialDistribution(trials: 10, probabilityOfSuccess: 0.5)!
let binomialOutput = (
    pmf: binomial.pmf(5),
    cdf: binomial.cdf(5),
    inverse: binomial.inverseCDF(0.5),
    probability: binomial.probability(at: 5),
    sample: binomial.sample(using: &generator)
)
print("Binomial pmf/cdf/inverse/mean/variance/probability/sample (expected 0.24609375, 0.623046875, 5, 5, 2.5, 0.24609375, fixed sample): \(binomialOutput.pmf) \(binomialOutput.cdf) \(binomialOutput.inverse ?? -1) \(binomial.mean) \(binomial.variance) \(binomialOutput.probability) \(binomialOutput.sample)")

let poisson = Numerica.Probability.PoissonDistribution(lambda: 3)!
let poissonOutput = (
    pmf: poisson.pmf(3),
    cdf: poisson.cdf(3),
    inverse: poisson.inverseCDF(0.5),
    probability: poisson.probability(at: 3),
    sample: poisson.sample(using: &generator)
)
print("Poisson pmf/cdf/inverse/mean/variance/probability/sample (expected approximately 0.224042, 0.647232, 3, 3, 3, 0.224042, fixed sample): \(poissonOutput.pmf) \(poissonOutput.cdf) \(poissonOutput.inverse ?? -1) \(poisson.mean) \(poisson.variance) \(poissonOutput.probability) \(poissonOutput.sample)")

let hypergeometric = Numerica.Probability.HypergeometricDistribution(populationSize: 52, successStates: 4, draws: 5)!
let hypergeometricOutput = (
    pmf: hypergeometric.pmf(1),
    cdf: hypergeometric.cdf(1),
    inverse: hypergeometric.inverseCDF(0.5),
    probability: hypergeometric.probability(at: 1),
    sample: hypergeometric.sample(using: &generator)
)
print("Hypergeometric pmf/cdf/inverse/mean/variance/probability/sample (expected approximately 0.299474, 0.958316, 0, 0.384615, 0.327184, 0.299474, fixed sample): \(hypergeometricOutput.pmf) \(hypergeometricOutput.cdf) \(hypergeometricOutput.inverse ?? -1) \(hypergeometric.mean) \(hypergeometric.variance) \(hypergeometricOutput.probability) \(hypergeometricOutput.sample)")
