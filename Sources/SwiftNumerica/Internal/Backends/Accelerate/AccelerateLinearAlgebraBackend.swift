#if canImport(Accelerate)
import Accelerate
import CNumericaLAPACK
#endif

/// LAPACK-backed linear algebra. Row-major buffers are passed straight to
/// column-major LAPACK, which therefore factors the transpose; determinants
/// are transpose-invariant, transposed inverses read back as row-major
/// inverses, and solves request the transposed system, so no explicit
/// transposition is needed anywhere.
internal struct AccelerateLinearAlgebraBackend: LinearAlgebraBackend {
    private let reference = PureSwiftLinearAlgebraBackend()

    /// Matches the pivot tolerance used by `LinearSystemMath` so both
    /// backends agree on which matrices count as singular.
    private static let singularityTolerance = 1e-12

    internal func determinant(_ matrix: Matrix) -> Double? {
        guard matrix.isSquare else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        var factored = matrix.values
        var pivots = [Int](repeating: 0, count: dimension)
        let status = sn_dgetrf(dimension, &factored, &pivots)
        if status > 0 {
            return 0
        }
        guard status == 0 else { return reference.determinant(matrix) }

        var determinant = 1.0
        for index in 0..<dimension {
            let diagonal = factored[index * dimension + index]
            guard Swift.abs(diagonal) > Self.singularityTolerance else { return 0 }
            determinant *= diagonal
            if pivots[index] != index + 1 {
                determinant.negate()
            }
        }
        return determinant
        #else
        return reference.determinant(matrix)
        #endif
    }

    internal func inverse(_ matrix: Matrix) -> Matrix? {
        guard matrix.isSquare else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        guard var factored = luFactorization(matrix.values, dimension: dimension) else { return nil }
        guard sn_dgetri(dimension, &factored.values, factored.pivots) == 0 else { return nil }
        return Matrix(values: factored.values, rows: dimension, columns: dimension)
        #else
        return reference.inverse(matrix)
        #endif
    }

    internal func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
        guard matrix.isSquare, matrix.rowCount == vector.count else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        guard let factored = luFactorization(matrix.values, dimension: dimension) else { return nil }
        var solution = vector.values
        guard sn_dgetrs_transposed(
            dimension, factored.values, factored.pivots, &solution
        ) == 0 else { return nil }
        return Vector(solution)
        #else
        return reference.solve(matrix, vector)
        #endif
    }

    internal func eigenvalues(_ matrix: Matrix) -> [Double]? {
        symmetricEigenDecomposition(matrix, computeVectors: false)?.values
    }

    internal func eigenvectors(_ matrix: Matrix) -> Matrix? {
        symmetricEigenDecomposition(matrix, computeVectors: true)?.vectors
    }

    private func symmetricEigenDecomposition(
        _ matrix: Matrix,
        computeVectors: Bool
    ) -> (values: [Double], vectors: Matrix?)? {
        guard matrix.isSquare,
              matrix.rowCount > 0,
              reference.isSymmetric(matrix) else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        var buffer = matrix.values
        var ascendingValues = [Double](repeating: 0, count: dimension)
        guard sn_dsyev(
            dimension, &buffer, &ascendingValues, computeVectors ? 1 : 0
        ) == 0 else { return nil }

        // dsyev orders eigenvalues ascending; the reference orders descending.
        let values = Array(ascendingValues.reversed())
        guard computeVectors else { return (values, nil) }

        // Eigenvector j is column j of the column-major result, which is row j
        // of the row-major buffer. Reverse the column order to match the
        // descending eigenvalues.
        let rows = (0..<dimension).map { row in
            (0..<dimension).map { column in
                buffer[(dimension - 1 - column) * dimension + row]
            }
        }
        guard let vectors = Matrix(rows) else { return nil }
        return (values, vectors)
        #else
        guard let values = reference.eigenvalues(matrix) else { return nil }
        return (values, computeVectors ? reference.eigenvectors(matrix) : nil)
        #endif
    }

    #if canImport(Accelerate)
    /// Factors the row-major values with `dgetrf` and rejects matrices whose
    /// pivots fall within the shared singularity tolerance, mirroring the
    /// PureSwift reference behavior of returning `nil` for singular systems.
    private func luFactorization(
        _ values: [Double],
        dimension: Int
    ) -> (values: [Double], pivots: [Int])? {
        var factored = values
        var pivots = [Int](repeating: 0, count: dimension)
        guard sn_dgetrf(dimension, &factored, &pivots) == 0 else { return nil }

        for index in 0..<dimension
        where Swift.abs(factored[index * dimension + index]) <= Self.singularityTolerance {
            return nil
        }
        return (factored, pivots)
    }
    #endif
}
