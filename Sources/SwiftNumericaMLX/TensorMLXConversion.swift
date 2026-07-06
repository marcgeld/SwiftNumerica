// This module only has content when the package is built with the `MLX`
// trait enabled; without it, the MLX product is not a dependency and the
// module compiles to an empty library.
#if canImport(MLX)
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
    /// conversion lives behind the `MLX` package trait so MLX remains an
    /// opt-in dependency.
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

public extension Matrix {
    /// Creates a matrix from a rank-2 MLX array.
    init?(mlxArray array: MLXArray) {
        guard array.ndim == 2,
              let tensor = Tensor<Double>(mlxArray: array) else { return nil }
        self.init(tensor)
    }

    /// Creates an MLX array from the matrix values and shape.
    func mlxArray() -> MLXArray {
        tensor.mlxArray()
    }
}

public extension Vector {
    /// Creates a vector from a rank-1 MLX array.
    init?(mlxArray array: MLXArray) {
        guard array.ndim == 1,
              let tensor = Tensor<Double>(mlxArray: array) else { return nil }
        self.init(tensor)
    }

    /// Creates an MLX array from the vector values.
    func mlxArray() -> MLXArray {
        tensor.mlxArray()
    }
}
#endif
