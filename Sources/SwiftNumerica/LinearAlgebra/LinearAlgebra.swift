public extension Numerica.LinearAlgebra {
    /// Computes the determinant of a square matrix.
    static func determinant(_ matrix: Matrix) -> Double? {
        try? BackendResolver.linearAlgebraBackend().determinant(matrix)
    }

    /// Computes the inverse of a square matrix.
    static func inverse(_ matrix: Matrix) -> Matrix? {
        try? BackendResolver.linearAlgebraBackend().inverse(matrix)
    }

    /// Solves `matrix * x = vector`.
    static func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
        try? BackendResolver.linearAlgebraBackend().solve(matrix, vector)
    }

    /// Computes real eigenvalues for a symmetric matrix.
    ///
    /// Returns `nil` for non-square or non-symmetric matrices.
    static func eigenvalues(_ matrix: Matrix) -> [Double]? {
        try? BackendResolver.linearAlgebraBackend().eigenvalues(matrix)
    }

    /// Computes column-wise real eigenvectors for a symmetric matrix.
    ///
    /// Returns `nil` for non-square or non-symmetric matrices. Eigenvectors are
    /// returned as columns ordered to match `eigenvalues(_:)`.
    static func eigenvectors(_ matrix: Matrix) -> Matrix? {
        try? BackendResolver.linearAlgebraBackend().eigenvectors(matrix)
    }
}

public extension Matrix {
    /// Computes the determinant of a square matrix.
    func determinant() -> Double? {
        Numerica.LinearAlgebra.determinant(self)
    }

    /// Computes the inverse of a square matrix.
    func inverse() -> Matrix? {
        Numerica.LinearAlgebra.inverse(self)
    }

    /// Solves `self * x = vector`.
    func solve(_ vector: Vector) -> Vector? {
        Numerica.LinearAlgebra.solve(self, vector)
    }

    /// Computes real eigenvalues for a symmetric matrix.
    func eigenvalues() -> [Double]? {
        Numerica.LinearAlgebra.eigenvalues(self)
    }

    /// Computes column-wise real eigenvectors for a symmetric matrix.
    func eigenvectors() -> Matrix? {
        Numerica.LinearAlgebra.eigenvectors(self)
    }
}

/// Computes the determinant of a square matrix.
public func determinant(_ matrix: Matrix) -> Double? {
    Numerica.LinearAlgebra.determinant(matrix)
}

/// Computes the inverse of a square matrix.
public func inverse(_ matrix: Matrix) -> Matrix? {
    Numerica.LinearAlgebra.inverse(matrix)
}

/// Solves `matrix * x = vector`.
public func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
    Numerica.LinearAlgebra.solve(matrix, vector)
}

/// Computes real eigenvalues for a symmetric matrix.
public func eigenvalues(_ matrix: Matrix) -> [Double]? {
    Numerica.LinearAlgebra.eigenvalues(matrix)
}

/// Computes column-wise real eigenvectors for a symmetric matrix.
public func eigenvectors(_ matrix: Matrix) -> Matrix? {
    Numerica.LinearAlgebra.eigenvectors(matrix)
}
