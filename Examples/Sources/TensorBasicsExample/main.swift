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
let shapeMatches = shape == [2, 2]
let secondVectorValue = wrappedVector?[1]

print("Scalar (expected values [3.14], rank 0): \(scalar.values) rank: \(scalar.rank)")
print("Vector (expected values [1, 2, 3, 4], shape [4]): \(vector.values) shape: \(vector.shape.dimensions)")
print("Matrix tensor (expected row-major values [1, 2, 3, 4], shape [2, 2]): \(matrixTensor.values) shape: \(matrixTensor.shape.dimensions)")
print("Multidimensional tensor shape (expected [1, 2, 3]): \(multidimensional.shape.dimensions)")
print("Reshaped vector (expected shape [2, 2] with original values): \(reshaped.shape.dimensions) \(reshaped.values)")
print("Shape equals [2, 2] (expected true): \(shapeMatches)")
print("Tensor index (expected coordinates [1, 0]): \(index.coordinates)")
print("Vector wrapper count and second value (expected count 4, second value 2): \(wrappedVector?.count ?? 0) \(secondVectorValue ?? .nan)")
print("Matrix dimensions and values (expected 2 x 2 and [1, 2, 3, 4]): \(matrix.rowCount) x \(matrix.columnCount) values: \(matrix.values)")
print("Matrix from values (expected [1, 2, 3, 4]): \(matrixFromValues.values)")
print("Matrix from tensor (expected [1, 2, 3, 4]): \(matrixFromTensor.values)")
