public extension Numerica.Simulation {
    /// A repeated random experiment used to estimate an expected value.
    struct MonteCarloSimulation: Equatable, Sendable {
        /// The result of a Monte Carlo run.
        public struct Result: Equatable, Sendable {
            /// The individual trial estimates.
            public let estimates: Tensor<Double>

            /// The number of trials.
            public let iterations: Int

            /// The estimated expected value.
            public let mean: Double

            /// The sample variance of the trial estimates.
            public let variance: Double

            /// The estimated standard error of the mean.
            public let standardError: Double

            /// Creates a Monte Carlo result.
            public init(
                estimates: Tensor<Double>,
                iterations: Int,
                mean: Double,
                variance: Double,
                standardError: Double
            ) {
                self.estimates = estimates
                self.iterations = iterations
                self.mean = mean
                self.variance = variance
                self.standardError = standardError
            }
        }

        /// The number of Monte Carlo trials.
        public let iterations: Int

        /// Creates a Monte Carlo simulation.
        ///
        /// - Parameter iterations: The number of trials. Must be positive.
        public init?(iterations: Int) {
            guard iterations > 0 else { return nil }
            self.iterations = iterations
        }

        /// Runs a Monte Carlo simulation using a caller-provided random number generator.
        public func run<T: RandomNumberGenerator>(
            using generator: inout T,
            estimator: (inout T) -> Double
        ) -> Result? {
            var estimates: [Double] = []
            estimates.reserveCapacity(iterations)

            for _ in 0..<iterations {
                let estimate = estimator(&generator)
                guard estimate.isFinite else { return nil }
                estimates.append(estimate)
            }

            return result(from: estimates)
        }

        /// Runs a Monte Carlo simulation using `SystemRandomNumberGenerator`.
        public func run(estimator: () -> Double) -> Result? {
            var estimates: [Double] = []
            estimates.reserveCapacity(iterations)

            for _ in 0..<iterations {
                let estimate = estimator()
                guard estimate.isFinite else { return nil }
                estimates.append(estimate)
            }

            return result(from: estimates)
        }

        private func result(from estimates: [Double]) -> Result? {
            let tensor = Tensor.vector(estimates)
            guard let mean = Numerica.Statistics.mean(tensor) else { return nil }
            let variance = Numerica.Statistics.sampleVariance(tensor) ?? 0
            let standardError = (variance / Double(iterations)).squareRoot()

            return .init(
                estimates: tensor,
                iterations: iterations,
                mean: mean,
                variance: variance,
                standardError: standardError
            )
        }
    }

    /// A one-dimensional additive random walk.
    struct RandomWalk: Equatable, Sendable {
        /// The result of a random walk simulation.
        public struct Result: Equatable, Sendable {
            /// The full path, including the initial value.
            public let path: Tensor<Double>

            /// The number of simulated steps.
            public let steps: Int

            /// The initial value.
            public let initialValue: Double

            /// The final value.
            public let finalValue: Double

            /// Creates a random walk result.
            public init(path: Tensor<Double>, steps: Int, initialValue: Double, finalValue: Double) {
                self.path = path
                self.steps = steps
                self.initialValue = initialValue
                self.finalValue = finalValue
            }
        }

        /// The starting value.
        public let initialValue: Double

        /// Creates a random walk.
        public init?(initialValue: Double = 0) {
            guard initialValue.isFinite else { return nil }
            self.initialValue = initialValue
        }

        /// Simulates a random walk with caller-provided step increments.
        public func simulate<T: RandomNumberGenerator>(
            steps: Int,
            using generator: inout T,
            step: (inout T) -> Double
        ) -> Result? {
            guard steps >= 0 else { return nil }

            var path = [initialValue]
            path.reserveCapacity(steps + 1)
            var currentValue = initialValue

            for _ in 0..<steps {
                let increment = step(&generator)
                guard increment.isFinite else { return nil }
                currentValue += increment
                guard currentValue.isFinite else { return nil }
                path.append(currentValue)
            }

            return .init(
                path: .vector(path),
                steps: steps,
                initialValue: initialValue,
                finalValue: currentValue
            )
        }

        /// Simulates a random walk using a continuous distribution for increments.
        public func simulate<T: RandomNumberGenerator, Distribution: Numerica.Probability.ContinuousDistribution>(
            steps: Int,
            using generator: inout T,
            increments distribution: Distribution
        ) -> Result? {
            simulate(steps: steps, using: &generator) { generator in
                distribution.sample(using: &generator)
            }
        }

