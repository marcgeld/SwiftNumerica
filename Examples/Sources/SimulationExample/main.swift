import SwiftNumerica

// Simulation:
// https://en.wikipedia.org/wiki/Simulation
//
// This example runs Monte Carlo estimation, random walks, distribution-driven
// random walks, and finite-state Markov chains.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 42

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

var generator = FixedGenerator()
let monteCarlo = MonteCarloSimulation(iterations: 5)!
let monteCarloResult = monteCarlo.run(using: &generator) {
    Double.random(in: 0...1, using: &$0)
}
let closureResult = monteCarlo.run { 0.5 }

print("Monte Carlo random estimates (expected fixed-generator sequence with 5 values): \(monteCarloResult?.estimates.values ?? [])")
print("Monte Carlo constant mean (expected five estimates of 0.5 -> mean 0.5): \(closureResult?.mean ?? .nan)")

let walk = RandomWalk(initialValue: 0)!
let walkResult = walk.simulate(steps: 5, using: &generator) { rng in
    Bool.random(using: &rng) ? 1 : -1
}
let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
let distributionWalk = walk.simulate(steps: 5, using: &generator, increments: normal)
let deterministicWalk = walk.simulate(steps: 5) { 1 }

print("Random walk path (expected fixed-generator path [0, -1, 0, -1, 0, -1]): \(walkResult?.path.values ?? [])")
print("Distribution walk path (expected starts at 0 and contains 6 values): \(distributionWalk?.path.values ?? [])")
print("Deterministic walk final value (expected 0 + five steps of 1 = 5): \(deterministicWalk?.finalValue ?? .nan)")

let chain = MarkovChain(
    states: ["sunny", "rainy"],
    transitionProbabilities: [
        [0.8, 0.2],
        [0.4, 0.6],
    ]
)!
let next = chain.nextState(from: "sunny", using: &generator)
let path = chain.simulate(startingAt: "sunny", steps: 5)

print("Next weather state (expected fixed-generator state sunny): \(next ?? "unknown")")
print("Weather path count (expected initial state + 5 steps = 6): \(path?.path.count ?? 0)")
print("State count total (expected 6): \(path?.stateCounts.values.reduce(0, +) ?? 0)")
