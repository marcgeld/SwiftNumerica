import Testing
@testable import SwiftNumerica

@Test func tensorScalarHasRankZeroAndCountOne() {
    let tensor = Tensor.scalar(42)
    #expect(tensor.rank == 0)
    #expect(tensor.count == 1)
    #expect(tensor.values == [42])
}

@Test func tensorVectorHasRankOne() {
    let tensor = Tensor.vector([1, 2, 3])
    #expect(tensor.rank == 1)
    #expect(tensor.shape.dimensions == [3])
}

@Test func tensorMatrixValidatesShape() throws {
    let tensor = try #require(Tensor.matrix([[1, 2], [3, 4]]))
    #expect(tensor.rank == 2)
    #expect(tensor.shape.dimensions == [2, 2])
    #expect(tensor.values == [1, 2, 3, 4])
    #expect(Tensor.matrix([[1], [2, 3]]) == nil)
}

@Test func tensorMultidimensionalValidatesElementCount() {
    #expect(Tensor.multidimensional([1, 2, 3, 4], dimensions: [2, 2]) != nil)
    #expect(Tensor.multidimensional([1, 2, 3], dimensions: [2, 2]) == nil)
}

@Test func tensorReshapePreservesRowMajorStorage() throws {
    let tensor = Tensor.vector([1, 2, 3, 4, 5, 6])
    let reshaped = try tensor.reshaped(to: [2, 3])

    #expect(reshaped.shape == [2, 3])
    #expect(reshaped.rank == 2)
    #expect(reshaped.values == [1, 2, 3, 4, 5, 6])
}

@Test func tensorCanReshapeToScalarShape() throws {
    let tensor = Tensor.vector([42])
    let reshaped = try tensor.reshaped(to: [])

    #expect(reshaped.shape == [])
    #expect(reshaped.rank == 0)
    #expect(reshaped.values == [42])
}

@Test func tensorReshapeRejectsNonPositiveDimensions() {
    let tensor = Tensor.vector([1, 2, 3, 4])

    #expect(throws: TensorError.invalidShape) {
        try tensor.reshaped(to: [2, 0])
    }

    #expect(throws: TensorError.invalidShape) {
        try tensor.reshaped(to: [2, -2])
    }
}

@Test func tensorReshapeRejectsIncompatibleElementCount() {
    let tensor = Tensor.vector([1, 2, 3, 4, 5, 6])

    #expect(throws: TensorError.incompatibleShape) {
        try tensor.reshaped(to: [4, 4])
    }
}
