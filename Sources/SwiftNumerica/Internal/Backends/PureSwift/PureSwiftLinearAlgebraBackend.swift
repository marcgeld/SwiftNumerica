import Foundation

internal struct PureSwiftLinearAlgebraBackend: LinearAlgebraBackend {
    internal func determinant(_ matrix: Matrix) -> Double? {
        guard matrix.isSquare else { return nil }
        let dimension = matrix.rowCount
        var rows = matrix.rows
        var sign = 1.0
        var determinant = 1.0

        for column in 0..<dimension {
            var pivotRow = column
            var pivotMagnitude = Swift.abs(rows[column][column])
            for row in (column + 1)..<dimension {
                let magnitude = Swift.abs(rows[row][column])
                if magnitude > pivotMagnitude {
                    pivotMagnitude = magnitude
                    pivotRow = row
                }
            }

            guard pivotMagnitude > 1e-12 else { return 0 }
            if pivotRow != column {
                rows.swapAt(pivotRow, column)
                sign *= -1
            }

            let pivot = rows[column][column]
            determinant *= pivot
            for row in (column + 1)..<dimension {
                let factor = rows[row][column] / pivot
                for entry in column..<dimension {
                    rows[row][entry] -= factor * rows[column][entry]
                }
            }
        }

        return sign * determinant
    }

    internal func inverse(_ matrix: Matrix) -> Matrix? {
        guard matrix.isSquare,
              let inverted = LinearSystemMath.invert(matrix.rows) else { return nil }
        return Matrix(inverted)
    }

