import SwiftNumerica

// Combinatorics:
// https://en.wikipedia.org/wiki/Combinatorics
//
// This example computes factorials, combinations, and permutations.

print("5! (expected 120):", Numerica.Combinatorics.factorial(5) ?? -1)
print("10 choose 3 (expected 120):", Numerica.Combinatorics.combinations(n: 10, r: 3) ?? -1)
print("10 permute 3 (expected 720):", Numerica.Combinatorics.permutations(n: 10, r: 3) ?? -1)
