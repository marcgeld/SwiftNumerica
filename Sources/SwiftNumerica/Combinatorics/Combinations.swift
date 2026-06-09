public extension Numerica.Combinatorics {
    /// Returns the number of unordered selections of `r` items from `n` items.
    ///
    /// This computes `C(n, r) = n! / (r! * (n - r)!)`.
    ///
    /// - Parameters:
    ///   - n: The number of available items.
    ///   - r: The number of selected items.
    /// - Returns: The number of combinations, or `nil` when the inputs are invalid.
    static func combinations(n: Int, r: Int) -> Int? {
        try? BackendResolver.combinatoricsBackend().combinations(n: n, r: r)
    }
}
