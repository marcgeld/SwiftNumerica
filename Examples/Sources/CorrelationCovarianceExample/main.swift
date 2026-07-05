import SwiftNumerica

// Correlation and covariance:
// https://en.wikipedia.org/wiki/Correlation
//
// This example compares two tensors and prints covariance plus Pearson and
// Spearman correlation.

let x = Tensor.vector([1, 2, 3, 4, 5])
let y = Tensor.vector([2, 4, 6, 8, 10])
let populationCovariance = Numerica.Statistics.populationCovariance(x, y)
let sampleCovariance = Numerica.Statistics.sampleCovariance(x, y)
let covarianceAlias = Numerica.Statistics.covariance(x, y)
let pearsonCorrelation = Numerica.Statistics.pearsonCorrelation(x, y)
let spearmanCorrelation = Numerica.Statistics.spearmanCorrelation(x, y)
let correlationAlias = Numerica.Statistics.correlation(x, y)
let valueStyleCovariance = x.covariance(with: y)
let valueStyleCorrelation = x.correlation(with: y)

print("x:", x.values)
print("y:", y.values)
print("Population covariance (expected average paired deviation product = 4): \(populationCovariance ?? .nan)")
print("Sample covariance (expected population covariance scaled by 5 / 4 = 5): \(sampleCovariance ?? .nan)")
print("Covariance alias (expected sample covariance = 5): \(covarianceAlias ?? .nan)")
print("Pearson correlation (expected perfect positive linear relationship = 1): \(pearsonCorrelation ?? .nan)")
print("Spearman correlation (expected identical ranks = 1): \(spearmanCorrelation ?? .nan)")
print("Correlation alias (expected Pearson correlation = 1): \(correlationAlias ?? .nan)")
print("Value-style covariance (expected same as alias = 5): \(valueStyleCovariance ?? .nan)")
print("Value-style correlation (expected same as alias = 1): \(valueStyleCorrelation ?? .nan)")
