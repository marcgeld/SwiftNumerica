import Testing

@testable import SwiftNumerica

@Test func linearRegressionModelFitsAndPredicts() throws {
    let model = LinearRegression()
    let result = try #require(model.fit(.vector([1, 2, 3]), .vector([3, 5, 7])))

    #expect(result.slope.isApproximatelyEqual(to: 2))
    #expect(result.intercept.isApproximatelyEqual(to: 1))
    #expect(result.rSquared.isApproximatelyEqual(to: 1))
    #expect(result.predict(4).isApproximatelyEqual(to: 9))

    let predictions = try #require(result.predict(.vector([4, 5])))
    #expect(predictions.values[0].isApproximatelyEqual(to: 9))
    #expect(predictions.values[1].isApproximatelyEqual(to: 11))
}

@Test func polynomialRegressionModelFitsQuadratic() throws {
    let model = try #require(PolynomialRegression(degree: 2))
    let x = Tensor.vector([-2, -1, 0, 1, 2])
    let y = Tensor.vector(x.values.map { 1 + 2 * $0 + 3 * $0 * $0 })
    let result = try #require(model.fit(x, y))

    #expect(result.degree == 2)
    #expect(result.coefficients[0].isApproximatelyEqual(to: 1, tolerance: 1e-10))
    #expect(result.coefficients[1].isApproximatelyEqual(to: 2, tolerance: 1e-10))
    #expect(result.coefficients[2].isApproximatelyEqual(to: 3, tolerance: 1e-10))
    #expect(result.rSquared.isApproximatelyEqual(to: 1, tolerance: 1e-10))
    #expect(result.predict(3).isApproximatelyEqual(to: 34, tolerance: 1e-10))
}

@Test func polynomialRegressionNamespaceFunctionDelegatesToModel() throws {
    let x = Tensor.vector([-2, -1, 0, 1, 2])
    let y = Tensor.vector(x.values.map { 1 + $0 * $0 })
    let result = try #require(Numerica.Statistics.polynomialRegression(x: x, y: y, degree: 2))

    #expect(result.predict(4).isApproximatelyEqual(to: 17, tolerance: 1e-10))
}

@Test func polynomialRegressionRejectsInvalidDegree() {
    #expect(PolynomialRegression(degree: -1) == nil)
}

@Test func logisticRegressionModelFitsBinaryClassifier() throws {
    let features = try #require(
        Tensor.matrix([
            [0],
            [1],
            [2],
            [3],
        ]))
    let target = Tensor.vector([0, 0, 1, 1])
    let model = try #require(LogisticRegression(learningRate: 0.5, iterations: 2_000))
    let result = try #require(model.fit(features: features, target: target))

    #expect(try #require(result.predict(.vector([0]))) == 0)
    #expect(try #require(result.predict(.vector([3]))) == 1)
}
