/// A convenience value type for one-dimensional numerical tensors.
public struct Vector: Equatable, Sendable {
    /// The underlying tensor storage.
    public var tensor: Tensor<Double>

    /// The vector values.
    public var values: [Double] {
        tensor.values
    }

    /// Creates a vector.
    ///
    /// - Parameter values: The vector values.
    public init(_ values: [Double]) {
        self.tensor = .vector(values)
    }
}
