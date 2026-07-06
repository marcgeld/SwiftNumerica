import Foundation
import Testing

@testable import SwiftNumerica

@Test func matrixAndVectorExposeDimensionsAndValues() throws {
    let matrix = try #require(Matrix([[1, 2, 3], [4, 5, 6]]))
    let vector = Vector([7, 8, 9])

    #expect(matrix.rowCount == 2)
    #expect(matrix.columnCount == 3)
    #expect(matrix.values == [1, 2, 3, 4, 5, 6])
    #expect(matrix.rows == [[1, 2, 3], [4, 5, 6]])
    #expect(matrix[1, 2] == 6)
    #expect(vector.count == 3)
    #expect(vector[2] == 9)
}

@Test func matrixSubscriptTrapsOnOutOfBoundsIndexes() async throws {
    await #expect(processExitsWith: .failure) {
        let matrix = try #require(Matrix([[1, 2], [3, 4]]))
        _ = matrix[0, 2]
    }
    await #expect(processExitsWith: .failure) {
        let matrix = try #require(Matrix([[1, 2], [3, 4]]))
        _ = matrix[2, 0]
    }
}

@Test func determinantInverseAndSolveUseSquareMatrixAlgebra() throws {
    let matrix = try #require(Matrix([[4, 7], [2, 6]]))

    #expect(try #require(matrix.determinant()).isApproximatelyEqual(to: 10))

    let inverse = try #require(matrix.inverse())
    #expect(inverse[0, 0].isApproximatelyEqual(to: 0.6))
    #expect(inverse[0, 1].isApproximatelyEqual(to: -0.7))
    #expect(inverse[1, 0].isApproximatelyEqual(to: -0.2))
    #expect(inverse[1, 1].isApproximatelyEqual(to: 0.4))

    let solution = try #require(matrix.solve(Vector([1, 0])))
    #expect(solution.values[0].isApproximatelyEqual(to: 0.6))
    #expect(solution.values[1].isApproximatelyEqual(to: -0.2))
}

@Test func freeLinearAlgebraFunctionsDelegateToNamespace() throws {
    let matrix = try #require(Matrix([[1, 2], [3, 4]]))
    let vector = Vector([5, 11])

    #expect(try #require(determinant(matrix)).isApproximatelyEqual(to: -2))
    let solution = try #require(solve(matrix, vector))
    #expect(solution.values[0].isApproximatelyEqual(to: 1))
    #expect(solution.values[1].isApproximatelyEqual(to: 2))
    #expect(inverse(matrix) != nil)
}

@Test func eigenvaluesAndEigenvectorsWorkForSymmetricMatrices() throws {
    let matrix = try #require(Matrix([[2, 1], [1, 2]]))
    let values = try #require(matrix.eigenvalues())
    let vectors = try #require(matrix.eigenvectors())

    #expect(values[0].isApproximatelyEqual(to: 3, tolerance: 1e-10))
    #expect(values[1].isApproximatelyEqual(to: 1, tolerance: 1e-10))

    for column in 0..<vectors.columnCount {
        let vector = (0..<vectors.rowCount).map { vectors[$0, column] }
        let product = multiply(matrix, by: vector)
        for index in vector.indices {
            #expect(product[index].isApproximatelyEqual(to: values[column] * vector[index], tolerance: 1e-9))
        }
        #expect(norm(vector).isApproximatelyEqual(to: 1, tolerance: 1e-9))
    }
}

@Test func eigenDecompositionReturnsNilForNonSymmetricMatrices() throws {
    let matrix = try #require(Matrix([[0, 1], [-2, 0]]))

    #expect(matrix.eigenvalues() == nil)
    #expect(matrix.eigenvectors() == nil)
}

@Test func inverseRoundTripsForLargerMatrices() throws {
    let matrix = try #require(Matrix([[2, 1, 0], [1, 3, 1], [0, 1, 4]]))
    let inverse = try #require(matrix.inverse())

    for row in 0..<matrix.rowCount {
        for column in 0..<matrix.columnCount {
            let product = (0..<matrix.columnCount).map { entry in
                matrix[row, entry] * inverse[entry, column]
            }.reduce(0.0) { $0 + $1 }
            let expected = row == column ? 1.0 : 0.0
            #expect(product.isApproximatelyEqual(to: expected, tolerance: 1e-10))
        }
    }

    #expect(try #require(Matrix([[1, 2], [2, 4]])).inverse() == nil)
}

