import Foundation

internal enum ProbabilityMath {
    internal static let pi = 3.14159265358979323846264338327950288
    internal static let squareRootOfTwo = 1.41421356237309504880168872420969808
    internal static let squareRootOfTwoPi = 2.50662827463100050241576528481104525
    private static let convergenceTolerance = 3e-14
    private static let maximumIterations = 200
    private static let minimumContinuedFractionValue = 1e-300

    internal static func factorial(_ n: Int) -> Double? {
        guard n >= 0 else { return nil }
        guard n > 1 else { return 1 }
        return Double((2...n).reduce(1, *))
    }

    internal static func combinations(n: Int, r: Int) -> Double? {
        guard n >= 0, r >= 0, r <= n else { return nil }
        let k = Swift.min(r, n - r)
        guard k > 0 else { return 1 }
        var result = 1.0
        for i in 1...k {
            result = result * Double(n - k + i) / Double(i)
        }
        return result
    }

    internal static func normalCDFStandardized(_ z: Double) -> Double {
        0.5 * (1 + erfApproximation(z / squareRootOfTwo))
    }

    internal static func inverseNormalCDFStandardized(_ probability: Double) -> Double? {
        guard (0...1).contains(probability) else { return nil }
        if probability == 0 { return -.infinity }
        if probability == 1 { return .infinity }

        var lower = -8.0
        var upper = 8.0
        while normalCDFStandardized(lower) > probability {
            lower *= 2
        }
        while normalCDFStandardized(upper) < probability {
            upper *= 2
        }

        for _ in 0..<100 {
            let midpoint = (lower + upper) / 2
            if normalCDFStandardized(midpoint) < probability {
                lower = midpoint
            } else {
                upper = midpoint
            }
        }
        return (lower + upper) / 2
    }

    internal static func logGamma(_ value: Double) -> Double {
        let coefficients = [
            676.5203681218851,
            -1259.1392167224028,
            771.32342877765313,
            -176.61502916214059,
            12.507343278686905,
            -0.13857109526572012,
            9.9843695780195716e-6,
            1.5056327351493116e-7,
        ]

        if value < 0.5 {
            return Foundation.log(pi) - Foundation.log(Foundation.sin(pi * value)) - logGamma(1 - value)
        }

        let shifted = value - 1
        var accumulator = 0.99999999999980993
        for (index, coefficient) in coefficients.enumerated() {
            accumulator += coefficient / (shifted + Double(index) + 1)
        }

        let t = shifted + Double(coefficients.count) - 0.5
        return 0.5 * Foundation.log(2 * pi) + (shifted + 0.5) * Foundation.log(t) - t + Foundation.log(accumulator)
    }

    internal static func regularizedLowerIncompleteGamma(shape: Double, x: Double) -> Double {
        guard shape > 0 else { return .nan }
        guard x > 0 else { return 0 }

        if x < shape + 1 {
            return incompleteGammaSeries(shape: shape, x: x)
        }
        return 1 - incompleteGammaContinuedFraction(shape: shape, x: x)
    }

    internal static func regularizedBeta(x: Double, alpha: Double, beta: Double) -> Double {
        guard alpha > 0, beta > 0 else { return .nan }
        if x <= 0 { return 0 }
        if x >= 1 { return 1 }

        let logBetaTerm = logGamma(alpha + beta) - logGamma(alpha) - logGamma(beta)
            + alpha * Foundation.log(x)
            + beta * Foundation.log1p(-x)
        let betaTerm = Foundation.exp(logBetaTerm)

        if x < (alpha + 1) / (alpha + beta + 2) {
            return betaTerm * betaContinuedFraction(alpha: alpha, beta: beta, x: x) / alpha
        }
        return 1 - betaTerm * betaContinuedFraction(alpha: beta, beta: alpha, x: 1 - x) / beta
    }

    internal static func standardNormalSample<T: RandomNumberGenerator>(using generator: inout T) -> Double {
        let radiusUniform = Double.random(in: Double.leastNonzeroMagnitude..<1, using: &generator)
        let angleUniform = Double.random(in: 0..<1, using: &generator)
        return Foundation.sqrt(-2 * Foundation.log(radiusUniform))
            * Foundation.cos(2 * pi * angleUniform)
    }

