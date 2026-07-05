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

print("Binomial:", binomial.pmf(5), binomial.cdf(5), binomial.inverseCDF(0.5) ?? -1, binomial.mean, binomial.variance)
print("Poisson:", poisson.pmf(3), poisson.cdf(3), poisson.inverseCDF(0.5) ?? -1, poisson.mean, poisson.variance)
print("Hypergeometric:", hypergeometric.pmf(1), hypergeometric.cdf(1), hypergeometric.inverseCDF(0.5) ?? -1, hypergeometric.mean, hypergeometric.variance)
print("Probability alias:", binomial.probability(at: 5))
print("Deterministic sample:", poisson.sample(using: &generator))
print("No-argument sample is in support:", (0...10).contains(binomial.sample()))
print("Sample helper:", hypergeometric.sample(count: 3).count)
print("Deterministic sample helper:", poisson.sample(count: 3, using: &generator).count)
