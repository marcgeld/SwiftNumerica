import SwiftNumerica

// Numerical optimization:
// https://en.wikipedia.org/wiki/Mathematical_optimization
//
// This example minimizes and maximizes simple objective functions using several
// algorithms and typed options.

func bowl(_ point: [Double]) -> Double {
    let x = point[0] - 3
    let y = point[1] + 2
    return x * x + y * y
}

for algorithm in [
    Numerica.Optimization.Algorithm.gradientDescent,
    .newtonRaphson,
    .lbfgs,
    .nelderMead,
] {
    let options = Numerica.Optimization.Options(
        algorithm: algorithm,
        maxIterations: 500,
        tolerance: 1e-8,
        gradientTolerance: 1e-6,
        finiteDifferenceStep: 1e-6,
        learningRate: 0.05,
        historySize: 5,
        initialSimplexStep: 1
    )
    let result = Numerica.Optimization.minimize(
        function: bowl,
        initialGuess: [0, 0],
        options: options
    )
    print("Minimize with", algorithm, "->", result?.solution ?? [], result?.value ?? .nan, result?.reason ?? .invalidInput)
}

let freeMinimize = minimize(function: bowl, initialGuess: [0, 0])
let freeMaximize = maximize(function: { -bowl($0) }, initialGuess: [0, 0])

print("Free minimize:", freeMinimize?.solution ?? [], freeMinimize?.value ?? .nan)
print("Free maximize:", freeMaximize?.solution ?? [], freeMaximize?.value ?? .nan)
