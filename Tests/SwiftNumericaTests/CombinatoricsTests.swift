import Testing
@testable import SwiftNumerica

@Test func factorialOfZeroIsOne() {
    #expect(Numerica.Combinatorics.factorial(0) == 1)
}

@Test func factorialOfOneIsOne() {
    #expect(Numerica.Combinatorics.factorial(1) == 1)
}

@Test func factorialOfFiveIsOneHundredTwenty() {
    #expect(Numerica.Combinatorics.factorial(5) == 120)
}

@Test func factorialReturnsNilForInvalidInput() {
    #expect(Numerica.Combinatorics.factorial(-1) == nil)
}

@Test func permutationsForTenChooseThree() {
    #expect(Numerica.Combinatorics.permutations(n: 10, r: 3) == 720)
}

@Test func combinationsForTenChooseThree() {
    #expect(Numerica.Combinatorics.combinations(n: 10, r: 3) == 120)
}

@Test func combinationsForFifteenChooseTen() {
    #expect(Numerica.Combinatorics.combinations(n: 15, r: 10) == 3003)
}
