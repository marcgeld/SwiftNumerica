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
let normalDensity = normal.pdf(0)
let normalCDF = normal.cdf(1.96)
let normalInverse = normal.inverseCDF(0.975)
let uniformDensity = uniform.pdf(0)
let uniformCDF = uniform.cdf(0)
let uniformInverse = uniform.inverseCDF(0.75)
let exponentialDensity = exponential.pdf(0.5)
let exponentialCDF = exponential.cdf(0.5)
let exponentialInverse = exponential.inverseCDF(0.5)
let betaDensity = beta.pdf(0.5)
let betaCDF = beta.cdf(0.5)
let betaInverse = beta.inverseCDF(0.5)
let gammaDensity = gamma.pdf(2)
let gammaCDF = gamma.cdf(2)
let gammaInverse = gamma.inverseCDF(0.5)
let probabilityAlias = normal.probability(at: 0)
let deterministicSample = normal.sample(using: &generator)
let noArgumentSampleIsFinite = exponential.sample().isFinite
let sampleHelperCount = uniform.sample(count: 3).count
let deterministicSampleHelperCount = gamma.sample(count: 3, using: &generator).count

print("Normal pdf/cdf/inverse/mean/variance (expected approximately 0.398942, 0.975002, 1.959963, 0, 1): \(normalDensity) \(normalCDF) \(normalInverse ?? .nan) \(normal.mean) \(normal.variance)")
print("Uniform pdf/cdf/inverse/mean/variance (expected 0.5, 0.5, 0.5, 0, 1/3): \(uniformDensity) \(uniformCDF) \(uniformInverse ?? .nan) \(uniform.mean) \(uniform.variance)")
print("Exponential pdf/cdf/inverse/mean/variance (expected approximately 0.735759, 0.632121, 0.346574, 0.5, 0.25): \(exponentialDensity) \(exponentialCDF) \(exponentialInverse ?? .nan) \(exponential.mean) \(exponential.variance)")
print("Beta pdf/cdf/inverse/mean/variance (expected 1.5, 0.5, 0.5, 0.5, 0.05): \(betaDensity) \(betaCDF) \(betaInverse ?? .nan) \(beta.mean) \(beta.variance)")
print("Gamma pdf/cdf/inverse/mean/variance (expected approximately 0.183940, 0.264241, 3.356694, 4, 8): \(gammaDensity) \(gammaCDF) \(gammaInverse ?? .nan) \(gamma.mean) \(gamma.variance)")
print("Probability alias for normal at 0 (expected same as pdf = 0.398942): \(probabilityAlias)")
print("Deterministic normal sample (expected fixed-generator value approximately 0.108705): \(deterministicSample)")
print("No-argument exponential sample is finite (expected true): \(noArgumentSampleIsFinite)")
print("Uniform sample helper count (expected 3): \(sampleHelperCount)")
print("Deterministic gamma sample helper count (expected 3): \(deterministicSampleHelperCount)")
