internal struct PureSwiftCombinatoricsBackend: CombinatoricsBackend {
    internal func factorial(_ n: Int) -> Int? {
        guard InputValidation.isValidCount(n) else { return nil }
        guard n > 1 else { return 1 }

        var result = 1
        for value in 2...n {
            let (product, overflow) = result.multipliedReportingOverflow(by: value)
            guard !overflow else { return nil }
            result = product
        }
        return result
    }

    internal func combinations(n: Int, r: Int) -> Int? {
        guard InputValidation.isValidSelection(n: n, r: r) else { return nil }
        let k = min(r, n - r)
        guard k > 0 else { return 1 }

        var result = 1
        for i in 1...k {
            let numerator = n - k + i
            let divisor = i
            let shared = greatestCommonDivisor(result, divisor)
            let reducedResult = result / shared
            let reducedDivisor = divisor / shared
            guard numerator % reducedDivisor == 0 else { return nil }
            let (product, overflow) = reducedResult.multipliedReportingOverflow(by: numerator / reducedDivisor)
            guard !overflow else { return nil }
            result = product
        }
        return result
    }

    internal func permutations(n: Int, r: Int) -> Int? {
        guard InputValidation.isValidSelection(n: n, r: r) else { return nil }
        guard r > 0 else { return 1 }

        var result = 1
        for value in (n - r + 1)...n {
            let (product, overflow) = result.multipliedReportingOverflow(by: value)
            guard !overflow else { return nil }
            result = product
        }
        return result
    }

    private func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
        var a = lhs
        var b = rhs
        while b != 0 {
            (a, b) = (b, a % b)
        }
        return a
    }
}
