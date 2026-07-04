import Testing

@testable import SwiftNumerica

@Test func minimizeDefaultLBFGSFindsQuadraticMinimum() throws {
    let result = try #require(
        minimize(
            function: { point in
                let x = point[0] - 3
                let y = point[1] + 2
                return x * x + y * y
            },
            initialGuess: [0, 0]
        )
    )

    #expect(result.converged)
    #expect(result.reason == .converged)
    #expect(result.solution[0].isApproximatelyEqual(to: 3, tolerance: 1e-5))
    #expect(result.solution[1].isApproximatelyEqual(to: -2, tolerance: 1e-5))
    #expect(result.value.isApproximatelyEqual(to: 0, tolerance: 1e-10))
}

@Test func maximizeFindsConcaveQuadraticMaximum() throws {
    let result = try #require(
        maximize(
            function: { point in
                let x = point[0] - 2
                return 5 - x * x
            },
            initialGuess: [0]
        )
    )

    #expect(result.converged)
    #expect(result.solution[0].isApproximatelyEqual(to: 2, tolerance: 1e-5))
    #expect(result.value.isApproximatelyEqual(to: 5, tolerance: 1e-10))
}

@Test func gradientDescentMinimizesOneDimensionalQuadratic() throws {
    let result = try #require(
        Numerica.Optimization.minimize(
            function: { point in
                let x = point[0] - 4
                return x * x
            },
            initialGuess: [10],
            options: .init(
                algorithm: .gradientDescent,
                maxIterations: 2_000,
                tolerance: 1e-10,
                gradientTolerance: 1e-6,
                learningRate: 0.2
            )
        )
    )

    #expect(result.converged)
    #expect(result.solution[0].isApproximatelyEqual(to: 4, tolerance: 1e-4))
}

@Test func newtonRaphsonMinimizesQuadratic() throws {
    let result = try #require(
        Numerica.Optimization.minimize(
            function: { point in
                let x = point[0] - 1
                let y = point[1] + 3
                return 2 * x * x + 3 * y * y
            },
            initialGuess: [8, 2],
            options: .init(algorithm: .newtonRaphson)
        )
    )

    #expect(result.converged)
    #expect(result.solution[0].isApproximatelyEqual(to: 1, tolerance: 1e-5))
    #expect(result.solution[1].isApproximatelyEqual(to: -3, tolerance: 1e-5))
}

@Test func nelderMeadMinimizesWithoutGradients() throws {
    let result = try #require(
        Numerica.Optimization.minimize(
            function: { point in
                let x = point[0] + 1
                let y = point[1] - 2
                return x * x + y * y
            },
            initialGuess: [3, -4],
            options: .init(
                algorithm: .nelderMead,
                maxIterations: 500,
                tolerance: 1e-8,
                initialSimplexStep: 1
            )
        )
    )

    #expect(result.converged)
    #expect(result.solution[0].isApproximatelyEqual(to: -1, tolerance: 1e-4))
    #expect(result.solution[1].isApproximatelyEqual(to: 2, tolerance: 1e-4))
}

@Test func invalidOptimizationInputsReturnNil() {
    let result = Numerica.Optimization.minimize(
        function: { $0[0] * $0[0] },
        initialGuess: [],
        options: .init()
    )

    #expect(result == nil)
}
