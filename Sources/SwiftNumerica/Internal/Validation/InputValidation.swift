internal enum InputValidation {
    internal static func isNonEmpty(_ tensor: Tensor<Double>) -> Bool {
        !tensor.values.isEmpty
    }

    internal static func isValidCount(_ n: Int) -> Bool {
        n >= 0
    }

    internal static func isValidSelection(n: Int, r: Int) -> Bool {
        n >= 0 && r >= 0 && r <= n
    }
}
