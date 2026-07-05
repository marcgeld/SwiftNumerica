import SwiftNumerica

// Continuous probability distribution:
// https://en.wikipedia.org/wiki/Probability_distribution
//
// This example evaluates continuous distributions with pdf, cdf, inverseCDF,
// analytical moments, probability aliases, and sample helpers.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 0x1234_5678_9abc_def0

    mutating func next() -> UInt64 {
        state = 2862933555777941757 &* state &+ 3037000493
        return state
    }
}

var generator = FixedGenerator()
let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
let uniform = Numerica.Probability.UniformDistribution(lowerBound: -1, upperBound: 1)!
let exponential = Numerica.Probability.ExponentialDistribution(rate: 2)!
let beta = Numerica.Probability.BetaDistribution(alpha: 2, beta: 2)!
let gamma = Numerica.Probability.GammaDistribution(shape: 2, scale: 2)!

print("Normal:", normal.pdf(0), normal.cdf(1.96), normal.inverseCDF(0.975) ?? .nan, normal.mean, normal.variance)
print("Uniform:", uniform.pdf(0), uniform.cdf(0), uniform.inverseCDF(0.75) ?? .nan, uniform.mean, uniform.variance)
print("Exponential:", exponential.pdf(0.5), exponential.cdf(0.5), exponential.inverseCDF(0.5) ?? .nan, exponential.mean, exponential.variance)
print("Beta:", beta.pdf(0.5), beta.cdf(0.5), beta.inverseCDF(0.5) ?? .nan, beta.mean, beta.variance)
print("Gamma:", gamma.pdf(2), gamma.cdf(2), gamma.inverseCDF(0.5) ?? .nan, gamma.mean, gamma.variance)
print("Probability alias:", normal.probability(at: 0))
print("Deterministic sample:", normal.sample(using: &generator))
print("No-argument sample is finite:", exponential.sample().isFinite)
print("Sample helper:", uniform.sample(count: 3).count)
print("Deterministic sample helper:", gamma.sample(count: 3, using: &generator).count)
