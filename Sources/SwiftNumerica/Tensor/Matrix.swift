/// A convenience value type for two-dimensional numerical tensors.
public struct Matrix: Equatable, Sendable {
    /// The underlying tensor storage.
    public var tensor: Tensor<Double>

    /// Creates a matrix.
    ///
    /// - Parameter rows: Row-major matrix values.
    /// - Returns: `nil` when rows have inconsistent lengths.
    public init?(_ rows: [[Double]]) {
        guard let tensor = Tensor<Double>.matrix(rows) else { return nil }
        self.tensor = tensor
    }
}
