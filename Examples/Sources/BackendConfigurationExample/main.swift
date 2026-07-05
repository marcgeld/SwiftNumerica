import SwiftNumerica

// Compute backend selection:
// https://en.wikipedia.org/wiki/Hardware_acceleration
//
// This example shows how to inspect and switch SwiftNumerica compute backends.

let data = Tensor.vector([1, 2, 3, 4])

print("Default backend:", Numerica.configuration.backend)
print("Accelerate available:", ComputeBackend.accelerate.isAvailable)

Numerica.configuration.backend = .pureSwift
print("Pure Swift mean:", Numerica.Statistics.mean(data) ?? .nan)

Numerica.configuration.backend = .automatic
print("Resolved automatic backend:", try Numerica.resolvedBackend())
print("Automatic mean:", Numerica.Statistics.mean(data) ?? .nan)

if ComputeBackend.accelerate.isAvailable {
    Numerica.configuration.backend = .accelerate
    print("Accelerate mean:", Numerica.Statistics.mean(data) ?? .nan)
}

Numerica.configuration = NumericaConfiguration()
print("Reset backend:", Numerica.configuration.backend)
