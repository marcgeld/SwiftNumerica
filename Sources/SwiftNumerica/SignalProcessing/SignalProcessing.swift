import Foundation

public extension Numerica.SignalProcessing {
    /// A complex number used by signal transforms.
    struct ComplexNumber: Equatable, Sendable {
        /// The real component.
        public let real: Double

        /// The imaginary component.
        public let imaginary: Double

        /// The magnitude.
        public var magnitude: Double {
            Foundation.hypot(real, imaginary)
        }

        /// The phase angle in radians.
        public var phase: Double {
            Foundation.atan2(imaginary, real)
        }

        /// Creates a complex number.
        public init(real: Double, imaginary: Double = 0) {
            self.real = real
            self.imaginary = imaginary
        }
    }

    /// A detected local peak.
    struct Peak: Equatable, Sendable {
        /// The peak index in the source signal.
        public let index: Int

        /// The peak value.
        public let value: Double

        /// The peak prominence relative to its immediate neighbors.
        public let prominence: Double

        /// Creates a peak.
        public init(index: Int, value: Double, prominence: Double) {
            self.index = index
            self.value = value
            self.prominence = prominence
        }
    }

    /// A direct-form I biquad filter.
    struct BiquadFilter: Equatable, Sendable {
        /// The feed-forward coefficient b0.
        public let b0: Double

        /// The feed-forward coefficient b1.
        public let b1: Double

        /// The feed-forward coefficient b2.
        public let b2: Double

        /// The feedback coefficient a1. `a0` is normalized to 1.
        public let a1: Double

        /// The feedback coefficient a2. `a0` is normalized to 1.
        public let a2: Double

        /// Creates a normalized biquad filter.
        public init?(b0: Double, b1: Double, b2: Double, a0: Double = 1, a1: Double, a2: Double) {
            guard a0 != 0,
                  [b0, b1, b2, a0, a1, a2].allSatisfy(\.isFinite) else { return nil }
            self.b0 = b0 / a0
            self.b1 = b1 / a0
            self.b2 = b2 / a0
            self.a1 = a1 / a0
            self.a2 = a2 / a0
        }

        /// Applies the filter to a signal.
        public func applied(to signal: Tensor<Double>) -> Tensor<Double>? {
            Numerica.SignalProcessing.apply(self, to: signal)
        }
    }

    /// A one-dimensional signal with an optional sample rate.
    struct Signal: Equatable, Sendable {
        /// The signal samples.
        public let samples: Tensor<Double>

        /// The sample rate in hertz, when known.
        public let sampleRate: Double?

        /// The sample values.
        public var values: [Double] {
            samples.values
        }

        /// The number of samples.
        public var count: Int {
            samples.count
        }

        /// Creates a signal from a rank-1 tensor.
        public init?(samples: Tensor<Double>, sampleRate: Double? = nil) {
            guard samples.rank == 1,
                  samples.values.allSatisfy(\.isFinite),
                  sampleRate.map({ $0 > 0 && $0.isFinite }) ?? true else { return nil }
            self.samples = samples
            self.sampleRate = sampleRate
        }

        /// Creates a signal from sample values.
        public init?(_ values: [Double], sampleRate: Double? = nil) {
            self.init(samples: .vector(values), sampleRate: sampleRate)
        }

        /// Computes the discrete Fourier transform.
        public func fft() -> Tensor<ComplexNumber>? {
            Numerica.SignalProcessing.fft(samples)
        }

        /// Smooths the signal with a centered moving average.
        public func movingAverage(windowSize: Int) -> Signal? {
            Numerica.SignalProcessing.movingAverage(samples, windowSize: windowSize)
                .flatMap { Signal(samples: $0, sampleRate: sampleRate) }
        }

        /// Removes the least-squares linear trend from the signal.
        public func detrended() -> Signal? {
            Numerica.SignalProcessing.detrend(samples)
                .flatMap { Signal(samples: $0, sampleRate: sampleRate) }
        }

        /// Normalizes the signal to zero mean and unit sample standard deviation.
        public func normalized() -> Signal? {
            Numerica.SignalProcessing.normalize(samples)
                .flatMap { Signal(samples: $0, sampleRate: sampleRate) }
        }

        /// Returns local peaks.
        public func peaks(minimumProminence: Double = 0) -> [Peak] {
            Numerica.SignalProcessing.peakDetection(samples, minimumProminence: minimumProminence)
        }

        /// Computes the periodogram.
        public func periodogram() -> Tensor<Double>? {
            Numerica.SignalProcessing.periodogram(samples)
        }
    }