@Test func symmetryCheckToleratesRepresentationNoiseInLargeMatrices() throws {
    let large = 1e12
    // Off-diagonal entries differ by ~0.1 absolutely but only 1e-13 relatively,
    // so the matrix should still be treated as symmetric.
    let matrix = try #require(
        Matrix([
            [2 * large, large * (1 + 1e-13)],
            [large, large],
        ]))

    #expect(matrix.eigenvalues() != nil)
    #expect(matrix.eigenvectors() != nil)
}

private func multiply(_ matrix: Matrix, by vector: [Double]) -> [Double] {
    (0..<matrix.rowCount).map { row in
        (0..<matrix.columnCount).map { column in
            matrix[row, column] * vector[column]
        }.reduce(0.0) { $0 + $1 }
    }
}

private func norm(_ vector: [Double]) -> Double {
    vector.map { $0 * $0 }.reduce(0.0) { $0 + $1 }.squareRoot()
}

@Test func choleskyDecompositionFactorsSymmetricPositiveDefiniteMatrices() throws {
    // Classic reference example: A = L * Lt with known integer factor.
    let matrix = try #require(Matrix([[4, 12, -16], [12, 37, -43], [-16, -43, 98]]))
    let factor = try #require(matrix.choleskyDecomposition())
    let expected = [[2.0, 0, 0], [6, 1, 0], [-8, 5, 3]]

    for row in 0..<3 {
        for column in 0..<3 {
            #expect(factor[row, column].isApproximatelyEqual(to: expected[row][column], tolerance: 1e-10))
        }
    }

    // Non-positive-definite and non-symmetric inputs are rejected.
    #expect(try #require(Matrix([[1, 0], [0, -1]])).choleskyDecomposition() == nil)
    #expect(try #require(Matrix([[1, 2], [3, 4]])).choleskyDecomposition() == nil)
}

@Test func logDeterminantMatchesDeterminantForSPDMatrices() throws {
    let matrix = try #require(Matrix([[4, 1, 2], [1, 5, 3], [2, 3, 6]]))
    let logDet = try #require(matrix.logDeterminant())
    let determinant = try #require(matrix.determinant())

    #expect(logDet.isApproximatelyEqual(to: Foundation.log(determinant), tolerance: 1e-10))
    #expect(logDeterminant(matrix)?.isApproximatelyEqual(to: logDet) == true)
    #expect(try #require(Matrix([[1, 2], [3, 4]])).logDeterminant() == nil)
}

@Test func solveSupportsMatrixRightHandSides() throws {
    let matrix = try #require(Matrix([[4, 7], [2, 6]]))
    let rightHandSide = try #require(Matrix([[1, 0], [0, 1]]))
    let solution = try #require(matrix.solve(rightHandSide))

    // Solving against the identity yields the inverse.
    let inverse = try #require(matrix.inverse())
    for row in 0..<2 {
        for column in 0..<2 {
            #expect(solution[row, column].isApproximatelyEqual(to: inverse[row, column], tolerance: 1e-10))
        }
    }

    #expect(solve(matrix, rightHandSide) != nil)
    #expect(matrix.solve(try #require(Matrix([[1.0], [2], [3]]))) == nil)
}

@Test func symmetricRoutinesAcceptSinglePrecisionAsymmetry() throws {
    // Float32 round-tripping introduces relative asymmetry near 1e-7, which
    // must be symmetrized internally rather than rejected.
    let noisy = try #require(Matrix([[2, 1 + 1e-7], [1, 2]]))

    let values = try #require(noisy.eigenvalues())
    #expect(values[0].isApproximatelyEqual(to: 3, tolerance: 1e-6))
    #expect(values[1].isApproximatelyEqual(to: 1, tolerance: 1e-6))
    #expect(noisy.eigenvectors() != nil)

    let spdNoisy = try #require(Matrix([[4, 1 + 1e-7], [1, 4]]))
    #expect(spdNoisy.choleskyDecomposition() != nil)
    #expect(spdNoisy.logDeterminant() != nil)
}
