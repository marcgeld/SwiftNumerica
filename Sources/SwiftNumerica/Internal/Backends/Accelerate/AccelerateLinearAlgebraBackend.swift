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
            dimension, 1, factored.values, factored.pivots, &solution
        ) == 0 else { return nil }
        return Vector(solution)
        #else
        return reference.solve(matrix, vector)
        #endif
    }

    internal func solve(_ matrix: Matrix, _ rightHandSide: Matrix) -> Matrix? {
        guard matrix.isSquare, matrix.rowCount == rightHandSide.rowCount else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        let solutionColumns = rightHandSide.columnCount
        guard let factored = luFactorization(matrix.values, dimension: dimension) else { return nil }

        // dgetrs expects the right-hand sides in column-major layout.
        var columnMajor = [Double](repeating: 0, count: dimension * solutionColumns)
        for row in 0..<dimension {
            for column in 0..<solutionColumns {
                columnMajor[column * dimension + row] = rightHandSide[row, column]
            }
        }
        guard sn_dgetrs_transposed(
            dimension, solutionColumns, factored.values, factored.pivots, &columnMajor
        ) == 0 else { return nil }

        var rowMajor = [Double](repeating: 0, count: dimension * solutionColumns)
        for row in 0..<dimension {
            for column in 0..<solutionColumns {
                rowMajor[row * solutionColumns + column] = columnMajor[column * dimension + row]
            }
        }
        return Matrix(values: rowMajor, rows: dimension, columns: solutionColumns)
        #else
        return reference.solve(matrix, rightHandSide)
        #endif
    }

    internal func choleskyDecomposition(_ matrix: Matrix) -> Matrix? {
        guard matrix.isSquare,
              matrix.rowCount > 0,
              reference.isSymmetric(matrix) else { return nil }

        #if canImport(Accelerate)
        let dimension = matrix.rowCount
        var buffer = symmetrizedValues(matrix)
        guard sn_dpotrf(dimension, &buffer) == 0 else { return nil }

        // dpotrf leaves the unfactored triangle untouched; zero the row-major
        // strict upper triangle so the result is a clean lower-triangular L
        // with A = L * Lt.
        for row in 0..<dimension {
            for column in (row + 1)..<dimension {
                buffer[row * dimension + column] = 0
            }
        }
        return Matrix(values: buffer, rows: dimension, columns: dimension)
        #else
        return reference.choleskyDecomposition(matrix)
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
        var buffer = symmetrizedValues(matrix)
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
    /// Returns `(A + At) / 2` as a flat row-major buffer, matching the
    /// reference backend's symmetrization of accepted near-symmetric inputs.
    private func symmetrizedValues(_ matrix: Matrix) -> [Double] {
        let dimension = matrix.rowCount
        var values = [Double](repeating: 0, count: dimension * dimension)
        for row in 0..<dimension {
            for column in 0..<dimension {
                values[row * dimension + column] = (matrix[row, column] + matrix[column, row]) / 2
            }
        }
        return values
    }

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
