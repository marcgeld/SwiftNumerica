internal protocol LinearAlgebraBackend: Sendable {
    func determinant(_ matrix: Matrix) -> Double?
    func inverse(_ matrix: Matrix) -> Matrix?
    func solve(_ matrix: Matrix, _ vector: Vector) -> Vector?
    func eigenvalues(_ matrix: Matrix) -> [Double]?
    func eigenvectors(_ matrix: Matrix) -> Matrix?
}