    internal func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
        guard matrix.isSquare,
              matrix.rowCount == vector.count,
              let solution = LinearSystemMath.solve(matrix.rows, vector.values) else { return nil }
        return Vector(solution)
    }

    internal func solve(_ matrix: Matrix, _ rightHandSide: Matrix) -> Matrix? {
        guard matrix.isSquare,
              matrix.rowCount == rightHandSide.rowCount else { return nil }

        let coefficientRows = matrix.rows
        var solutionColumns: [[Double]] = []
        for column in 0..<rightHandSide.columnCount {
            let target = (0..<rightHandSide.rowCount).map { rightHandSide[$0, column] }
            guard let solution = LinearSystemMath.solve(coefficientRows, target) else { return nil }
            solutionColumns.append(solution)
        }

        let rows = (0..<matrix.rowCount).map { row in
            solutionColumns.map { $0[row] }
        }
        return Matrix(rows)
    }

    internal func choleskyDecomposition(_ matrix: Matrix) -> Matrix? {
        guard matrix.isSquare,
              matrix.rowCount > 0,
              isSymmetric(matrix) else { return nil }

        let dimension = matrix.rowCount
        let source = symmetrizedRows(matrix)
        var factor = Array(repeating: Array(repeating: 0.0, count: dimension), count: dimension)

        for row in 0..<dimension {
            for column in 0...row {
                var sum = 0.0
                for index in 0..<column {
                    sum += factor[row][index] * factor[column][index]
                }

                if row == column {
                    let diagonal = source[row][row] - sum
                    guard diagonal > 0 else { return nil }
                    factor[row][column] = diagonal.squareRoot()
                } else {
                    factor[row][column] = (source[row][column] - sum) / factor[column][column]
                }
            }
        }

        return Matrix(factor)
    }

    internal func eigenvalues(_ matrix: Matrix) -> [Double]? {
        jacobiEigenDecomposition(matrix)?.values
    }

    internal func eigenvectors(_ matrix: Matrix) -> Matrix? {
        jacobiEigenDecomposition(matrix)?.vectors
    }

    private func jacobiEigenDecomposition(_ matrix: Matrix) -> (values: [Double], vectors: Matrix)? {
        guard matrix.isSquare,
              matrix.rowCount > 0,
              isSymmetric(matrix) else { return nil }

        let dimension = matrix.rowCount
        var diagonalized = symmetrizedRows(matrix)
        var eigenvectors = identityRows(dimension)
        let tolerance = 1e-12
        let maxIterations = Swift.max(50, dimension * dimension * 50)

        for _ in 0..<maxIterations {
            let pivot = largestOffDiagonalElement(in: diagonalized)
            guard pivot.magnitude > tolerance else {
                return sortedEigenDecomposition(values: diagonalizedDiagonal(diagonalized), vectors: eigenvectors)
            }

            let row = pivot.row
            let column = pivot.column
            let difference = diagonalized[column][column] - diagonalized[row][row]
            let angle = difference == 0
                ? Double.pi / 4
                : 0.5 * Foundation.atan2(2 * diagonalized[row][column], difference)
            let cosine = Foundation.cos(angle)
            let sine = Foundation.sin(angle)

            for index in 0..<dimension where index != row && index != column {
                let rowValue = diagonalized[index][row]
                let columnValue = diagonalized[index][column]
                diagonalized[index][row] = cosine * rowValue - sine * columnValue
                diagonalized[row][index] = diagonalized[index][row]
                diagonalized[index][column] = sine * rowValue + cosine * columnValue
                diagonalized[column][index] = diagonalized[index][column]
            }

            let rowDiagonal = diagonalized[row][row]
            let columnDiagonal = diagonalized[column][column]
            let offDiagonal = diagonalized[row][column]
            diagonalized[row][row] = cosine * cosine * rowDiagonal
                - 2 * sine * cosine * offDiagonal
                + sine * sine * columnDiagonal
            diagonalized[column][column] = sine * sine * rowDiagonal
                + 2 * sine * cosine * offDiagonal
                + cosine * cosine * columnDiagonal
            diagonalized[row][column] = 0
            diagonalized[column][row] = 0

            for index in 0..<dimension {
                let rowValue = eigenvectors[index][row]
                let columnValue = eigenvectors[index][column]
                eigenvectors[index][row] = cosine * rowValue - sine * columnValue
                eigenvectors[index][column] = sine * rowValue + cosine * columnValue
            }
        }

        return sortedEigenDecomposition(values: diagonalizedDiagonal(diagonalized), vectors: eigenvectors)
    }

    internal func isSymmetric(_ matrix: Matrix) -> Bool {
        for row in 0..<matrix.rowCount {
            for column in (row + 1)..<matrix.columnCount {
                let upper = matrix[row, column]
                let lower = matrix[column, row]
                // The relative 1e-6 tolerance accepts asymmetry from
                // single-precision-sourced data (about 1e-7) while rejecting
                // genuinely nonsymmetric matrices. Decompositions symmetrize
                // accepted inputs as (A + At) / 2 before factoring, so the
                // residual asymmetry never reaches the numerics.
                let scale = Swift.max(Swift.abs(upper), Swift.abs(lower), 1)
                if Swift.abs(upper - lower) > 1e-6 * scale {
                    return false
                }
            }
        }
        return true
    }

    /// Returns `(A + At) / 2` as row arrays, canceling the residual asymmetry
    /// that `isSymmetric` tolerates.
    internal func symmetrizedRows(_ matrix: Matrix) -> [[Double]] {
        (0..<matrix.rowCount).map { row in
            (0..<matrix.columnCount).map { column in
                (matrix[row, column] + matrix[column, row]) / 2
            }
        }
    }

    private func largestOffDiagonalElement(in rows: [[Double]]) -> (row: Int, column: Int, magnitude: Double) {
        var pivot = (row: 0, column: 0, magnitude: 0.0)
        for row in 0..<rows.count {
            for column in (row + 1)..<rows.count {
                let magnitude = Swift.abs(rows[row][column])
                if magnitude > pivot.magnitude {
                    pivot = (row, column, magnitude)
                }
            }
        }
        return pivot
    }

    private func identityRows(_ dimension: Int) -> [[Double]] {
        (0..<dimension).map { row in
            (0..<dimension).map { column in row == column ? 1 : 0 }
        }
    }

    private func diagonalizedDiagonal(_ rows: [[Double]]) -> [Double] {
        rows.indices.map { rows[$0][$0] }
    }

    private func sortedEigenDecomposition(values: [Double], vectors: [[Double]]) -> (values: [Double], vectors: Matrix)? {
        let order = values.indices.sorted { values[$0] > values[$1] }
        let sortedValues = order.map { values[$0] }
        let sortedVectors = vectors.map { row in
            order.map { row[$0] }
        }
        guard let matrix = Matrix(sortedVectors) else { return nil }
        return (sortedValues, matrix)
    }
}
