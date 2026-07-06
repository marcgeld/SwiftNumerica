import SwiftNumerica

// Linear algebra:
// https://en.wikipedia.org/wiki/Linear_algebra
//
// This example uses Matrix and Vector with determinant, inverse, solve,
// eigenvalues, and eigenvectors APIs.

let matrix = Matrix([[4, 7], [2, 6]])!
let vector = Vector([1, 0])
let symmetric = Matrix([[2, 1], [1, 2]])!
let determinantNamespace = Numerica.LinearAlgebra.determinant(matrix)
let determinantFree = determinant(matrix)
let determinantValue = matrix.determinant()
let inverseNamespace = Numerica.LinearAlgebra.inverse(matrix)
let inverseFree = inverse(matrix)
let inverseValue = matrix.inverse()
let solutionNamespace = Numerica.LinearAlgebra.solve(matrix, vector)
let solutionFree = solve(matrix, vector)
let solutionValue = matrix.solve(vector)
let eigenvaluesNamespace = Numerica.LinearAlgebra.eigenvalues(symmetric)
let eigenvaluesFree = eigenvalues(symmetric)
let eigenvaluesValue = symmetric.eigenvalues()
let eigenvectorsNamespace = Numerica.LinearAlgebra.eigenvectors(symmetric)
let eigenvectorsFree = eigenvectors(symmetric)
let eigenvectorsValue = symmetric.eigenvectors()

print("Matrix values:", matrix.values)
print("Vector values:", vector.values)
print("Determinant namespace/free/value (expected 4 x 6 - 7 x 2 = 10): \(determinantNamespace ?? .nan) \(determinantFree ?? .nan) \(determinantValue ?? .nan)")
print("Inverse namespace/free/value (expected approximately [0.6, -0.7, -0.2, 0.4]): \(inverseNamespace?.values ?? []) \(inverseFree?.values ?? []) \(inverseValue?.values ?? [])")
print("Solve namespace/free/value for Ax = [1, 0] (expected approximately [0.6, -0.2]): \(solutionNamespace?.values ?? []) \(solutionFree?.values ?? []) \(solutionValue?.values ?? [])")
print("Eigenvalues namespace/free/value for [[2, 1], [1, 2]] (expected [3, 1]): \(eigenvaluesNamespace ?? []) \(eigenvaluesFree ?? []) \(eigenvaluesValue ?? [])")
print("Eigenvectors namespace/free/value (expected normalized orthogonal vectors): \(eigenvectorsNamespace?.values ?? []) \(eigenvectorsFree?.values ?? []) \(eigenvectorsValue?.values ?? [])")

// Cholesky decomposition, log-determinant, and matrix right-hand-side solve:
// https://en.wikipedia.org/wiki/Cholesky_decomposition
let symmetricPositiveDefinite = Matrix([[4, 12, -16], [12, 37, -43], [-16, -43, 98]])!
let choleskyFactor = symmetricPositiveDefinite.choleskyDecomposition()
let logDet = symmetricPositiveDefinite.logDeterminant()
let identity = Matrix([[1, 0], [0, 1]])!
let matrixSolution = matrix.solve(identity)

print("Cholesky factor (expected [2, 0, 0, 6, 1, 0, -8, 5, 3]): \(choleskyFactor?.values ?? [])")
print("Log-determinant (expected log(det) = log(36) ~ 3.5835): \(logDet ?? .nan)")
print("Solve with identity right-hand side equals the inverse: \(matrixSolution?.values ?? [])")
