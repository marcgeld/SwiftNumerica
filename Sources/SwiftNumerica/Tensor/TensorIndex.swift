/// A multidimensional tensor index.
public struct TensorIndex: Equatable, Sendable {
    /// The coordinate for each tensor axis.
    public let coordinates: [Int]

    /// Creates a tensor index from axis coordinates.
    ///
    /// - Parameter coordinates: Non-negative axis coordinates.
    public init?(_ coordinates: [Int]) {
        guard coordinates.allSatisfy({ $0 >= 0 }) else { return nil }
        self.coordinates = coordinates
    }
}