    /// Computes the discrete Fourier transform in O(n log n) for any length.
    static func fft(_ signal: Tensor<Double>) -> Tensor<ComplexNumber>? {
        guard isFiniteVector(signal), signal.count > 0,
              let backend = try? BackendResolver.signalProcessingBackend() else { return nil }
        return complexVector(backend.fft(signal.values))
    }

    /// Computes the inverse discrete Fourier transform and returns the real component.
    static func inverseFFT(_ spectrum: Tensor<ComplexNumber>) -> Tensor<Double>? {
        guard spectrum.rank == 1, spectrum.count > 0,
              let backend = try? BackendResolver.signalProcessingBackend() else { return nil }
        return .vector(backend.inverseFFT(spectrum.values))
    }

    /// Computes the full discrete convolution of two signals.
    static func convolve(_ signal: Tensor<Double>, with kernel: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(signal), isFiniteVector(kernel),
              signal.count > 0, kernel.count > 0 else { return nil }

        var output = Array(repeating: 0.0, count: signal.count + kernel.count - 1)
        for signalIndex in signal.values.indices {
            for kernelIndex in kernel.values.indices {
                output[signalIndex + kernelIndex] += signal.values[signalIndex] * kernel.values[kernelIndex]
            }
        }

        return .vector(output)
    }

    /// Computes the full cross-correlation of two signals.
    static func correlate(_ signal: Tensor<Double>, with kernel: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(kernel) else { return nil }
        return convolve(signal, with: .vector(kernel.values.reversed()))
    }

    /// Computes full autocorrelation.
    static func autocorrelation(_ signal: Tensor<Double>) -> Tensor<Double>? {
        correlate(signal, with: signal)
    }

    /// Smooths a signal with a centered moving average while preserving length.
    static func movingAverage(_ signal: Tensor<Double>, windowSize: Int) -> Tensor<Double>? {
        guard isFiniteVector(signal), signal.count > 0, windowSize > 0 else { return nil }

        let leftRadius = (windowSize - 1) / 2
        let rightRadius = windowSize / 2
        let values = signal.values.indices.map { index -> Double in
            let lower = Swift.max(0, index - leftRadius)
            let upper = Swift.min(signal.count - 1, index + rightRadius)
            let window = signal.values[lower...upper]
            return window.reduce(0, +) / Double(window.count)
        }

        return .vector(values)
    }

    /// Creates a rectangular window.
    static func rectangularWindow(size: Int) -> Tensor<Double>? {
        guard size > 0 else { return nil }
        return .vector(Array(repeating: 1, count: size))
    }

    /// Creates a Hann window.
    static func hannWindow(size: Int) -> Tensor<Double>? {
        raisedCosineWindow(size: size, alpha: 0.5, beta: 0.5)
    }

    /// Creates a Hamming window.
    static func hammingWindow(size: Int) -> Tensor<Double>? {
        raisedCosineWindow(size: size, alpha: 0.54, beta: 0.46)
    }

    /// Creates a Blackman window.
    static func blackmanWindow(size: Int) -> Tensor<Double>? {
        guard size > 0 else { return nil }
        if size == 1 { return .vector([1]) }

        let denominator = Double(size - 1)
        let values = (0..<size).map { index in
            let phase = 2 * Double.pi * Double(index) / denominator
            return 0.42 - 0.5 * Foundation.cos(phase) + 0.08 * Foundation.cos(2 * phase)
        }
        return .vector(values)
    }

    /// Removes the least-squares linear trend from a signal.
    static func detrend(_ signal: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(signal), signal.count > 0 else { return nil }
        if signal.count == 1 { return .vector([0]) }

        let x = Tensor.vector((0..<signal.count).map(Double.init))
        guard let regression = Numerica.Statistics.linearRegression(x: x, y: signal) else { return nil }

        let values = signal.values.enumerated().map { index, value in
            value - (regression.slope * Double(index) + regression.intercept)
        }
        return .vector(values)
    }

    /// Normalizes a signal to zero mean and unit sample standard deviation.
    static func normalize(_ signal: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(signal),
              let mean = Numerica.Statistics.mean(signal),
              let standardDeviation = Numerica.Statistics.sampleStandardDeviation(signal),
              standardDeviation > 0 else { return nil }

        return .vector(signal.values.map { ($0 - mean) / standardDeviation })
    }

