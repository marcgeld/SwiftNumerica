import SwiftNumerica

// Monte Carlo method:
// https://en.wikipedia.org/wiki/Monte_Carlo_method
//
// This example runs random and deterministic Monte Carlo estimators.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 42

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

var generator = FixedGenerator()
let simulation = MonteCarloSimulation(iterations: 5)!
let randomResult = simulation.run(using: &generator) {
    Double.random(in: 0...1, using: &$0)
}
let deterministicResult = simulation.run { 0.5 }

print("Random estimates:", randomResult?.estimates.values ?? [])
print("Random mean:", randomResult?.mean ?? .nan)
print("Random variance:", randomResult?.variance ?? .nan)
print("Random standard error:", randomResult?.standardError ?? .nan)
print("Deterministic mean:", deterministicResult?.mean ?? .nan)
