import MLX
import SwiftNumerica

public extension Tensor where Scalar == Double {
    /// Creates a tensor from an MLX array.
    ///
    /// The MLX array is evaluated and copied into SwiftNumerica row-major
    /// storage as `Double` values.
    init?(mlxArray array: MLXArray) {
        guard let shape = Shape(array.shape) else { return nil }
        self.init(array.asArray(Double.self), shape: shape)
    }

    /// Creates an MLX array from the tensor values and shape.
    ///
    /// The values are copied in SwiftNumerica's row-major storage order. This
    /// adapter intentionally lives outside the SwiftNumerica core package so
    /// MLX remains an opt-in dependency.
    func mlxArray() -> MLXArray {
        if rank == 0, let value = values.first {
            return MLXArray(value)
        }

        return MLXArray(values, shape.dimensions)
    }
}

public extension MLXArray {
    /// Creates a SwiftNumerica tensor from this MLX array.
    ///
    /// The MLX array is evaluated and copied into SwiftNumerica row-major
    /// storage as `Double` values.
    func tensorDouble() -> Tensor<Double>? {
        Tensor<Double>(mlxArray: self)
    }
}
