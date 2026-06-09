/// The dimensions of a tensor.
public struct Shape: Equatable, Sendable {
    /// The size of each tensor axis.
    public let dimensions: [Int]

    /// The number of axes in the shape.
    public var rank: Int {
        dimensions.count
    }

    /// The number of scalar elements described by the shape.
    public var count: Int {
        dimensions.reduce(1, *)
    }

    /// Creates a shape from dimensions.
    ///
    /// Scalar tensors use an empty shape, vectors use one dimension, matrices
    /// use two dimensions, and higher-rank tensors use three or more dimensions.
    ///
    /// - Parameter dimensions: Non-negative dimension sizes.
    public init?(_ dimensions: [Int]) {
        guard dimensions.allSatisfy({ $0 >= 0 }) else { return nil }
        self.dimensions = dimensions
    }
}

public extension Shape {
    /// Returns `true` when this shape has the same dimensions as `dimensions`.
    static func == (lhs: Shape, rhs: [Int]) -> Bool {
        lhs.dimensions == rhs
    }

    /// Returns `true` when `dimensions` has the same values as this shape.
    static func == (lhs: [Int], rhs: Shape) -> Bool {
        lhs == rhs.dimensions
    }
}
