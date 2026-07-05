import SwiftNumerica

// Random walk:
// https://en.wikipedia.org/wiki/Random_walk
//
// This example simulates custom, distribution-driven, and deterministic random
// walks from the same initial value.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 7

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

var generator = FixedGenerator()
let walk = RandomWalk(initialValue: 0)!
let normal = Numerica.Probability.NormalDistribution(mean: 0, standardDeviation: 1)!
let random = walk.simulate(steps: 5, using: &generator) { rng in
    Bool.random(using: &rng) ? 1 : -1
}
let distribution = walk.simulate(steps: 5, using: &generator, increments: normal)
let deterministic = walk.simulate(steps: 5) { 1 }

print("Random path (expected fixed-generator path [0, -1, -2, -1, 0, 1]): \(random?.path.values ?? [])")
print("Distribution path (expected starts at 0 and contains 6 values): \(distribution?.path.values ?? [])")
print("Deterministic final value (expected 0 + five steps of 1 = 5): \(deterministic?.finalValue ?? .nan)")
