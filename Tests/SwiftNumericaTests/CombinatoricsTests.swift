import Testing
@testable import SwiftNumerica

@Test func factorialOfZeroIsOne() throws {
    #expect(try Numerica.Combinatorics.factorial(0) == 1)
}

@Test func factorialOfOneIsOne() throws {
    #expect(try Numerica.Combinatorics.factorial(1) == 1)
}

@Test func factorialOfFiveIsOneHundredTwenty() throws {
    #expect(try Numerica.Combinatorics.factorial(5) == 120)
}

@Test func factorialReturnsNilForInvalidInput() throws {
    #expect(try Numerica.Combinatorics.factorial(-1) == nil)
}

@Test func permutationsForTenChooseThree() throws {
    #expect(try Numerica.Combinatorics.permutations(n: 10, r: 3) == 720)
}

@Test func combinationsForTenChooseThree() throws {
    #expect(try Numerica.Combinatorics.combinations(n: 10, r: 3) == 120)
}

@Test func combinationsForFifteenChooseTen() throws {
    #expect(try Numerica.Combinatorics.combinations(n: 15, r: 10) == 3003)
}

@Test func combinatoricsReturnsNilInsteadOfOverflowing() throws {
    #expect(try Numerica.Combinatorics.factorial(21) == nil)
    #expect(try Numerica.Combinatorics.permutations(n: 30, r: 25) == nil)
}
