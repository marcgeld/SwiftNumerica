/// A convenience value type for two-dimensional numerical tensors.
public struct Matrix: Equatable, Sendable {
    /// The underlying tensor storage.
    public var tensor: Tensor<Double>

    /// The matrix values in row-major storage order.
    public var values: [Double] {
        tensor.values
    }

    /// The number of matrix rows.
    public var rowCount: Int {
        tensor.shape.dimensions[0]
    }

    /// The number of matrix columns.
    public var columnCount: Int {
        tensor.shape.dimensions[1]
    }

    /// The matrix rows.
    public var rows: [[Double]] {
        (0..<rowCount).map { row in
            let start = row * columnCount
            return Array(values[start..<(start + columnCount)])
        }
    }

    /// Returns whether the matrix is square.
    public var isSquare: Bool {
        rowCount == columnCount
    }

    /// Creates a matrix.
    ///
    /// - Parameter rows: Row-major matrix values.
    /// - Returns: `nil` when rows have inconsistent lengths.
    public init?(_ rows: [[Double]]) {
        guard let tensor = Tensor<Double>.matrix(rows) else { return nil }
        self.tensor = tensor
    }

    /// Creates a matrix from row-major values and dimensions.
    public init?(values: [Double], rows: Int, columns: Int) {
        guard rows > 0,
              columns > 0,
              values.count == rows * columns,
              let shape = Shape([rows, columns]),
              let tensor = Tensor<Double>(values, shape: shape) else { return nil }
        self.tensor = tensor
    }

    /// Creates a matrix from an existing rank-2 tensor.
    public init?(_ tensor: Tensor<Double>) {
        guard tensor.rank == 2 else { return nil }
        self.tensor = tensor
    }

    /// Accesses a matrix element.
    public subscript(row: Int, column: Int) -> Double {
        values[row * columnCount + column]
    }
}
