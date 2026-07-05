import SwiftNumerica

// Combinatorics:
// https://en.wikipedia.org/wiki/Combinatorics
//
// This example computes factorials, combinations, and permutations.

let factorial = Numerica.Combinatorics.factorial(5)
let combinations = Numerica.Combinatorics.combinations(n: 10, r: 3)
let permutations = Numerica.Combinatorics.permutations(n: 10, r: 3)

print("5! (expected 5 x 4 x 3 x 2 x 1 = 120): \(factorial ?? -1)")
print("10 choose 3 (expected 10! / (3! x 7!) = 120): \(combinations ?? -1)")
print("10 permute 3 (expected 10 x 9 x 8 = 720): \(permutations ?? -1)")
