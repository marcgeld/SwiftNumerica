import Foundation

internal enum ProbabilityMath {
    internal static let pi = 3.14159265358979323846264338327950288
    internal static let squareRootOfTwo = 1.41421356237309504880168872420969808
    internal static let squareRootOfTwoPi = 2.50662827463100050241576528481104525

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

    private static func erfApproximation(_ x: Double) -> Double {
        let sign = x < 0 ? -1.0 : 1.0
        let absolute = Swift.abs(x)
        let t = 1 / (1 + 0.3275911 * absolute)
        let polynomial = (((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592
        let y = 1 - polynomial * t * Foundation.exp(-absolute * absolute)
        return sign * y
    }
}
