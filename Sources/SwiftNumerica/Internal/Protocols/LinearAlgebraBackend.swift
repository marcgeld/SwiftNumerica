internal protocol LinearAlgebraBackend: Sendable {
    func determinant(_ matrix: Matrix) -> Double?
    func inverse(_ matrix: Matrix) -> Matrix?
    func solve(_ matrix: Matrix, _ vector: Vector) -> Vector?
    func solve(_ matrix: Matrix, _ rightHandSide: Matrix) -> Matrix?
    func choleskyDecomposition(_ matrix: Matrix) -> Matrix?
    func eigenvalues(_ matrix: Matrix) -> [Double]?
    func eigenvectors(_ matrix: Matrix) -> Matrix?
}
