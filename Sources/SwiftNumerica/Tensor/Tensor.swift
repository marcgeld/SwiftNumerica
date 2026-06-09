/// A dense value-type tensor.
///
/// `Tensor<Double>` is the fundamental numerical abstraction in SwiftNumerica.
/// Higher-level statistics, profiling, probability, and analysis APIs operate on
/// tensors rather than tabular data structures.
public struct Tensor<Scalar: Sendable>: Equatable, Sendable where Scalar: Equatable {
    /// The tensor shape.
    public let shape: Shape

    /// The tensor values in row-major storage order.
    public var values: [Scalar]

    /// The tensor rank.
    public var rank: Int {
        shape.rank
    }

    /// The number of scalar elements in the tensor.
    public var count: Int {
        values.count
    }

    /// Creates a tensor with row-major values and a shape.
    ///
    /// - Parameters:
    ///   - values: Row-major scalar values.
    ///   - shape: The tensor shape.
    /// - Returns: `nil` when the values do not match the shape.
    public init?(_ values: [Scalar], shape: Shape) {
        guard values.count == shape.count else { return nil }
        self.values = values
        self.shape = shape
    }

    /// Returns a tensor with the same row-major storage and a new shape.
    ///
    /// Reshaping never reorders values. The requested shape must preserve the
    /// total element count. Use an empty shape (`[]`) for scalar tensors.
    ///
    /// - Parameter newShape: The requested tensor dimensions.
    /// - Returns: A tensor with the requested shape and the same values.
    /// - Throws: `TensorError.invalidShape` when a dimension is not positive,
    ///   or `TensorError.incompatibleShape` when the element count changes.
    public func reshaped(to newShape: [Int]) throws -> Tensor<Scalar> {
        guard newShape.allSatisfy({ $0 > 0 }) else {
            throw TensorError.invalidShape
        }

        let newCount = newShape.reduce(1, *)
        guard newCount == values.count else {
            throw TensorError.incompatibleShape
        }

        guard let shape = Shape(newShape),
              let tensor = Tensor(values, shape: shape) else {
            throw TensorError.invalidShape
        }

        return tensor
    }
}

public extension Tensor where Scalar == Double {
    /// Creates a scalar tensor.
    ///
    /// - Parameter value: The scalar value.
    /// - Returns: A rank-0 tensor.
    static func scalar(_ value: Double) -> Tensor<Double> {
        Tensor<Double>([value], shape: Shape([])!)!
    }

    /// Creates a vector tensor.
    ///
    /// - Parameter values: The vector values.
    /// - Returns: A rank-1 tensor.
    static func vector(_ values: [Double]) -> Tensor<Double> {
        Tensor<Double>(values, shape: Shape([values.count])!)!
    }

    /// Creates a matrix tensor.
    ///
    /// - Parameter rows: Row-major matrix values.
    /// - Returns: A rank-2 tensor, or `nil` when rows have inconsistent lengths.
    static func matrix(_ rows: [[Double]]) -> Tensor<Double>? {
        guard let columnCount = rows.first?.count else {
            return Tensor<Double>([], shape: Shape([0, 0])!)
        }
        guard rows.allSatisfy({ $0.count == columnCount }) else { return nil }
        return Tensor<Double>(rows.flatMap { $0 }, shape: Shape([rows.count, columnCount])!)
    }

    /// Creates a tensor from row-major values and dimensions.
    ///
    /// - Parameters:
    ///   - values: Row-major scalar values.
    ///   - dimensions: Non-negative dimension sizes.
    /// - Returns: A tensor, or `nil` when the shape is invalid.
    static func multidimensional(_ values: [Double], dimensions: [Int]) -> Tensor<Double>? {
        guard let shape = Shape(dimensions) else { return nil }
        return Tensor<Double>(values, shape: shape)
    }
}
