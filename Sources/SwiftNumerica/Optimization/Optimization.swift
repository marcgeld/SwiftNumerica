import Foundation

public extension Numerica.Optimization {
    /// A scalar objective function over a dense vector.
    typealias ObjectiveFunction = ([Double]) -> Double

    /// The optimization algorithm used by `minimize` and `maximize`.
    enum Algorithm: Equatable, Sendable {
        /// Batch gradient descent with backtracking when a step does not improve the objective.
        case gradientDescent

        /// Newton-Raphson using numerical gradients and Hessians.
        case newtonRaphson

        /// Limited-memory BFGS using numerical gradients.
        case lbfgs

        /// Nelder-Mead simplex search, which does not require gradients.
        case nelderMead
    }

    /// Configuration for numerical optimization.
    struct Options: Equatable, Sendable {
        /// The optimization algorithm.
        public var algorithm: Algorithm

        /// The maximum number of optimization iterations.
        public var maxIterations: Int

        /// The tolerance for objective and position convergence.
        public var tolerance: Double

        /// The gradient-norm tolerance used by gradient-based methods.
        public var gradientTolerance: Double

        /// The base finite-difference step used for numerical derivatives.
        public var finiteDifferenceStep: Double

        /// The initial learning rate used by gradient descent.
        public var learningRate: Double

        /// The number of correction pairs retained by LBFGS.
        public var historySize: Int

        /// The initial simplex step used by Nelder-Mead.
        public var initialSimplexStep: Double

        /// Creates optimization options.
        public init(
            algorithm: Algorithm = .lbfgs,
            maxIterations: Int = 1_000,
            tolerance: Double = 1e-8,
            gradientTolerance: Double = 1e-6,
            finiteDifferenceStep: Double = 1e-6,
            learningRate: Double = 0.01,
            historySize: Int = 10,
            initialSimplexStep: Double = 1
        ) {
            self.algorithm = algorithm
            self.maxIterations = maxIterations
            self.tolerance = tolerance
            self.gradientTolerance = gradientTolerance
            self.finiteDifferenceStep = finiteDifferenceStep
            self.learningRate = learningRate
            self.historySize = historySize
            self.initialSimplexStep = initialSimplexStep
        }
    }

    /// The reason an optimization run stopped.
    enum TerminationReason: Equatable, Sendable {
        /// The optimizer met the configured convergence tolerance.
        case converged

        /// The optimizer reached the maximum iteration count.
        case maxIterationsReached

        /// The optimizer encountered invalid inputs or non-finite objective values.
        case invalidInput

        /// The optimizer could not find an improving step.
        case stepFailure
    }

    /// The result of a numerical optimization run.
    struct Result: Equatable, Sendable {
        /// The best point found by the optimizer.
        public let solution: [Double]

        /// The objective value at `solution`.
        public let value: Double

        /// The number of iterations performed.
        public let iterations: Int

        /// Whether the optimizer met a convergence tolerance.
        public let converged: Bool

        /// The reason the optimizer stopped.
        public let reason: TerminationReason

        /// Creates an optimization result.
        public init(
            solution: [Double],
            value: Double,
            iterations: Int,
            converged: Bool,
            reason: TerminationReason
        ) {
            self.solution = solution
            self.value = value
            self.iterations = iterations
            self.converged = converged
            self.reason = reason
        }
    }

    /// Minimizes a scalar objective function.
    ///
    /// - Parameters:
    ///   - function: The objective function to minimize.
    ///   - initialGuess: The starting point.
    ///   - options: Optimization configuration.
    /// - Returns: The optimization result, or `nil` when the inputs are invalid.
    static func minimize(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options = Options()
    ) -> Result? {
        guard isValid(initialGuess), isValid(options) else { return nil }

        switch options.algorithm {
        case .gradientDescent:
            return gradientDescent(function: function, initialGuess: initialGuess, options: options)
        case .newtonRaphson:
            return newtonRaphson(function: function, initialGuess: initialGuess, options: options)
        case .lbfgs:
            return lbfgs(function: function, initialGuess: initialGuess, options: options)
        case .nelderMead:
            return nelderMead(function: function, initialGuess: initialGuess, options: options)
        }
    }

