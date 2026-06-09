internal protocol CombinatoricsBackend: Sendable {
    func factorial(_ n: Int) -> Int?
    func combinations(n: Int, r: Int) -> Int?
    func permutations(n: Int, r: Int) -> Int?
}
