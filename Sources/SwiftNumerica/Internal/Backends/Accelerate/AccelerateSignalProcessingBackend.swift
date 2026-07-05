import Foundation

#if canImport(Accelerate)
import Accelerate
#endif

internal struct AccelerateSignalProcessingBackend: SignalProcessingBackend {
    private let reference = PureSwiftSignalProcessingBackend()

    internal func fft(_ signal: [Double]) -> [Numerica.SignalProcessing.ComplexNumber] {
        #if canImport(Accelerate)
        guard let setup = DFTSetupCache.shared.setup(count: signal.count, forward: true) else {
            return reference.fft(signal)
        }

        let imaginary = [Double](repeating: 0, count: signal.count)
        var outputReal = [Double](repeating: 0, count: signal.count)
        var outputImaginary = [Double](repeating: 0, count: signal.count)
        vDSP_DFT_ExecuteD(setup, signal, imaginary, &outputReal, &outputImaginary)
        return zip(outputReal, outputImaginary).map { .init(real: $0, imaginary: $1) }
        #else
        return reference.fft(signal)
        #endif
    }

    internal func inverseFFT(_ spectrum: [Numerica.SignalProcessing.ComplexNumber]) -> [Double] {
        #if canImport(Accelerate)
        guard let setup = DFTSetupCache.shared.setup(count: spectrum.count, forward: false) else {
            return reference.inverseFFT(spectrum)
        }

        let inputReal = spectrum.map(\.real)
        let inputImaginary = spectrum.map(\.imaginary)
        var outputReal = [Double](repeating: 0, count: spectrum.count)
        var outputImaginary = [Double](repeating: 0, count: spectrum.count)
        vDSP_DFT_ExecuteD(setup, inputReal, inputImaginary, &outputReal, &outputImaginary)
        let scale = 1 / Double(spectrum.count)
        return outputReal.map { $0 * scale }
        #else
        return reference.inverseFFT(spectrum)
        #endif
    }
}

#if canImport(Accelerate)
/// Caches vDSP DFT setups per length and direction.
///
/// Setups are never destroyed: eviction could free a setup another thread is
/// executing with, and realistic workloads use a small number of distinct
/// transform lengths.
internal final class DFTSetupCache: @unchecked Sendable {
    internal static let shared = DFTSetupCache()

    private struct Key: Hashable {
        let count: Int
        let forward: Bool
    }

    private let lock = NSLock()
    private var setups: [Key: OpaquePointer] = [:]

    /// Returns a cached or newly created setup, or `nil` when vDSP does not
    /// support the length (supported lengths are `f * 2^n` with `f` in
    /// 1, 3, 5, or 15).
    internal func setup(count: Int, forward: Bool) -> OpaquePointer? {
        lock.lock()
        defer { lock.unlock() }

        let key = Key(count: count, forward: forward)
        if let cached = setups[key] {
            return cached
        }

        guard let created = vDSP_DFT_zop_CreateSetupD(
            nil,
            vDSP_Length(count),
            forward ? .FORWARD : .INVERSE
        ) else { return nil }

        setups[key] = created
        return created
    }
}
#endif
