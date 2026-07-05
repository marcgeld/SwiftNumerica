import Foundation

internal struct PureSwiftSignalProcessingBackend: SignalProcessingBackend {
    internal func fft(_ signal: [Double]) -> [Numerica.SignalProcessing.ComplexNumber] {
        let (real, imaginary) = Self.complexDFT(
            real: signal,
            imaginary: Array(repeating: 0, count: signal.count),
            inverse: false
        )
        return zip(real, imaginary).map { .init(real: $0, imaginary: $1) }
    }

    internal func inverseFFT(_ spectrum: [Numerica.SignalProcessing.ComplexNumber]) -> [Double] {
        guard !spectrum.isEmpty else { return [] }
        let (real, _) = Self.complexDFT(
            real: spectrum.map(\.real),
            imaginary: spectrum.map(\.imaginary),
            inverse: true
        )
        let scale = 1 / Double(spectrum.count)
        return real.map { $0 * scale }
    }

    internal func convolve(_ signal: [Double], kernel: [Double]) -> [Double] {
        var output = Array(repeating: 0.0, count: signal.count + kernel.count - 1)
        for signalIndex in signal.indices {
            for kernelIndex in kernel.indices {
                output[signalIndex + kernelIndex] += signal[signalIndex] * kernel[kernelIndex]
            }
        }
        return output
    }

    /// Computes an unscaled complex DFT in O(n log n) for any length: radix-2
    /// Cooley-Tukey for powers of two and Bluestein's chirp-z algorithm
    /// otherwise. Callers scale inverse transforms by `1 / count`.
    internal static func complexDFT(
        real: [Double],
        imaginary: [Double],
        inverse: Bool
    ) -> ([Double], [Double]) {
        let count = real.count
        guard count > 1 else { return (real, imaginary) }

        if count & (count - 1) == 0 {
            var mutableReal = real
            var mutableImaginary = imaginary
            radix2FFT(real: &mutableReal, imaginary: &mutableImaginary, inverse: inverse)
            return (mutableReal, mutableImaginary)
        }
        return bluesteinDFT(real: real, imaginary: imaginary, inverse: inverse)
    }

    /// In-place iterative radix-2 Cooley-Tukey FFT. `count` must be a power of
    /// two. The transform is unscaled in both directions.
    private static func radix2FFT(real: inout [Double], imaginary: inout [Double], inverse: Bool) {
        let count = real.count
        guard count > 1 else { return }

        var target = 0
        for index in 0..<(count - 1) {
            if index < target {
                real.swapAt(index, target)
                imaginary.swapAt(index, target)
            }
            var mask = count >> 1
            while mask <= target {
                target -= mask
                mask >>= 1
            }
            target += mask
        }

        let angleSign: Double = inverse ? 1 : -1
        let half = count >> 1
        var twiddleReal = [Double](repeating: 0, count: half)
        var twiddleImaginary = [Double](repeating: 0, count: half)
        for index in 0..<half {
            let angle = angleSign * 2 * Double.pi * Double(index) / Double(count)
            twiddleReal[index] = Foundation.cos(angle)
            twiddleImaginary[index] = Foundation.sin(angle)
        }

        var length = 2
        while length <= count {
            let halfLength = length >> 1
            let twiddleStride = count / length
            var start = 0
            while start < count {
                for offset in 0..<halfLength {
                    let twiddleIndex = offset * twiddleStride
                    let twiddleRealValue = twiddleReal[twiddleIndex]
                    let twiddleImaginaryValue = twiddleImaginary[twiddleIndex]
                    let evenIndex = start + offset
                    let oddIndex = evenIndex + halfLength
                    let productReal = twiddleRealValue * real[oddIndex]
                        - twiddleImaginaryValue * imaginary[oddIndex]
                    let productImaginary = twiddleRealValue * imaginary[oddIndex]
                        + twiddleImaginaryValue * real[oddIndex]
                    real[oddIndex] = real[evenIndex] - productReal
                    imaginary[oddIndex] = imaginary[evenIndex] - productImaginary
                    real[evenIndex] += productReal
                    imaginary[evenIndex] += productImaginary
                }
                start += length
            }
            length <<= 1
        }
    }

    /// Bluestein's chirp-z transform: expresses an arbitrary-length DFT as a
    /// circular convolution of power-of-two length, evaluated with radix-2
    /// FFTs. Chirp exponents are reduced modulo `2 * count` to keep the angle
    /// arguments small and precise.
    private static func bluesteinDFT(
        real: [Double],
        imaginary: [Double],
        inverse: Bool
    ) -> ([Double], [Double]) {
        let count = real.count
        let sign: Double = inverse ? 1 : -1
        let modulus = 2 * count

        var chirpReal = [Double](repeating: 0, count: count)
        var chirpImaginary = [Double](repeating: 0, count: count)
        for index in 0..<count {
            let squared = (index * index) % modulus
            let angle = sign * Double.pi * Double(squared) / Double(count)
            chirpReal[index] = Foundation.cos(angle)
            chirpImaginary[index] = Foundation.sin(angle)
        }

        var paddedCount = 1
        while paddedCount < 2 * count - 1 {
            paddedCount <<= 1
        }

        var leftReal = [Double](repeating: 0, count: paddedCount)
        var leftImaginary = [Double](repeating: 0, count: paddedCount)
        for index in 0..<count {
            leftReal[index] = real[index] * chirpReal[index]
                - imaginary[index] * chirpImaginary[index]
            leftImaginary[index] = real[index] * chirpImaginary[index]
                + imaginary[index] * chirpReal[index]
        }

        var rightReal = [Double](repeating: 0, count: paddedCount)
        var rightImaginary = [Double](repeating: 0, count: paddedCount)
        rightReal[0] = chirpReal[0]
        rightImaginary[0] = -chirpImaginary[0]
        for index in 1..<count {
            rightReal[index] = chirpReal[index]
            rightImaginary[index] = -chirpImaginary[index]
            rightReal[paddedCount - index] = rightReal[index]
            rightImaginary[paddedCount - index] = rightImaginary[index]
        }

        radix2FFT(real: &leftReal, imaginary: &leftImaginary, inverse: false)
        radix2FFT(real: &rightReal, imaginary: &rightImaginary, inverse: false)

        for index in 0..<paddedCount {
            let productReal = leftReal[index] * rightReal[index]
                - leftImaginary[index] * rightImaginary[index]
            let productImaginary = leftReal[index] * rightImaginary[index]
                + leftImaginary[index] * rightReal[index]
            leftReal[index] = productReal
            leftImaginary[index] = productImaginary
        }

        radix2FFT(real: &leftReal, imaginary: &leftImaginary, inverse: true)
        let scale = 1 / Double(paddedCount)

        var outputReal = [Double](repeating: 0, count: count)
        var outputImaginary = [Double](repeating: 0, count: count)
        for index in 0..<count {
            let convolvedReal = leftReal[index] * scale
            let convolvedImaginary = leftImaginary[index] * scale
            outputReal[index] = convolvedReal * chirpReal[index]
                - convolvedImaginary * chirpImaginary[index]
            outputImaginary[index] = convolvedReal * chirpImaginary[index]
                + convolvedImaginary * chirpReal[index]
        }
        return (outputReal, outputImaginary)
    }
}
