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
        guard matrix.isSquare else { return nil }
        let dimension = matrix.rowCount
        var columns: [[Double]] = []

        for column in 0..<dimension {
            var basis = Array(repeating: 0.0, count: dimension)
            basis[column] = 1
            guard let solution = LinearSystemMath.solve(matrix.rows, basis) else { return nil }
            columns.append(solution)
        }

        let rows = (0..<dimension).map { row in
            columns.map { $0[row] }
        }
        return Matrix(rows)
    }

    internal func solve(_ matrix: Matrix, _ vector: Vector) -> Vector? {
        guard matrix.isSquare,
              matrix.rowCount == vector.count,
              let solution = LinearSystemMath.solve(matrix.rows, vector.values) else { return nil }
        return Vector(solution)
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
        var diagonalized = matrix.rows
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

    private func isSymmetric(_ matrix: Matrix) -> Bool {
        for row in 0..<matrix.rowCount {
            for column in (row + 1)..<matrix.columnCount {
                if Swift.abs(matrix[row, column] - matrix[column, row]) > 1e-10 {
                    return false
                }
            }
        }
        return true
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
