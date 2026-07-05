import SwiftNumerica

// Probability mass function:
// https://en.wikipedia.org/wiki/Probability_mass_function
//
// This example evaluates discrete distributions with pmf, cdf, inverseCDF,
// analytical moments, probability aliases, and sample helpers.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 0x9876_5432_10fe_dcba

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

var generator = FixedGenerator()
let binomial = Numerica.Probability.BinomialDistribution(trials: 10, probabilityOfSuccess: 0.5)!
let poisson = Numerica.Probability.PoissonDistribution(lambda: 3)!
let hypergeometric = Numerica.Probability.HypergeometricDistribution(populationSize: 52, successStates: 4, draws: 5)!
let binomialPMF = binomial.pmf(5)
let binomialCDF = binomial.cdf(5)
let binomialInverse = binomial.inverseCDF(0.5)
let poissonPMF = poisson.pmf(3)
let poissonCDF = poisson.cdf(3)
let poissonInverse = poisson.inverseCDF(0.5)
let hypergeometricPMF = hypergeometric.pmf(1)
let hypergeometricCDF = hypergeometric.cdf(1)
let hypergeometricInverse = hypergeometric.inverseCDF(0.5)
let probabilityAlias = binomial.probability(at: 5)
let deterministicSample = poisson.sample(using: &generator)
let noArgumentSampleIsInSupport = (0...10).contains(binomial.sample())
let sampleHelperCount = hypergeometric.sample(count: 3).count
let deterministicSampleHelperCount = poisson.sample(count: 3, using: &generator).count

print("Binomial pmf/cdf/inverse/mean/variance (expected 0.24609375, 0.623046875, 5, 5, 2.5): \(binomialPMF) \(binomialCDF) \(binomialInverse ?? -1) \(binomial.mean) \(binomial.variance)")
print("Poisson pmf/cdf/inverse/mean/variance (expected approximately 0.224042, 0.647232, 3, 3, 3): \(poissonPMF) \(poissonCDF) \(poissonInverse ?? -1) \(poisson.mean) \(poisson.variance)")
print("Hypergeometric pmf/cdf/inverse/mean/variance (expected approximately 0.299474, 0.958316, 0, 0.384615, 0.327184): \(hypergeometricPMF) \(hypergeometricCDF) \(hypergeometricInverse ?? -1) \(hypergeometric.mean) \(hypergeometric.variance)")
print("Probability alias for binomial at 5 (expected same as pmf = 0.24609375): \(probabilityAlias)")
print("Deterministic poisson sample (expected fixed-generator value = 4): \(deterministicSample)")
print("No-argument binomial sample is in support (expected true): \(noArgumentSampleIsInSupport)")
print("Hypergeometric sample helper count (expected 3): \(sampleHelperCount)")
print("Deterministic poisson sample helper count (expected 3): \(deterministicSampleHelperCount)")
