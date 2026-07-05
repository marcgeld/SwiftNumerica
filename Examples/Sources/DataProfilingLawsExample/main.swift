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
print("Benford observed frequencies:", benford?.observedFrequencies ?? [:])
print("Benford expected frequencies:", benford?.expectedFrequencies ?? [:])
print("Benford MAD:", benford?.meanAbsoluteDeviation ?? .nan)
print("Zipf entries:", zipf?.entries ?? [])
print("Pareto top 20 percent share:", pareto?.topTwentyPercentShare ?? .nan)
print("Pareto-like:", pareto?.isApproximatelyPareto ?? false)