    /// Computes the zero crossing rate.
    ///
    /// A crossing is counted whenever the sign changes between consecutive
    /// nonzero samples, so paths through exact zeros such as `[1, 0, -1]`
    /// count as one crossing. The rate is normalized by `count - 1`.
    static func zeroCrossingRate(_ signal: Tensor<Double>) -> Double? {
        guard isFiniteVector(signal), signal.count > 1 else { return nil }

        var crossings = 0
        var previousSign = 0.0
        for value in signal.values {
            let sign: Double = value > 0 ? 1 : (value < 0 ? -1 : 0)
            guard sign != 0 else { continue }
            if previousSign != 0, sign != previousSign {
                crossings += 1
            }
            previousSign = sign
        }

        return Double(crossings) / Double(signal.count - 1)
    }

    /// Detects strict local maxima.
    static func peakDetection(_ signal: Tensor<Double>, minimumProminence: Double = 0) -> [Peak] {
        guard isFiniteVector(signal),
              signal.count >= 3,
              minimumProminence >= 0,
              minimumProminence.isFinite else { return [] }

        var peaks: [Peak] = []
        for index in 1..<(signal.count - 1) {
            let left = signal.values[index - 1]
            let value = signal.values[index]
            let right = signal.values[index + 1]
            let prominence = value - Swift.max(left, right)
            if value > left, value > right, prominence >= minimumProminence {
                peaks.append(Peak(index: index, value: value, prominence: prominence))
            }
        }
        return peaks
    }

    /// Computes a basic periodogram from the discrete Fourier transform.
    static func periodogram(_ signal: Tensor<Double>) -> Tensor<Double>? {
        guard let spectrum = fft(signal) else { return nil }
        let scale = Double(signal.count)
        return .vector(spectrum.values.map { value in
            let magnitude = value.magnitude
            return magnitude * magnitude / scale
        })
    }

    /// Returns the magnitude spectrum.
    static func magnitudeSpectrum(_ signal: Tensor<Double>) -> Tensor<Double>? {
        fft(signal).map { .vector($0.values.map(\.magnitude)) }
    }

    /// Returns the phase spectrum in radians.
    static func phaseSpectrum(_ signal: Tensor<Double>) -> Tensor<Double>? {
        fft(signal).map { .vector($0.values.map(\.phase)) }
    }

    /// Applies a low-pass FIR filter.
    static func lowPassFilter(
        _ signal: Tensor<Double>,
        cutoffFrequency: Double,
        sampleRate: Double,
        filterLength: Int = 101
    ) -> Tensor<Double>? {
        firKernel(cutoffFrequency: cutoffFrequency, sampleRate: sampleRate, filterLength: filterLength)
            .flatMap { applyFIRKernel($0, to: signal) }
    }

    /// Applies a high-pass FIR filter.
    static func highPassFilter(
        _ signal: Tensor<Double>,
        cutoffFrequency: Double,
        sampleRate: Double,
        filterLength: Int = 101
    ) -> Tensor<Double>? {
        guard let lowPass = firKernel(
            cutoffFrequency: cutoffFrequency,
            sampleRate: sampleRate,
            filterLength: filterLength
        ) else { return nil }

        let center = lowPass.count / 2
        let values = lowPass.values.enumerated().map { index, value in
            (index == center ? 1 : 0) - value
        }
        return applyFIRKernel(.vector(values), to: signal)
    }

    /// Applies a band-pass FIR filter.
    static func bandPassFilter(
        _ signal: Tensor<Double>,
        lowCutoffFrequency: Double,
        highCutoffFrequency: Double,
        sampleRate: Double,
        filterLength: Int = 101
    ) -> Tensor<Double>? {
        guard lowCutoffFrequency > 0,
              highCutoffFrequency > lowCutoffFrequency,
              let low = firKernel(
                cutoffFrequency: lowCutoffFrequency,
                sampleRate: sampleRate,
                filterLength: filterLength
              ),
              let high = firKernel(
                cutoffFrequency: highCutoffFrequency,
                sampleRate: sampleRate,
                filterLength: filterLength
              ) else { return nil }

        let values = zip(high.values, low.values).map { $0 - $1 }
        return applyFIRKernel(.vector(values), to: signal)
    }

    /// Applies a band-stop FIR filter.
    static func bandStopFilter(
        _ signal: Tensor<Double>,
        lowCutoffFrequency: Double,
        highCutoffFrequency: Double,
        sampleRate: Double,
        filterLength: Int = 101
    ) -> Tensor<Double>? {
        guard lowCutoffFrequency > 0,
              highCutoffFrequency > lowCutoffFrequency,
              let low = firKernel(
                cutoffFrequency: lowCutoffFrequency,
                sampleRate: sampleRate,
                filterLength: filterLength
              ),
              let high = firKernel(
                cutoffFrequency: highCutoffFrequency,
                sampleRate: sampleRate,
                filterLength: filterLength
              ) else { return nil }

        let center = low.count / 2
        let values = zip(high.values, low.values).enumerated().map { index, pair in
            (index == center ? 1 : 0) - (pair.0 - pair.1)
        }
        return applyFIRKernel(.vector(values), to: signal)
    }

