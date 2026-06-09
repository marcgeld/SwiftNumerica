internal enum BackendAvailability {
    internal static var isAccelerateAvailable: Bool {
        #if canImport(Accelerate)
        true
        #else
        false
        #endif
    }

    internal static var isMLXAvailable: Bool {
        // TODO: Detect MLX availability when an MLX backend is implemented.
        false
    }
}
