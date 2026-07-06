#ifndef C_NUMERICA_LAPACK_H
#define C_NUMERICA_LAPACK_H

/// Thin C wrappers around Accelerate's modern LAPACK interface
/// (ACCELERATE_NEW_LAPACK with ACCELERATE_LAPACK_ILP64, Apple's recommended
/// configuration for new code). The wrappers exist because the macros must be
/// defined when the Accelerate Clang module is consumed, which Swift targets
/// cannot arrange without unsafe compiler flags.
///
/// All matrices use LAPACK's column-major convention. SwiftNumerica passes
/// row-major buffers, which LAPACK therefore sees as transposed; callers
/// account for that (determinants are transpose-invariant, the inverse of a
/// transpose is the transposed inverse, and solves request the transposed
/// system).
///
/// Every function returns the LAPACK `info` code: `0` on success, `> 0` for
/// numerical failures such as exact singularity, `< 0` for invalid arguments,
/// and `-1000` when Accelerate is unavailable or memory allocation fails.

/// Returns 1 when Accelerate's LAPACK is available in this build.
int sn_lapack_available(void);

/// LU-factorizes an `n x n` matrix in place with partial pivoting (dgetrf).
/// `pivots` must hold `n` entries.
int sn_dgetrf(long n, double *matrix, long *pivots);

/// Inverts an LU-factorized matrix in place (dgetri).
int sn_dgetri(long n, double *matrix, const long *pivots);

/// Solves `transpose(factored) * X = rhs` for `rightHandSideCount` columns
/// using an LU factorization from `sn_dgetrf` (dgetrs with TRANS = 'T').
/// `rhs` holds the right-hand sides in column-major `n x rightHandSideCount`
/// layout and is overwritten with the solution.
int sn_dgetrs_transposed(
    long n,
    long rightHandSideCount,
    const double *factored,
    const long *pivots,
    double *rhs
);

/// Cholesky-factorizes a symmetric positive definite `n x n` matrix in place
/// (dpotrf with UPLO = 'U'). Because LAPACK sees the row-major buffer as its
/// transpose, the computed factor occupies the row-major lower triangle; the
/// row-major upper triangle keeps its original values and callers must zero
/// it. Returns `info > 0` when the matrix is not positive definite.
int sn_dpotrf(long n, double *matrix);

/// Computes eigenvalues (ascending) and, when `computeVectors` is nonzero,
/// orthonormal eigenvectors of a symmetric `n x n` matrix in place (dsyev).
/// On success with vectors, the matrix buffer holds the eigenvectors in
/// LAPACK column-major layout.
int sn_dsyev(long n, double *matrix, double *eigenvalues, int computeVectors);

#endif
