/// A convenience value type for one-dimensional numerical tensors.
public struct Vector: Equatable, Sendable {
    /// The underlying tensor storage.
    public var tensor: Tensor<Double>

    /// The vector values.
    public var values: [Double] {
        tensor.values
    }

    /// The number of vector elements.
    public var count: Int {
        values.count
    }

    /// Creates a vector.
    ///
    /// - Parameter values: The vector values.
    public init(_ values: [Double]) {
        self.tensor = .vector(values)
    }

    /// Creates a vector from an existing rank-1 tensor.
    ///
    /// - Parameter tensor: A rank-1 tensor.
    public init?(_ tensor: Tensor<Double>) {
        guard tensor.rank == 1 else { return nil }
        self.tensor = tensor
    }

    /// Accesses a vector element.
    public subscript(index: Int) -> Double {
        values[index]
    }
}
