/// Errors thrown by tensor shape and storage operations.
public enum TensorError: Error, Equatable, Sendable {
    /// The requested shape is invalid.
    case invalidShape

    /// The requested shape is incompatible with the tensor storage.
    case incompatibleShape
}
