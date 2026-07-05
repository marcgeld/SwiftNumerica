#if canImport(Accelerate)
import Accelerate
#endif

internal struct AccelerateLinearAlgebraBackend: LinearAlgebraBackend {
    private let reference = PureSwiftLinearAlgebraBackend()

    internal func determinant(_ matrix: Matrix) -> Double? {
        reference.determinant(matrix)
    }

    internal func inverse(_ matrix: Matrix) -> Matrix? {
        reference.inverse(matrix)
    }

    internal func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
        reference.solve(matrix, vector)
    }

    internal func eigenvalues(_ matrix: Matrix) -> [Double]? {
        reference.eigenvalues(matrix)
    }

    internal func eigenvectors(_ matrix: Matrix) -> Matrix? {
        reference.eigenvectors(matrix)
    }
}