    /// Maximizes a scalar objective function by minimizing its negation.
    ///
    /// - Parameters:
    ///   - function: The objective function to maximize.
    ///   - initialGuess: The starting point.
    ///   - options: Optimization configuration.
    /// - Returns: The optimization result, or `nil` when the inputs are invalid.
    static func maximize(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options = Options()
    ) -> Result? {
        guard let result = minimize(
            function: { -function($0) },
            initialGuess: initialGuess,
            options: options
        ) else { return nil }

        return .init(
            solution: result.solution,
            value: function(result.solution),
            iterations: result.iterations,
            converged: result.converged,
            reason: result.reason
        )
    }

    private static func gradientDescent(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options
    ) -> Result? {
        var point = initialGuess
        var value = function(point)
        guard value.isFinite else { return invalidResult(point: point, iterations: 0) }

        for iteration in 0..<options.maxIterations {
            guard let gradient = numericalGradient(function, at: point, step: options.finiteDifferenceStep) else {
                return invalidResult(point: point, iterations: iteration)
            }
            let gradientNorm = norm(gradient)
            if gradientNorm <= options.gradientTolerance {
                return completed(point: point, value: value, iterations: iteration, reason: .converged)
            }

            let direction = scaled(gradient, by: -1)
            guard let candidate = descentStep(
                function: function,
                point: point,
                value: value,
                gradient: gradient,
                direction: direction,
                initialStep: options.learningRate,
                tolerance: options.tolerance
            ) else {
                return completed(point: point, value: value, iterations: iteration, reason: .stepFailure)
            }

            if hasConverged(
                oldPoint: point,
                newPoint: candidate.point,
                oldValue: value,
                newValue: candidate.value,
                tolerance: options.tolerance
            ) {
                return completed(
                    point: candidate.point,
                    value: candidate.value,
                    iterations: iteration + 1,
                    reason: .converged
                )
            }

            point = candidate.point
            value = candidate.value
        }

        return completed(point: point, value: value, iterations: options.maxIterations, reason: .maxIterationsReached)
    }

    private static func newtonRaphson(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options
    ) -> Result? {
        var point = initialGuess
        var value = function(point)
        guard value.isFinite else { return invalidResult(point: point, iterations: 0) }

        for iteration in 0..<options.maxIterations {
            guard let gradient = numericalGradient(function, at: point, step: options.finiteDifferenceStep) else {
                return invalidResult(point: point, iterations: iteration)
            }
            let gradientNorm = norm(gradient)
            if gradientNorm <= options.gradientTolerance {
                return completed(point: point, value: value, iterations: iteration, reason: .converged)
            }

            guard let hessian = numericalHessian(function, at: point, step: options.finiteDifferenceStep),
                  let newtonStep = LinearSystemMath.solve(hessian, gradient) else {
                return completed(point: point, value: value, iterations: iteration, reason: .stepFailure)
            }

            var direction = scaled(newtonStep, by: -1)
            if dot(gradient, direction) >= 0 {
                direction = scaled(gradient, by: -1)
            }

            guard let candidate = descentStep(
                function: function,
                point: point,
                value: value,
                gradient: gradient,
                direction: direction,
                initialStep: 1,
                tolerance: options.tolerance
            ) else {
                return completed(point: point, value: value, iterations: iteration, reason: .stepFailure)
            }

            if hasConverged(
                oldPoint: point,
                newPoint: candidate.point,
                oldValue: value,
                newValue: candidate.value,
                tolerance: options.tolerance
            ) {
                return completed(
                    point: candidate.point,
                    value: candidate.value,
                    iterations: iteration + 1,
                    reason: .converged
                )
            }

            point = candidate.point
            value = candidate.value
        }

        return completed(point: point, value: value, iterations: options.maxIterations, reason: .maxIterationsReached)
    }

