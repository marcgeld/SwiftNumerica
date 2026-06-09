public extension Numerica.Combinatorics {
    /// Returns `n!`.
    ///
    /// - Parameter n: A non-negative integer.
    /// - Returns: The factorial of `n`, or `nil` when `n` is negative.
    static func factorial(_ n: Int) -> Int? {
        try? BackendResolver.combinatoricsBackend().factorial(n)
    }
}
