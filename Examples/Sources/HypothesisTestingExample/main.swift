import SwiftNumerica

// Hypothesis testing:
// https://en.wikipedia.org/wiki/Statistical_hypothesis_testing
//
// This example runs the currently available hypothesis tests and prints each
// test statistic, p-value, and selected metadata.

let sampleA = Tensor.vector([8, 9, 10, 11, 12])
let sampleB = Tensor.vector([1, 2, 3, 4, 5])
let pairedA = Tensor.vector([5, 7, 8, 10, 11])
let pairedB = Tensor.vector([1, 2, 3, 4, 5])

let welch = HypothesisTesting.welchTTest(sampleA, sampleB, alternative: .greater)
let paired = HypothesisTesting.pairedTTest(pairedA, pairedB)
let chiSquare = HypothesisTesting.chiSquareGoodnessOfFit(observed: Tensor.vector([20, 5, 5]))
let anova = HypothesisTesting.oneWayANOVA([
    Tensor.vector([1, 2, 1]),
    Tensor.vector([5, 6, 5]),
    Tensor.vector([9, 10, 9]),
])
let mannWhitney = HypothesisTesting.mannWhitneyU(sampleA, sampleB, alternative: .greater)
let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
let ks = HypothesisTesting.kolmogorovSmirnovTest(Tensor.vector([-1, 0, 1]), distribution: normal)

for result in [welch, paired, chiSquare, anova, mannWhitney, ks].compactMap({ $0 }) {
    print(result.method)
    print("  statistic:", result.statistic)
    print("  p-value:", result.pValue)
    print("  df:", result.degreesOfFreedom ?? .nan)
    print("  effect size:", result.effectSize ?? .nan)
}

