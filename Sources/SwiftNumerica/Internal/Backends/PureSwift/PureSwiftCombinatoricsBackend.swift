internal struct PureSwiftCombinatoricsBackend: CombinatoricsBackend {
    internal func factorial(_ n: Int) -> Int? {
        guard InputValidation.isValidCount(n) else { return nil }
        guard n > 1 else { return 1 }

        return (2...n).reduce(1) { partialResult, value in
            partialResult * value
        }
    }

    internal func combinations(n: Int, r: Int) -> Int? {
        guard InputValidation.isValidSelection(n: n, r: r) else { return nil }
        let k = min(r, n - r)
        guard k > 0 else { return 1 }

        var result = 1
        for i in 1...k {
            result = result * (n - k + i) / i
        }
        return result
    }

    internal func permutations(n: Int, r: Int) -> Int? {
        guard InputValidation.isValidSelection(n: n, r: r) else { return nil }
        guard r > 0 else { return 1 }

        var result = 1
        for value in (n - r + 1)...n {
            result *= value
        }
        return result
    }
}