    private static func lbfgs(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options
    ) -> Result? {
        var point = initialGuess
        var value = function(point)
        guard value.isFinite,
              var gradient = numericalGradient(function, at: point, step: options.finiteDifferenceStep) else {
            return invalidResult(point: point, iterations: 0)
        }

        var correctionSteps: [[Double]] = []
        var correctionGradients: [[Double]] = []
        var inverseRhos: [Double] = []

        for iteration in 0..<options.maxIterations {
            let gradientNorm = norm(gradient)
            if gradientNorm <= options.gradientTolerance {
                return completed(point: point, value: value, iterations: iteration, reason: .converged)
            }

            var direction = scaled(lbfgsDirection(
                gradient: gradient,
                correctionSteps: correctionSteps,
                correctionGradients: correctionGradients,
                inverseRhos: inverseRhos
            ), by: -1)

            if dot(gradient, direction) >= 0 {
                direction = scaled(gradient, by: -1)
            }

            guard let candidate = descentStep(
                function: function,
                point: point,
                value: value,
                gradient: gradient,
                direction: direction,
                initialStep: 1,
                tolerance: options.tolerance
            ) else {
                return completed(point: point, value: value, iterations: iteration, reason: .stepFailure)
            }

            guard let nextGradient = numericalGradient(
                function,
                at: candidate.point,
                step: options.finiteDifferenceStep
            ) else {
                return invalidResult(point: candidate.point, iterations: iteration + 1)
            }

            let pointDelta = subtract(candidate.point, point)
            let gradientDelta = subtract(nextGradient, gradient)
            let curvature = dot(pointDelta, gradientDelta)
            if curvature > 1e-12 {
                correctionSteps.append(pointDelta)
                correctionGradients.append(gradientDelta)
                inverseRhos.append(curvature)

                if correctionSteps.count > options.historySize {
                    correctionSteps.removeFirst()
                    correctionGradients.removeFirst()
                    inverseRhos.removeFirst()
                }
            }

            if hasConverged(
                oldPoint: point,
                newPoint: candidate.point,
                oldValue: value,
                newValue: candidate.value,
                tolerance: options.tolerance
            ) {
                return completed(
                    point: candidate.point,
                    value: candidate.value,
                    iterations: iteration + 1,
                    reason: .converged
                )
            }

            point = candidate.point
            value = candidate.value
            gradient = nextGradient
        }

        return completed(point: point, value: value, iterations: options.maxIterations, reason: .maxIterationsReached)
    }

    private static func nelderMead(
        function: ObjectiveFunction,
        initialGuess: [Double],
        options: Options
    ) -> Result? {
        let dimension = initialGuess.count
        var simplex = [initialGuess]
        for index in 0..<dimension {
            var point = initialGuess
            point[index] += options.initialSimplexStep
            simplex.append(point)
        }

        var values = simplex.map(function)
        guard values.allSatisfy(\.isFinite) else { return invalidResult(point: initialGuess, iterations: 0) }

        let reflection = 1.0
        let expansion = 2.0
        let contraction = 0.5
        let shrink = 0.5

        for iteration in 0..<options.maxIterations {
            sortSimplex(&simplex, &values)

            if simplexConverged(simplex: simplex, values: values, tolerance: options.tolerance) {
                return completed(point: simplex[0], value: values[0], iterations: iteration, reason: .converged)
            }

            let best = simplex[0]
            let worst = simplex[dimension]
            let centroid = centroid(of: Array(simplex.prefix(dimension)))
            let reflected = add(centroid, scaled(subtract(centroid, worst), by: reflection))
            let reflectedValue = function(reflected)
            guard reflectedValue.isFinite else {
                return completed(point: best, value: values[0], iterations: iteration, reason: .stepFailure)
            }

            if reflectedValue < values[0] {
                let expanded = add(centroid, scaled(subtract(reflected, centroid), by: expansion))
                let expandedValue = function(expanded)
                if expandedValue.isFinite && expandedValue < reflectedValue {
                    simplex[dimension] = expanded
                    values[dimension] = expandedValue
                } else {
                    simplex[dimension] = reflected
                    values[dimension] = reflectedValue
                }
            } else if reflectedValue < values[dimension - 1] {
                simplex[dimension] = reflected
                values[dimension] = reflectedValue
            } else {
                let contracted: [Double]
                if reflectedValue < values[dimension] {
                    contracted = add(centroid, scaled(subtract(reflected, centroid), by: contraction))
                } else {
                    contracted = add(centroid, scaled(subtract(worst, centroid), by: contraction))
                }

                let contractedValue = function(contracted)
                if contractedValue.isFinite && contractedValue < values[dimension] {
                    simplex[dimension] = contracted
                    values[dimension] = contractedValue
                } else {
                    for index in 1...dimension {
                        simplex[index] = add(best, scaled(subtract(simplex[index], best), by: shrink))
                        values[index] = function(simplex[index])
                    }
                    guard values.allSatisfy(\.isFinite) else {
                        return completed(point: best, value: values[0], iterations: iteration, reason: .stepFailure)
                    }
                }
            }
        }

        sortSimplex(&simplex, &values)
        return completed(point: simplex[0], value: values[0], iterations: options.maxIterations, reason: .maxIterationsReached)
    }

