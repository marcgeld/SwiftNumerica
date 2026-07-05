import Testing

@testable import SwiftNumerica

@Test func signalPreservesSamplesAndSampleRate() throws {
    let signal = try #require(Signal([1, 2, 3], sampleRate: 44_100))

    #expect(signal.values == [1, 2, 3])
    #expect(signal.count == 3)
    #expect(signal.sampleRate?.isApproximatelyEqual(to: 44_100) == true)
}

@Test func fftAndInverseFFTRoundTripRealSignal() throws {
    let signal = Tensor.vector([1, 0, -1, 0])
    let spectrum = try #require(Numerica.SignalProcessing.fft(signal))

    #expect(spectrum.values.count == 4)
    #expect(spectrum.values[0].real.isApproximatelyEqual(to: 0, tolerance: 1e-12))
    #expect(spectrum.values[1].real.isApproximatelyEqual(to: 2, tolerance: 1e-12))
    #expect(spectrum.values[1].imaginary.isApproximatelyEqual(to: 0, tolerance: 1e-12))

    let reconstructed = try #require(Numerica.SignalProcessing.inverseFFT(spectrum))
    for (actual, expected) in zip(reconstructed.values, signal.values) {
        #expect(actual.isApproximatelyEqual(to: expected, tolerance: 1e-12))
    }
}

@Test func convolutionCorrelationAndAutocorrelationUseFullLengthOutputs() throws {
    let signal = Tensor.vector([1, 2, 3])
    let kernel = Tensor.vector([1, 1])

    let convolved = try #require(Numerica.SignalProcessing.convolve(signal, with: kernel))
    #expect(convolved.values == [1, 3, 5, 3])

    let correlated = try #require(Numerica.SignalProcessing.correlate(signal, with: kernel))
    #expect(correlated.values == [1, 3, 5, 3])

    let autocorrelation = try #require(Numerica.SignalProcessing.autocorrelation(Tensor.vector([1, 2])))
    #expect(autocorrelation.values == [2, 5, 2])
}

@Test func windowFunctionsProduceExpectedShapesAndValues() throws {
    #expect(try #require(Numerica.SignalProcessing.rectangularWindow(size: 3)).values == [1, 1, 1])

    let hann = try #require(Numerica.SignalProcessing.hannWindow(size: 3))
    #expect(hann.values[0].isApproximatelyEqual(to: 0, tolerance: 1e-12))
    #expect(hann.values[1].isApproximatelyEqual(to: 1, tolerance: 1e-12))
    #expect(hann.values[2].isApproximatelyEqual(to: 0, tolerance: 1e-12))

    let hamming = try #require(Numerica.SignalProcessing.hammingWindow(size: 3))
    #expect(hamming.values[0].isApproximatelyEqual(to: 0.08, tolerance: 1e-12))
    #expect(hamming.values[1].isApproximatelyEqual(to: 1, tolerance: 1e-12))

    let blackman = try #require(Numerica.SignalProcessing.blackmanWindow(size: 3))
    #expect(blackman.values[1].isApproximatelyEqual(to: 1, tolerance: 1e-12))
}

@Test func movingAverageDetrendAndNormalizeProduceSignalSummaries() throws {
    let movingAverage = try #require(
        Numerica.SignalProcessing.movingAverage(Tensor.vector([1, 2, 10, 2, 1]), windowSize: 3)
    )
    #expect(movingAverage.values == [1.5, 13.0 / 3.0, 14.0 / 3.0, 13.0 / 3.0, 1.5])

    let detrended = try #require(Numerica.SignalProcessing.detrend(Tensor.vector([2, 4, 6, 8])))
    #expect(detrended.values.allSatisfy { $0.isApproximatelyEqual(to: 0, tolerance: 1e-12) })

    let normalized = try #require(Numerica.SignalProcessing.normalize(Tensor.vector([1, 2, 3])))
    #expect(try #require(normalized.mean()).isApproximatelyEqual(to: 0, tolerance: 1e-12))
    #expect(try #require(normalized.sampleStandardDeviation()).isApproximatelyEqual(to: 1, tolerance: 1e-12))
}

@Test func zeroCrossingRateAndPeakDetectionSummarizeSignalShape() throws {
    let crossings = try #require(Numerica.SignalProcessing.zeroCrossingRate(Tensor.vector([-1, 1, -1, 1])))
    #expect(crossings.isApproximatelyEqual(to: 1))

    let peaks = Numerica.SignalProcessing.peakDetection(
        Tensor.vector([0, 2, 1, 3, 0]),
        minimumProminence: 1
    )
    #expect(peaks == [
        Peak(index: 1, value: 2, prominence: 1),
        Peak(index: 3, value: 3, prominence: 2),
    ])
}

@Test func signalValueStyleAPIsDelegateToNamespaceFunctions() throws {
    let signal = try #require(Signal([1, 0, -1, 0], sampleRate: 4))

    #expect(try #require(signal.fft()).values.count == 4)
    #expect(try #require(signal.movingAverage(windowSize: 3)).values.count == 4)
    #expect(signal.peaks().isEmpty)
    #expect(try #require(signal.periodogram()).values.count == 4)
}

@Test func periodogramAndSpectraExposeFrequencyDomainSummaries() throws {
    let signal = Tensor.vector([1, 0, -1, 0])
    let periodogram = try #require(Numerica.SignalProcessing.periodogram(signal))
    let magnitude = try #require(Numerica.SignalProcessing.magnitudeSpectrum(signal))
    let phase = try #require(Numerica.SignalProcessing.phaseSpectrum(signal))

    #expect(periodogram.values.count == 4)
    #expect(periodogram.values[1].isApproximatelyEqual(to: 1, tolerance: 1e-12))
    #expect(magnitude.values[1].isApproximatelyEqual(to: 2, tolerance: 1e-12))
    #expect(phase.values.count == 4)
}

@Test func filtersPreserveSignalLengthAndRejectInvalidParameters() throws {
    let signal = Tensor.vector([0, 1, 0, -1, 0, 1, 0])

    let lowPass = try #require(
        Numerica.SignalProcessing.lowPassFilter(
            signal,
            cutoffFrequency: 1,
            sampleRate: 10,
            filterLength: 5
        ))
    #expect(lowPass.values.count == signal.count)

    let highPass = try #require(
        Numerica.SignalProcessing.highPassFilter(
            signal,
            cutoffFrequency: 1,
            sampleRate: 10,
            filterLength: 5
        ))
    #expect(highPass.values.count == signal.count)

    let bandPass = try #require(
        Numerica.SignalProcessing.bandPassFilter(
            signal,
            lowCutoffFrequency: 1,
            highCutoffFrequency: 2,
            sampleRate: 10,
            filterLength: 5
        ))
    #expect(bandPass.values.count == signal.count)

    let bandStop = try #require(
        Numerica.SignalProcessing.bandStopFilter(
            signal,
            lowCutoffFrequency: 1,
            highCutoffFrequency: 2,
            sampleRate: 10,
            filterLength: 5
        ))
    #expect(bandStop.values.count == signal.count)
    #expect(Numerica.SignalProcessing.lowPassFilter(signal, cutoffFrequency: 10, sampleRate: 10) == nil)
}

@Test func biquadFilterAppliesDirectFormDifferenceEquation() throws {
    let filter = try #require(BiquadFilter(b0: 1, b1: 0, b2: 0, a1: 0, a2: 0))
    let output = try #require(filter.applied(to: Tensor.vector([1, 2, 3])))

    #expect(output.values == [1, 2, 3])
}
