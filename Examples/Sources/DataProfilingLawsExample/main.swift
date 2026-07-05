import SwiftNumerica

// Benford's law:
// https://en.wikipedia.org/wiki/Benford%27s_law
//
// This example runs the Benford, Zipf, and Pareto profiling helpers.

let values = Tensor.vector([1, 2, 3, 4, 5, 10, 100, 1_000])
let benford = Numerica.DataProfiling.benfordAnalysis(values)
let zipf = Numerica.DataProfiling.zipfAnalysis(values)
let pareto = Numerica.DataProfiling.paretoAnalysis(values)

print("Values:", values.values)
print("Benford observed frequencies (expected digit 1 frequency 0.5; dictionary order may vary): \(benford?.observedFrequencies ?? [:])")
print("Benford expected frequencies (expected log10(1 + 1 / digit); dictionary order may vary): \(benford?.expectedFrequencies ?? [:])")
print("Benford MAD (expected approximately 0.0606533352604528): \(benford?.meanAbsoluteDeviation ?? .nan)")
print("Zipf entries (expected 8 ranked entries): \(zipf?.entries ?? [])")
print("Pareto top 20 percent share (expected approximately 0.9777777777777777): \(pareto?.topTwentyPercentShare ?? .nan)")
print("Pareto-like (expected true): \(pareto?.isApproximatelyPareto ?? false)")