        /// Simulates a random walk using `SystemRandomNumberGenerator`.
        public func simulate(steps: Int, step: () -> Double) -> Result? {
            guard steps >= 0 else { return nil }

            var path = [initialValue]
            path.reserveCapacity(steps + 1)
            var currentValue = initialValue

            for _ in 0..<steps {
                let increment = step()
                guard increment.isFinite else { return nil }
                currentValue += increment
                guard currentValue.isFinite else { return nil }
                path.append(currentValue)
            }

            return .init(
                path: .vector(path),
                steps: steps,
                initialValue: initialValue,
                finalValue: currentValue
            )
        }
    }

    /// A finite-state discrete-time Markov chain.
    struct MarkovChain<State: Hashable & Sendable>: Sendable {
        /// The result of a Markov chain simulation.
        public struct Result: Equatable, Sendable where State: Equatable {
            /// The full state path, including the initial state.
            public let path: [State]

            /// The number of simulated transitions.
            public let steps: Int

            /// Counts by state over the simulated path.
            public let stateCounts: [State: Int]

            /// Creates a Markov chain result.
            public init(path: [State], steps: Int, stateCounts: [State: Int]) {
                self.path = path
                self.steps = steps
                self.stateCounts = stateCounts
            }
        }

        /// The chain states, ordered to match the transition matrix.
        public let states: [State]

        /// The row-stochastic transition matrix.
        public let transitionMatrix: Matrix

        private let stateIndexes: [State: Int]

        /// Creates a Markov chain from states and a row-stochastic transition matrix.
        public init?(states: [State], transitionMatrix: Matrix) {
            guard !states.isEmpty,
                  Set(states).count == states.count,
                  transitionMatrix.rowCount == states.count,
                  transitionMatrix.columnCount == states.count else { return nil }

            for row in transitionMatrix.rows {
                guard row.allSatisfy({ $0 >= 0 && $0 <= 1 }) else { return nil }
                let sum = row.reduce(0.0) { $0 + $1 }
                guard Swift.abs(sum - 1) <= 1e-10 else { return nil }
            }

            self.states = states
            self.transitionMatrix = transitionMatrix
            self.stateIndexes = Dictionary(uniqueKeysWithValues: states.enumerated().map { ($1, $0) })
        }

        /// Creates a Markov chain from states and transition probabilities.
        public init?(states: [State], transitionProbabilities: [[Double]]) {
            guard let matrix = Matrix(transitionProbabilities) else { return nil }
            self.init(states: states, transitionMatrix: matrix)
        }

        /// Draws the next state from `state`.
        public func nextState<T: RandomNumberGenerator>(from state: State, using generator: inout T) -> State? {
            guard let rowIndex = stateIndexes[state] else { return nil }
            let row = transitionMatrix.rows[rowIndex]
            let draw = Double.random(in: 0..<1, using: &generator)
            var cumulative = 0.0

            for (index, probability) in row.enumerated() {
                cumulative += probability
                if draw < cumulative {
                    return states[index]
                }
            }

            // Floating-point rounding can leave the cumulative sum just below
            // the draw. Fall back to the last state that has any probability
            // mass so zero-probability states are never returned.
            guard let fallbackIndex = row.lastIndex(where: { $0 > 0 }) else { return nil }
            return states[fallbackIndex]
        }

        /// Simulates a state path from an initial state.
        public func simulate<T: RandomNumberGenerator>(
            startingAt initialState: State,
            steps: Int,
            using generator: inout T
        ) -> Result? {
            guard steps >= 0,
                  stateIndexes[initialState] != nil else { return nil }

            var path = [initialState]
            path.reserveCapacity(steps + 1)
            var currentState = initialState

            for _ in 0..<steps {
                guard let next = nextState(from: currentState, using: &generator) else { return nil }
                path.append(next)
                currentState = next
            }

            return .init(path: path, steps: steps, stateCounts: stateCounts(for: path))
        }

        /// Simulates a state path using `SystemRandomNumberGenerator`.
        public func simulate(startingAt initialState: State, steps: Int) -> Result? {
            var generator = SystemRandomNumberGenerator()
            return simulate(startingAt: initialState, steps: steps, using: &generator)
        }

        private func stateCounts(for path: [State]) -> [State: Int] {
            path.reduce(into: [:]) { counts, state in
                counts[state, default: 0] += 1
            }
        }
    }
}

/// A repeated random experiment used to estimate an expected value.
public typealias MonteCarloSimulation = Numerica.Simulation.MonteCarloSimulation

/// A one-dimensional additive random walk.
public typealias RandomWalk = Numerica.Simulation.RandomWalk

/// A finite-state discrete-time Markov chain.
public typealias MarkovChain<State: Hashable & Sendable> = Numerica.Simulation.MarkovChain<State>
