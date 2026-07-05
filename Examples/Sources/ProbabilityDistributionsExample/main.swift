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
print("Expected value:", Numerica.Probability.ExpectedValue.discrete(values: values, probabilities: probabilities) ?? .nan)

let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
print("Normal pdf/cdf/inverse/mean/variance/sample:",
      normal.pdf(0),
      normal.cdf(1.96),
      normal.inverseCDF(0.975) ?? .nan,
      normal.mean,
      normal.variance,
      normal.probability(at: 0),
      normal.sample(using: &generator))

let uniform = Numerica.Probability.UniformDistribution(lowerBound: -1, upperBound: 1)!
print("Uniform pdf/cdf/inverse/mean/variance/sample:",
      uniform.pdf(0),
      uniform.cdf(0),
      uniform.inverseCDF(0.75) ?? .nan,
      uniform.mean,
      uniform.variance,
      uniform.probability(at: 0),
      uniform.sample(using: &generator))

let exponential = Numerica.Probability.ExponentialDistribution(rate: 2)!
print("Exponential pdf/cdf/inverse/mean/variance/sample:",
      exponential.pdf(0.5),
      exponential.cdf(0.5),
      exponential.inverseCDF(0.5) ?? .nan,
      exponential.mean,
      exponential.variance,
      exponential.probability(at: 0.5),
      exponential.sample(using: &generator))

let beta = Numerica.Probability.BetaDistribution(alpha: 2, beta: 2)!
print("Beta pdf/cdf/inverse/mean/variance/sample:",
      beta.pdf(0.5),
      beta.cdf(0.5),
      beta.inverseCDF(0.5) ?? .nan,
      beta.mean,
      beta.variance,
      beta.probability(at: 0.5),
      beta.sample(using: &generator))

let gamma = Numerica.Probability.GammaDistribution(shape: 2, scale: 2)!
print("Gamma pdf/cdf/inverse/mean/variance/sample:",
      gamma.pdf(2),
      gamma.cdf(2),
      gamma.inverseCDF(0.5) ?? .nan,
      gamma.mean,
      gamma.variance,
      gamma.probability(at: 2),
      gamma.sample(using: &generator))

let binomial = Numerica.Probability.BinomialDistribution(trials: 10, probabilityOfSuccess: 0.5)!
print("Binomial pmf/cdf/inverse/mean/variance/sample:",
      binomial.pmf(5),
      binomial.cdf(5),
      binomial.inverseCDF(0.5) ?? -1,
      binomial.mean,
      binomial.variance,
      binomial.probability(at: 5),
      binomial.sample(using: &generator))

let poisson = Numerica.Probability.PoissonDistribution(lambda: 3)!
print("Poisson pmf/cdf/inverse/mean/variance/sample:",
      poisson.pmf(3),
      poisson.cdf(3),
      poisson.inverseCDF(0.5) ?? -1,
      poisson.mean,
      poisson.variance,
      poisson.probability(at: 3),
      poisson.sample(using: &generator))

let hypergeometric = Numerica.Probability.HypergeometricDistribution(populationSize: 52, successStates: 4, draws: 5)!
print("Hypergeometric pmf/cdf/inverse/mean/variance/sample:",
      hypergeometric.pmf(1),
      hypergeometric.cdf(1),
      hypergeometric.inverseCDF(0.5) ?? -1,
      hypergeometric.mean,
      hypergeometric.variance,
      hypergeometric.probability(at: 1),
      hypergeometric.sample(using: &generator))