    internal static func gammaSample<T: RandomNumberGenerator>(
        shape: Double,
        scale: Double,
        using generator: inout T
    ) -> Double {
        if shape < 1 {
            let boosted = gammaSample(shape: shape + 1, scale: 1, using: &generator)
            let uniform = Double.random(in: Double.leastNonzeroMagnitude..<1, using: &generator)
            return scale * boosted * Foundation.pow(uniform, 1 / shape)
        }

        let d = shape - 1 / 3
        let c = 1 / Foundation.sqrt(9 * d)

        while true {
            let normal = standardNormalSample(using: &generator)
            let transformed = 1 + c * normal
            guard transformed > 0 else { continue }

            let v = transformed * transformed * transformed
            let uniform = Double.random(in: Double.leastNonzeroMagnitude..<1, using: &generator)
            if uniform < 1 - 0.0331 * normal * normal * normal * normal {
                return scale * d * v
            }
            if Foundation.log(uniform) < 0.5 * normal * normal + d * (1 - v + Foundation.log(v)) {
                return scale * d * v
            }
        }
    }

    private static func erfApproximation(_ x: Double) -> Double {
        let sign = x < 0 ? -1.0 : 1.0
        let absolute = Swift.abs(x)
        let t = 1 / (1 + 0.3275911 * absolute)
        let polynomial = (((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592
        let y = 1 - polynomial * t * Foundation.exp(-absolute * absolute)
        return sign * y
    }

    private static func incompleteGammaSeries(shape: Double, x: Double) -> Double {
        let logGammaValue = logGamma(shape)
        var ap = shape
        var delta = 1 / shape
        var sum = delta

        for _ in 0..<maximumIterations {
            ap += 1
            delta *= x / ap
            sum += delta
            if Swift.abs(delta) < Swift.abs(sum) * convergenceTolerance {
                return sum * Foundation.exp(-x + shape * Foundation.log(x) - logGammaValue)
            }
        }

        return sum * Foundation.exp(-x + shape * Foundation.log(x) - logGammaValue)
    }

    private static func incompleteGammaContinuedFraction(shape: Double, x: Double) -> Double {
        let logGammaValue = logGamma(shape)
        var b = x + 1 - shape
        var c = 1 / minimumContinuedFractionValue
        var d = 1 / Swift.max(b, minimumContinuedFractionValue)
        var h = d

        for index in 1...maximumIterations {
            let i = Double(index)
            let an = -i * (i - shape)
            b += 2
            d = an * d + b
            if Swift.abs(d) < minimumContinuedFractionValue { d = minimumContinuedFractionValue }
            c = b + an / c
            if Swift.abs(c) < minimumContinuedFractionValue { c = minimumContinuedFractionValue }
            d = 1 / d
            let delta = d * c
            h *= delta
            if Swift.abs(delta - 1) < convergenceTolerance {
                break
            }
        }

        return Foundation.exp(-x + shape * Foundation.log(x) - logGammaValue) * h
    }

    private static func betaContinuedFraction(alpha: Double, beta: Double, x: Double) -> Double {
        let qab = alpha + beta
        let qap = alpha + 1
        let qam = alpha - 1
        var c = 1.0
        var d = 1 - qab * x / qap
        if Swift.abs(d) < minimumContinuedFractionValue { d = minimumContinuedFractionValue }
        d = 1 / d
        var h = d

        for m in 1...maximumIterations {
            let mDouble = Double(m)
            let m2 = 2 * mDouble

            var aa = mDouble * (beta - mDouble) * x / ((qam + m2) * (alpha + m2))
            d = 1 + aa * d
            if Swift.abs(d) < minimumContinuedFractionValue { d = minimumContinuedFractionValue }
            c = 1 + aa / c
            if Swift.abs(c) < minimumContinuedFractionValue { c = minimumContinuedFractionValue }
            d = 1 / d
            h *= d * c

            aa = -(alpha + mDouble) * (qab + mDouble) * x / ((alpha + m2) * (qap + m2))
            d = 1 + aa * d
            if Swift.abs(d) < minimumContinuedFractionValue { d = minimumContinuedFractionValue }
            c = 1 + aa / c
            if Swift.abs(c) < minimumContinuedFractionValue { c = minimumContinuedFractionValue }
            d = 1 / d
            let delta = d * c
            h *= delta
            if Swift.abs(delta - 1) < convergenceTolerance {
                break
            }
        }

        return h
    }
}
