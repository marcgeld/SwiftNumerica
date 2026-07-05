import SwiftNumerica

// Markov chain:
// https://en.wikipedia.org/wiki/Markov_chain
//
// This example models weather transitions with a finite-state Markov chain.

struct FixedGenerator: RandomNumberGenerator {
    var state: UInt64 = 99

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1
        return state
    }
}

var generator = FixedGenerator()
let chain = MarkovChain(
    states: ["sunny", "rainy"],
    transitionProbabilities: [
        [0.8, 0.2],
        [0.4, 0.6],
    ]
)!
let next = chain.nextState(from: "sunny", using: &generator)
let seededPath = chain.simulate(startingAt: "sunny", steps: 5, using: &generator)
let path = chain.simulate(startingAt: "sunny", steps: 5)

print("States:", chain.states)
print("Transition matrix:", chain.transitionMatrix.rows)
print("Next state:", next ?? "unknown")
print("Seeded path:", seededPath?.path ?? [])
print("Unseeded path count:", path?.path.count ?? 0)
print("Unseeded state count total:", path?.stateCounts.values.reduce(0, +) ?? 0)
