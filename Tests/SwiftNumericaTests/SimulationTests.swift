import Testing

@testable import SwiftNumerica

@Test func monteCarloSimulationSummarizesTrialEstimates() throws {
    let simulation = try #require(MonteCarloSimulation(iterations: 4))
    var generator = FixedGenerator([1, 2, 3, 4])

    let result = try #require(
        simulation.run(using: &generator) { generator in
            Double(generator.next())
        })

    #expect(result.iterations == 4)
    #expect(result.estimates.values == [1, 2, 3, 4])
    #expect(result.mean.isApproximatelyEqual(to: 2.5))
    #expect(result.variance.isApproximatelyEqual(to: 5.0 / 3.0))
    #expect(result.standardError.isApproximatelyEqual(to: (5.0 / 12.0).squareRoot()))
}

@Test func monteCarloSimulationRejectsInvalidInputs() {
    #expect(MonteCarloSimulation(iterations: 0) == nil)

    let simulation = MonteCarloSimulation(iterations: 1)
    #expect(simulation?.run { Double.nan } == nil)
}

@Test func randomWalkBuildsPathFromIncrements() throws {
    let walk = try #require(RandomWalk(initialValue: 10))
    var increments = [1.0, -2.0, 3.0]

    let result = try #require(
        walk.simulate(steps: 3) {
            increments.removeFirst()
        })

    #expect(result.steps == 3)
    #expect(result.initialValue.isApproximatelyEqual(to: 10))
    #expect(result.finalValue.isApproximatelyEqual(to: 12))
    #expect(result.path.values == [10, 11, 9, 12])
}

@Test func randomWalkCanUseContinuousDistributionForSteps() throws {
    let walk = try #require(RandomWalk(initialValue: 0))
    let distribution = try #require(Numerica.Probability.UniformDistribution(lowerBound: 1, upperBound: 1.0001))
    var generator = FixedGenerator([0, 1, 2])

    let result = try #require(
        walk.simulate(steps: 3, using: &generator, increments: distribution)
    )

    #expect(result.path.count == 4)
    #expect(result.finalValue >= 3)
    #expect(result.finalValue <= 3.0003)
}

@Test func markovChainSimulatesDeterministicTransitions() throws {
    let chain = try #require(
        MarkovChain(
            states: ["sunny", "rainy"],
            transitionProbabilities: [
                [0, 1],
                [0, 1],
            ]
        ))
    var generator = FixedGenerator([0, 0, 0])

    let result = try #require(chain.simulate(startingAt: "sunny", steps: 3, using: &generator))

    #expect(result.path == ["sunny", "rainy", "rainy", "rainy"])
    #expect(result.stateCounts["sunny"] == 1)
    #expect(result.stateCounts["rainy"] == 3)
    #expect(try #require(chain.nextState(from: "sunny", using: &generator)) == "rainy")
}

@Test func markovChainRejectsInvalidTransitionMatrices() {
    #expect(
        MarkovChain(
            states: ["a", "b"],
            transitionProbabilities: [
                [0.5, 0.4],
                [0.2, 0.8],
            ]
        ) == nil
    )
    #expect(
        MarkovChain(
            states: ["a", "a"],
            transitionProbabilities: [
                [1, 0],
                [0, 1],
            ]
        ) == nil
    )
}

private struct FixedGenerator: RandomNumberGenerator {
    private var values: [UInt64]
    private var index = 0

    init(_ values: [UInt64]) {
        self.values = values.isEmpty ? [0] : values
    }

    mutating func next() -> UInt64 {
        let value = values[index % values.count]
        index += 1
        return value
    }
}
