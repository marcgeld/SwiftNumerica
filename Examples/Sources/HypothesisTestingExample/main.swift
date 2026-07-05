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

func printResult(
    _ result: HypothesisTestResult?,
    expectedStatistic: String,
    expectedPValue: String,
    expectedDegreesOfFreedom: String,
    expectedEffectSize: String
) {
    guard let result else { return }
    print(result.method)
    print("  statistic (expected \(expectedStatistic)): \(result.statistic)")
    print("  p-value (expected \(expectedPValue)): \(result.pValue)")
    print("  df (expected \(expectedDegreesOfFreedom)): \(result.degreesOfFreedom ?? .nan)")
    print("  effect size (expected \(expectedEffectSize)): \(result.effectSize ?? .nan)")
}

printResult(
    welch,
    expectedStatistic: "7",
    expectedPValue: "approximately 5.631927456339891e-05",
    expectedDegreesOfFreedom: "8",
    expectedEffectSize: "approximately 4.427188724235731"
)
printResult(
    paired,
    expectedStatistic: "approximately 13.89758457944607",
    expectedPValue: "approximately 0.00015543552359864599",
    expectedDegreesOfFreedom: "4",
    expectedEffectSize: "approximately 6.215188768538847"
)
printResult(
    chiSquare,
    expectedStatistic: "15",
    expectedPValue: "approximately 0.0005530843701477828",
    expectedDegreesOfFreedom: "2",
    expectedEffectSize: "approximately 0.7071067811865476"
)
printResult(
    anova,
    expectedStatistic: "approximately 144",
    expectedPValue: "approximately 8.499859752264527e-06",
    expectedDegreesOfFreedom: "2",
    expectedEffectSize: "approximately 0.9795918367346939"
)
printResult(
    mannWhitney,
    expectedStatistic: "25",
    expectedPValue: "approximately 0.006092906343520776",
    expectedDegreesOfFreedom: "nil",
    expectedEffectSize: "1"
)
printResult(
    ks,
    expectedStatistic: "approximately 0.17467806950096965",
    expectedPValue: "approximately 0.999877236412919",
    expectedDegreesOfFreedom: "nil",
    expectedEffectSize: "nil"
)
