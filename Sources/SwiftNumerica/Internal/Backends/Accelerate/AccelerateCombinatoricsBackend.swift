internal struct AccelerateCombinatoricsBackend: CombinatoricsBackend {
    private let reference = PureSwiftCombinatoricsBackend()

    // TODO: Replace delegation with Accelerate-backed implementations if this
    // domain becomes a useful acceleration target.
    internal func factorial(_ n: Int) -> Int? { reference.factorial(n) }
    internal func combinations(n: Int, r: Int) -> Int? { reference.combinations(n: n, r: r) }
    internal func permutations(n: Int, r: Int) -> Int? { reference.permutations(n: n, r: r) }
}
