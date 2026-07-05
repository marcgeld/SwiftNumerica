import SwiftNumerica

// Compute backend selection:
// https://en.wikipedia.org/wiki/Hardware_acceleration
//
// This example shows how to inspect and switch SwiftNumerica compute backends.

let data = Tensor.vector([1, 2, 3, 4])
let defaultBackend = Numerica.configuration.backend
let accelerateAvailable = ComputeBackend.accelerate.isAvailable

print("Default backend (expected automatic): \(defaultBackend)")
print("Accelerate available (expected true on Apple platforms with Accelerate): \(accelerateAvailable)")

Numerica.configuration.backend = .pureSwift
let pureSwiftMean = Numerica.Statistics.mean(data)
print("Pure Swift mean (expected (1 + 2 + 3 + 4) / 4 = 2.5): \(pureSwiftMean ?? .nan)")

Numerica.configuration.backend = .automatic
let resolvedBackend = try Numerica.resolvedBackend()
let automaticMean = Numerica.Statistics.mean(data)
print("Resolved automatic backend (expected accelerate when available, otherwise pureSwift): \(resolvedBackend)")
print("Automatic mean (expected same mean = 2.5): \(automaticMean ?? .nan)")

if accelerateAvailable {
    Numerica.configuration.backend = .accelerate
    let accelerateMean = Numerica.Statistics.mean(data)
    print("Accelerate mean (expected same mean = 2.5): \(accelerateMean ?? .nan)")
}

Numerica.configuration = NumericaConfiguration()
let resetBackend = Numerica.configuration.backend
print("Reset backend (expected automatic): \(resetBackend)")
