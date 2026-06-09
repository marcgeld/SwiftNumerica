internal struct MLXCombinatoricsBackend: CombinatoricsBackend {
    private let reference = PureSwiftCombinatoricsBackend()

    // TODO: Replace delegation with MLX-backed implementations if combinatorics
    // operations become relevant for MLX acceleration.
    internal func factorial(_ n: Int) -> Int? { reference.factorial(n) }
    internal func combinations(n: Int, r: Int) -> Int? { reference.combinations(n: n, r: r) }
    internal func permutations(n: Int, r: Int) -> Int? { reference.permutations(n: n, r: r) }
}
