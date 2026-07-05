import SwiftNumerica

// Correlation and covariance:
// https://en.wikipedia.org/wiki/Correlation
//
// This example compares two tensors and prints covariance plus Pearson and
// Spearman correlation.

let x = Tensor.vector([1, 2, 3, 4, 5])
let y = Tensor.vector([2, 4, 6, 8, 10])

print("x:", x.values)
print("y:", y.values)
print("Population covariance:", Numerica.Statistics.populationCovariance(x, y) ?? .nan)
print("Sample covariance:", Numerica.Statistics.sampleCovariance(x, y) ?? .nan)
print("Covariance alias:", Numerica.Statistics.covariance(x, y) ?? .nan)
print("Pearson correlation:", Numerica.Statistics.pearsonCorrelation(x, y) ?? .nan)
print("Spearman correlation:", Numerica.Statistics.spearmanCorrelation(x, y) ?? .nan)
print("Correlation alias:", Numerica.Statistics.correlation(x, y) ?? .nan)
print("Value-style covariance:", x.covariance(with: y) ?? .nan)
print("Value-style correlation:", x.correlation(with: y) ?? .nan)

