internal struct AccelerateCombinatoricsBackend: CombinatoricsBackend {
    private let reference = PureSwiftCombinatoricsBackend()

    // Combinatorics is scalar integer arithmetic, so Accelerate does not offer a
    // useful implementation target here. Delegate to the reference backend.
    internal func factorial(_ n: Int) -> Int? { reference.factorial(n) }
    internal func combinations(n: Int, r: Int) -> Int? { reference.combinations(n: n, r: r) }
    internal func permutations(n: Int, r: Int) -> Int? { reference.permutations(n: n, r: r) }
}
