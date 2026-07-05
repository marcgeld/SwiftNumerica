import SwiftNumerica

// Linear algebra:
// https://en.wikipedia.org/wiki/Linear_algebra
//
// This example uses Matrix and Vector with determinant, inverse, solve,
// eigenvalues, and eigenvectors APIs.

let matrix = Matrix([[4, 7], [2, 6]])!
let vector = Vector([1, 0])
let symmetric = Matrix([[2, 1], [1, 2]])!

print("Matrix values:", matrix.values)
print("Vector values:", vector.values)
print("Determinant namespace/free/value:", Numerica.LinearAlgebra.determinant(matrix) ?? .nan, determinant(matrix) ?? .nan, matrix.determinant() ?? .nan)
print("Inverse namespace/free/value:", Numerica.LinearAlgebra.inverse(matrix)?.values ?? [], inverse(matrix)?.values ?? [], matrix.inverse()?.values ?? [])
print("Solve namespace/free/value:", Numerica.LinearAlgebra.solve(matrix, vector)?.values ?? [], solve(matrix, vector)?.values ?? [], matrix.solve(vector)?.values ?? [])
print("Eigenvalues namespace/free/value:", Numerica.LinearAlgebra.eigenvalues(symmetric) ?? [], eigenvalues(symmetric) ?? [], symmetric.eigenvalues() ?? [])
print("Eigenvectors namespace/free/value:", Numerica.LinearAlgebra.eigenvectors(symmetric)?.values ?? [], eigenvectors(symmetric)?.values ?? [], symmetric.eigenvectors()?.values ?? [])