    private static func isValid(_ point: [Double]) -> Bool {
        !point.isEmpty && point.allSatisfy(\.isFinite)
    }

    private static func isValid(_ options: Options) -> Bool {
        options.maxIterations > 0
            && options.tolerance > 0
            && options.gradientTolerance > 0
            && options.finiteDifferenceStep > 0
            && options.learningRate > 0
            && options.historySize > 0
            && options.initialSimplexStep > 0
    }

    private static func numericalGradient(
        _ function: ObjectiveFunction,
        at point: [Double],
        step: Double
    ) -> [Double]? {
        var gradient = Array(repeating: 0.0, count: point.count)
        for index in point.indices {
            let h = stepSize(for: point[index], base: step)
            var upper = point
            var lower = point
            upper[index] += h
            lower[index] -= h

            let upperValue = function(upper)
            let lowerValue = function(lower)
            guard upperValue.isFinite, lowerValue.isFinite else { return nil }
            gradient[index] = (upperValue - lowerValue) / (2 * h)
        }
        return gradient
    }

    private static func numericalHessian(
        _ function: ObjectiveFunction,
        at point: [Double],
        step: Double
    ) -> [[Double]]? {
        let dimension = point.count
        let centerValue = function(point)
        guard centerValue.isFinite else { return nil }

        var hessian = Array(repeating: Array(repeating: 0.0, count: dimension), count: dimension)
        for row in 0..<dimension {
            let rowStep = stepSize(for: point[row], base: step)
            var upper = point
            var lower = point
            upper[row] += rowStep
            lower[row] -= rowStep

            let upperValue = function(upper)
            let lowerValue = function(lower)
            guard upperValue.isFinite, lowerValue.isFinite else { return nil }
            hessian[row][row] = (upperValue - 2 * centerValue + lowerValue) / (rowStep * rowStep)

            for column in (row + 1)..<dimension {
                let columnStep = stepSize(for: point[column], base: step)
                var upperUpper = point
                var upperLower = point
                var lowerUpper = point
                var lowerLower = point

                upperUpper[row] += rowStep
                upperUpper[column] += columnStep
                upperLower[row] += rowStep
                upperLower[column] -= columnStep
                lowerUpper[row] -= rowStep
                lowerUpper[column] += columnStep
                lowerLower[row] -= rowStep
                lowerLower[column] -= columnStep

                let upperUpperValue = function(upperUpper)
                let upperLowerValue = function(upperLower)
                let lowerUpperValue = function(lowerUpper)
                let lowerLowerValue = function(lowerLower)
                guard upperUpperValue.isFinite,
                      upperLowerValue.isFinite,
                      lowerUpperValue.isFinite,
                      lowerLowerValue.isFinite else { return nil }

                let mixed = (upperUpperValue - upperLowerValue - lowerUpperValue + lowerLowerValue)
                    / (4 * rowStep * columnStep)
                hessian[row][column] = mixed
                hessian[column][row] = mixed
            }
        }
        return hessian
    }

    private static func descentStep(
        function: ObjectiveFunction,
        point: [Double],
        value: Double,
        gradient: [Double],
        direction: [Double],
        initialStep: Double,
        tolerance: Double
    ) -> (point: [Double], value: Double)? {
        let slope = dot(gradient, direction)
        guard slope < 0 else { return nil }

        var step = initialStep
        let armijo = 1e-4
        for _ in 0..<64 {
            let candidatePoint = add(point, scaled(direction, by: step))
            let candidateValue = function(candidatePoint)
            if candidateValue.isFinite && candidateValue <= value + armijo * step * slope {
                return (candidatePoint, candidateValue)
            }

            step *= 0.5
            if step < tolerance * 1e-3 {
                break
            }
        }

        return nil
    }

