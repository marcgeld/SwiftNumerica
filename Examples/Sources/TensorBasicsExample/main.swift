import SwiftNumerica

// Tensor basics:
// https://en.wikipedia.org/wiki/Tensor
//
// This example shows how SwiftNumerica represents scalars, vectors, matrices,
// shapes, tensor indices, vectors, matrices, and reshaping.

let scalar = Tensor.scalar(3.14)
let vector = Tensor.vector([1, 2, 3, 4])
let matrixTensor = Tensor.matrix([[1, 2], [3, 4]])!
let multidimensional = Tensor.multidimensional([1, 2, 3, 4, 5, 6], dimensions: [1, 2, 3])!
let reshaped = try! vector.reshaped(to: [2, 2])
let shape = Shape([2, 2])!
let index = TensorIndex([1, 0])!
let wrappedVector = Vector(vector)
let matrix = Matrix([[1, 2], [3, 4]])!
let matrixFromValues = Matrix(values: [1, 2, 3, 4], rows: 2, columns: 2)!
let matrixFromTensor = Matrix(matrixTensor)!

print("Scalar:", scalar.values, "rank:", scalar.rank)
print("Vector:", vector.values, "shape:", vector.shape.dimensions)
print("Matrix tensor:", matrixTensor.values, "shape:", matrixTensor.shape.dimensions)
print("Multidimensional tensor:", multidimensional.shape.dimensions)
print("Reshaped vector:", reshaped.shape.dimensions, reshaped.values)
print("Shape equals [2, 2]:", shape == [2, 2])
print("Tensor index:", index.coordinates)
print("Vector wrapper count:", wrappedVector?.count ?? 0, "second value:", wrappedVector?[1] ?? .nan)
print("Matrix dimensions:", matrix.rowCount, "x", matrix.columnCount, "values:", matrix.values)
print("Matrix from values:", matrixFromValues.values)
print("Matrix from tensor:", matrixFromTensor.values)
