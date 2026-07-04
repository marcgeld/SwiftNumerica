internal enum BackendAvailability {
    internal static var isAccelerateAvailable: Bool {
        #if canImport(Accelerate)
        true
        #else
        false
        #endif
    }
}