    private static func lbfgsDirection(
        gradient: [Double],
        correctionSteps: [[Double]],
        correctionGradients: [[Double]],
        inverseRhos: [Double]
    ) -> [Double] {
        guard !correctionSteps.isEmpty else { return gradient }

        var q = gradient
        var alphas = Array(repeating: 0.0, count: correctionSteps.count)

        for index in stride(from: correctionSteps.count - 1, through: 0, by: -1) {
            let alpha = dot(correctionSteps[index], q) / inverseRhos[index]
            alphas[index] = alpha
            q = subtract(q, scaled(correctionGradients[index], by: alpha))
        }

        if let lastStep = correctionSteps.last,
           let lastGradient = correctionGradients.last {
            let yy = dot(lastGradient, lastGradient)
            if yy > 0 {
                q = scaled(q, by: dot(lastStep, lastGradient) / yy)
            }
        }

        for index in 0..<correctionSteps.count {
            let beta = dot(correctionGradients[index], q) / inverseRhos[index]
            q = add(q, scaled(correctionSteps[index], by: alphas[index] - beta))
        }

        return q
    }

    private static func sortSimplex(_ simplex: inout [[Double]], _ values: inout [Double]) {
        let sorted = zip(simplex, values).sorted { $0.1 < $1.1 }
        simplex = sorted.map(\.0)
        values = sorted.map(\.1)
    }

    private static func simplexConverged(simplex: [[Double]], values: [Double], tolerance: Double) -> Bool {
        guard let bestValue = values.first else { return false }
        let valueSpread = values.map { Swift.abs($0 - bestValue) }.max() ?? 0
        let bestPoint = simplex[0]
        let diameter = simplex.map { distance($0, bestPoint) }.max() ?? 0
        return valueSpread <= tolerance && diameter <= tolerance
    }

    private static func centroid(of points: [[Double]]) -> [Double] {
        guard let first = points.first else { return [] }
        var result = Array(repeating: 0.0, count: first.count)
        for point in points {
            result = add(result, point)
        }
        return scaled(result, by: 1 / Double(points.count))
    }

    private static func hasConverged(
        oldPoint: [Double],
        newPoint: [Double],
        oldValue: Double,
        newValue: Double,
        tolerance: Double
    ) -> Bool {
        distance(oldPoint, newPoint) <= tolerance * Swift.max(1, norm(oldPoint))
            || Swift.abs(oldValue - newValue) <= tolerance * Swift.max(1, Swift.abs(oldValue))
    }

    private static func completed(
        point: [Double],
        value: Double,
        iterations: Int,
        reason: TerminationReason
    ) -> Result {
        .init(
            solution: point,
            value: value,
            iterations: iterations,
            converged: reason == .converged,
            reason: reason
        )
    }

    private static func invalidResult(point: [Double], iterations: Int) -> Result {
        .init(
            solution: point,
            value: .nan,
            iterations: iterations,
            converged: false,
            reason: .invalidInput
        )
    }

    private static func stepSize(for value: Double, base: Double) -> Double {
        base * Swift.max(1, Swift.abs(value))
    }

    private static func add(_ lhs: [Double], _ rhs: [Double]) -> [Double] {
        zip(lhs, rhs).map(+)
    }

    private static func subtract(_ lhs: [Double], _ rhs: [Double]) -> [Double] {
        zip(lhs, rhs).map(-)
    }

    private static func scaled(_ vector: [Double], by scalar: Double) -> [Double] {
        vector.map { $0 * scalar }
    }

    private static func dot(_ lhs: [Double], _ rhs: [Double]) -> Double {
        zip(lhs, rhs).map(*).reduce(0, +)
    }

    private static func norm(_ vector: [Double]) -> Double {
        dot(vector, vector).squareRoot()
    }

    private static func distance(_ lhs: [Double], _ rhs: [Double]) -> Double {
        norm(subtract(lhs, rhs))
    }
}

/// Minimizes a scalar objective function.
public func minimize(
    function: Numerica.Optimization.ObjectiveFunction,
    initialGuess: [Double],
    options: Numerica.Optimization.Options = Numerica.Optimization.Options()
) -> Numerica.Optimization.Result? {
    Numerica.Optimization.minimize(function: function, initialGuess: initialGuess, options: options)
}

/// Maximizes a scalar objective function.
public func maximize(
    function: Numerica.Optimization.ObjectiveFunction,
    initialGuess: [Double],
    options: Numerica.Optimization.Options = Numerica.Optimization.Options()
) -> Numerica.Optimization.Result? {
    Numerica.Optimization.maximize(function: function, initialGuess: initialGuess, options: options)
}
