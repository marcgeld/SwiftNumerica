internal enum LinearSystemMath {
    /// Solves `matrix * x = vector` with Gaussian elimination and partial
    /// pivoting. Returns `nil` when the system is singular within a `1e-12`
    /// pivot tolerance.
    internal static func solve(_ matrix: [[Double]], _ vector: [Double]) -> [Double]? {
        let dimension = vector.count
        guard matrix.count == dimension,
              matrix.allSatisfy({ $0.count == dimension }) else { return nil }

        var augmented = matrix.enumerated().map { rowIndex, row in
            row + [vector[rowIndex]]
        }

        for column in 0..<dimension {
            var pivotRow = column
            var pivotMagnitude = Swift.abs(augmented[column][column])
            for row in (column + 1)..<dimension {
                let magnitude = Swift.abs(augmented[row][column])
                if magnitude > pivotMagnitude {
                    pivotMagnitude = magnitude
                    pivotRow = row
                }
            }

            guard pivotMagnitude > 1e-12 else { return nil }
            if pivotRow != column {
                augmented.swapAt(pivotRow, column)
            }

            let pivot = augmented[column][column]
            for entry in column...dimension {
                augmented[column][entry] /= pivot
            }

            for row in 0..<dimension where row != column {
                let factor = augmented[row][column]
                for entry in column...dimension {
                    augmented[row][entry] -= factor * augmented[column][entry]
                }
            }
        }

        return augmented.map { $0[dimension] }
    }
}
