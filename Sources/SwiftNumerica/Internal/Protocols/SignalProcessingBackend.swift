internal protocol SignalProcessingBackend: Sendable {
    func fft(_ signal: [Double]) -> [Numerica.SignalProcessing.ComplexNumber]
    func inverseFFT(_ spectrum: [Numerica.SignalProcessing.ComplexNumber]) -> [Double]
    func convolve(_ signal: [Double], kernel: [Double]) -> [Double]
}
