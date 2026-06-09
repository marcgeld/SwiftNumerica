public extension Numerica.Combinatorics {
    /// Returns the number of ordered selections of `r` items from `n` items.
    ///
    /// This computes `P(n, r) = n! / (n - r)!`.
    ///
    /// - Parameters:
    ///   - n: The number of available items.
    ///   - r: The number of selected items.
    /// - Returns: The number of permutations, or `nil` when the inputs are invalid.
    static func permutations(n: Int, r: Int) -> Int? {
        try? BackendResolver.combinatoricsBackend().permutations(n: n, r: r)
    }
}