    /// Applies a direct-form I biquad filter.
    static func apply(_ filter: BiquadFilter, to signal: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(signal), signal.count > 0 else { return nil }

        var output = Array(repeating: 0.0, count: signal.count)
        var previousInput1 = 0.0
        var previousInput2 = 0.0
        var previousOutput1 = 0.0
        var previousOutput2 = 0.0

        for index in signal.values.indices {
            let input = signal.values[index]
            let value = filter.b0 * input
                + filter.b1 * previousInput1
                + filter.b2 * previousInput2
                - filter.a1 * previousOutput1
                - filter.a2 * previousOutput2
            output[index] = value

            previousInput2 = previousInput1
            previousInput1 = input
            previousOutput2 = previousOutput1
            previousOutput1 = value
        }

        return .vector(output)
    }

    private static func isFiniteVector(_ tensor: Tensor<Double>) -> Bool {
        tensor.rank == 1 && tensor.values.allSatisfy(\.isFinite)
    }

    private static func complexVector(_ values: [ComplexNumber]) -> Tensor<ComplexNumber>? {
        guard let shape = Shape([values.count]) else { return nil }
        return Tensor<ComplexNumber>(values, shape: shape)
    }

    private static func raisedCosineWindow(size: Int, alpha: Double, beta: Double) -> Tensor<Double>? {
        guard size > 0 else { return nil }
        if size == 1 { return .vector([1]) }

        let denominator = Double(size - 1)
        let values = (0..<size).map { index in
            alpha - beta * Foundation.cos(2 * Double.pi * Double(index) / denominator)
        }
        return .vector(values)
    }

    private static func firKernel(
        cutoffFrequency: Double,
        sampleRate: Double,
        filterLength: Int
    ) -> Tensor<Double>? {
        guard cutoffFrequency > 0,
              sampleRate > 0,
              cutoffFrequency < sampleRate / 2,
              filterLength > 1,
              filterLength.isMultiple(of: 2) == false else { return nil }

        let normalizedCutoff = cutoffFrequency / sampleRate
        let center = filterLength / 2
        let window = hannWindow(size: filterLength)?.values ?? Array(repeating: 1, count: filterLength)
        var values = (0..<filterLength).map { index -> Double in
            let offset = index - center
            if offset == 0 {
                return 2 * normalizedCutoff
            }
            let x = Double(offset)
            return Foundation.sin(2 * Double.pi * normalizedCutoff * x) / (Double.pi * x)
        }

        values = zip(values, window).map(*)
        let total = values.reduce(0, +)
        guard total != 0 else { return nil }
        return .vector(values.map { $0 / total })
    }

    private static func applyFIRKernel(_ kernel: Tensor<Double>, to signal: Tensor<Double>) -> Tensor<Double>? {
        guard isFiniteVector(signal),
              let convolved = convolve(signal, with: kernel) else { return nil }

        let start = kernel.count / 2
        let end = start + signal.count
        return .vector(Array(convolved.values[start..<end]))
    }
}

public extension Tensor where Scalar == Double {
    /// Computes the discrete Fourier transform.
    func fft() -> Tensor<Numerica.SignalProcessing.ComplexNumber>? {
        Numerica.SignalProcessing.fft(self)
    }

    /// Smooths the tensor with a centered moving average.
    func movingAverage(windowSize: Int) -> Tensor<Double>? {
        Numerica.SignalProcessing.movingAverage(self, windowSize: windowSize)
    }

    /// Removes the least-squares linear trend.
    func detrended() -> Tensor<Double>? {
        Numerica.SignalProcessing.detrend(self)
    }

    /// Normalizes values to zero mean and unit sample standard deviation.
    func normalizedSignal() -> Tensor<Double>? {
        Numerica.SignalProcessing.normalize(self)
    }
}

/// A one-dimensional signal with an optional sample rate.
public typealias Signal = Numerica.SignalProcessing.Signal

/// A complex number used by signal transforms.
public typealias ComplexNumber = Numerica.SignalProcessing.ComplexNumber

/// A detected local peak.
public typealias Peak = Numerica.SignalProcessing.Peak

/// A direct-form I biquad filter.
public typealias BiquadFilter = Numerica.SignalProcessing.BiquadFilter
