import Foundation

public extension Numerica.LinearAlgebra {
    /// Computes the determinant of a square matrix.
    static func determinant(_ matrix: Matrix) throws -> Double? {
        try BackendResolver.linearAlgebraBackend().determinant(matrix)
    }

    /// Computes the inverse of a square matrix.
    static func inverse(_ matrix: Matrix) throws -> Matrix? {
        try BackendResolver.linearAlgebraBackend().inverse(matrix)
    }

    /// Solves `matrix * x = vector`.
    static func solve(_ matrix: Matrix, _ vector: Vector) throws -> Vector? {
        try BackendResolver.linearAlgebraBackend().solve(matrix, vector)
    }

    /// Solves `matrix * X = rightHandSide` for a matrix of right-hand-side
    /// columns. Solving is preferred over forming an explicit inverse.
    static func solve(_ matrix: Matrix, _ rightHandSide: Matrix) throws -> Matrix? {
        try BackendResolver.linearAlgebraBackend().solve(matrix, rightHandSide)
    }

    /// Computes the lower-triangular Cholesky factor `L` with
    /// `matrix = L * Lt` for a symmetric positive definite matrix.
    ///
    /// Returns `nil` for non-square, non-symmetric, or non-positive-definite
    /// matrices. Near-symmetric inputs within a relative `1e-6` tolerance are
    /// symmetrized internally.
    static func choleskyDecomposition(_ matrix: Matrix) throws -> Matrix? {
        try BackendResolver.linearAlgebraBackend().choleskyDecomposition(matrix)
    }

    /// Computes the natural logarithm of the determinant of a symmetric
    /// positive definite matrix through its Cholesky factorization, which
    /// stays finite where the determinant itself would overflow or underflow.
    ///
    /// Returns `nil` for non-square, non-symmetric, or non-positive-definite
    /// matrices.
    static func logDeterminant(_ matrix: Matrix) throws -> Double? {
        guard let factor = try choleskyDecomposition(matrix) else { return nil }
        var sum = 0.0
        for index in 0..<factor.rowCount {
            sum += Foundation.log(factor[index, index])
        }
        return 2 * sum
    }

    /// Computes real eigenvalues for a symmetric matrix.
    ///
    /// Returns `nil` for non-square or non-symmetric matrices.
    static func eigenvalues(_ matrix: Matrix) throws -> [Double]? {
        try BackendResolver.linearAlgebraBackend().eigenvalues(matrix)
    }

    /// Computes column-wise real eigenvectors for a symmetric matrix.
    ///
    /// Returns `nil` for non-square or non-symmetric matrices. Eigenvectors are
    /// returned as columns ordered to match `eigenvalues(_:)`.
    static func eigenvectors(_ matrix: Matrix) throws -> Matrix? {
        try BackendResolver.linearAlgebraBackend().eigenvectors(matrix)
    }
}

public extension Matrix {
    /// Computes the determinant of a square matrix.
    func determinant() throws -> Double? {
        try Numerica.LinearAlgebra.determinant(self)
    }

    /// Computes the inverse of a square matrix.
    func inverse() throws -> Matrix? {
        try Numerica.LinearAlgebra.inverse(self)
    }

    /// Solves `self * x = vector`.
    func solve(_ vector: Vector) throws -> Vector? {
        try Numerica.LinearAlgebra.solve(self, vector)
    }

    /// Solves `self * X = rightHandSide` for a matrix of right-hand-side columns.
    func solve(_ rightHandSide: Matrix) throws -> Matrix? {
        try Numerica.LinearAlgebra.solve(self, rightHandSide)
    }

    /// Computes the lower-triangular Cholesky factor of a symmetric positive
    /// definite matrix.
    func choleskyDecomposition() throws -> Matrix? {
        try Numerica.LinearAlgebra.choleskyDecomposition(self)
    }

    /// Computes the log-determinant of a symmetric positive definite matrix.
    func logDeterminant() throws -> Double? {
        try Numerica.LinearAlgebra.logDeterminant(self)
    }

    /// Computes real eigenvalues for a symmetric matrix.
    func eigenvalues() throws -> [Double]? {
        try Numerica.LinearAlgebra.eigenvalues(self)
    }

    /// Computes column-wise real eigenvectors for a symmetric matrix.
    func eigenvectors() throws -> Matrix? {
        try Numerica.LinearAlgebra.eigenvectors(self)
    }
}

/// Computes the determinant of a square matrix.
public func determinant(_ matrix: Matrix) throws -> Double? {
    try Numerica.LinearAlgebra.determinant(matrix)
}

/// Computes the inverse of a square matrix.
public func inverse(_ matrix: Matrix) throws -> Matrix? {
    try Numerica.LinearAlgebra.inverse(matrix)
}

/// Solves `matrix * x = vector`.
public func solve(_ matrix: Matrix, _ vector: Vector) throws -> Vector? {
    try Numerica.LinearAlgebra.solve(matrix, vector)
}

/// Solves `matrix * X = rightHandSide` for a matrix of right-hand-side columns.
public func solve(_ matrix: Matrix, _ rightHandSide: Matrix) throws -> Matrix? {
    try Numerica.LinearAlgebra.solve(matrix, rightHandSide)
}

/// Computes the lower-triangular Cholesky factor of a symmetric positive
/// definite matrix.
public func choleskyDecomposition(_ matrix: Matrix) throws -> Matrix? {
    try Numerica.LinearAlgebra.choleskyDecomposition(matrix)
}

/// Computes the log-determinant of a symmetric positive definite matrix.
public func logDeterminant(_ matrix: Matrix) throws -> Double? {
    try Numerica.LinearAlgebra.logDeterminant(matrix)
}

/// Computes real eigenvalues for a symmetric matrix.
public func eigenvalues(_ matrix: Matrix) throws -> [Double]? {
    try Numerica.LinearAlgebra.eigenvalues(matrix)
}

/// Computes column-wise real eigenvectors for a symmetric matrix.
public func eigenvectors(_ matrix: Matrix) throws -> Matrix? {
    try Numerica.LinearAlgebra.eigenvectors(matrix)
}
