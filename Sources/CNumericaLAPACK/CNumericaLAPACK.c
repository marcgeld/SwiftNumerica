// ACCELERATE_NEW_LAPACK is defined through the package manifest's cSettings:
// the Accelerate headers are consumed as a Clang module, so the macro must be
// present on the compiler command line rather than in this source file.
#include "include/CNumericaLAPACK.h"

#if __has_include(<Accelerate/Accelerate.h>)

#include <Accelerate/Accelerate.h>
#include <stdlib.h>

int sn_lapack_available(void) {
    return 1;
}

int sn_dgetrf(long n, double *matrix, long *pivots) {
    __LAPACK_int info = 0;
    __LAPACK_int dimension = n;
    dgetrf_(&dimension, &dimension, matrix, &dimension, pivots, &info);
    return (int)info;
}

int sn_dgetri(long n, double *matrix, const long *pivots) {
    __LAPACK_int info = 0;
    __LAPACK_int dimension = n;
    __LAPACK_int workCount = -1;
    double workQuery = 0;
    dgetri_(&dimension, matrix, &dimension, (__LAPACK_int *)pivots, &workQuery, &workCount, &info);
    if (info != 0) {
        return (int)info;
    }

    workCount = (__LAPACK_int)workQuery;
    double *work = malloc((size_t)workCount * sizeof(double));
    if (work == NULL) {
        return -1000;
    }
    dgetri_(&dimension, matrix, &dimension, (__LAPACK_int *)pivots, work, &workCount, &info);
    free(work);
    return (int)info;
}

int sn_dgetrs_transposed(long n, const double *factored, const long *pivots, double *rhs) {
    __LAPACK_int info = 0;
    __LAPACK_int dimension = n;
    __LAPACK_int rightHandSides = 1;
    dgetrs_(
        "T",
        &dimension,
        &rightHandSides,
        (double *)factored,
        &dimension,
        (__LAPACK_int *)pivots,
        rhs,
        &dimension,
        &info
    );
    return (int)info;
}

int sn_dsyev(long n, double *matrix, double *eigenvalues, int computeVectors) {
    __LAPACK_int info = 0;
    __LAPACK_int dimension = n;
    __LAPACK_int workCount = -1;
    double workQuery = 0;
    const char *jobz = computeVectors ? "V" : "N";
    dsyev_(jobz, "U", &dimension, matrix, &dimension, eigenvalues, &workQuery, &workCount, &info);
    if (info != 0) {
        return (int)info;
    }

    workCount = (__LAPACK_int)workQuery;
    double *work = malloc((size_t)workCount * sizeof(double));
    if (work == NULL) {
        return -1000;
    }
    dsyev_(jobz, "U", &dimension, matrix, &dimension, eigenvalues, work, &workCount, &info);
    free(work);
    return (int)info;
}

#else

int sn_lapack_available(void) {
    return 0;
}

int sn_dgetrf(long n, double *matrix, long *pivots) {
    (void)n;
    (void)matrix;
    (void)pivots;
    return -1000;
}

int sn_dgetri(long n, double *matrix, const long *pivots) {
    (void)n;
    (void)matrix;
    (void)pivots;
    return -1000;
}

int sn_dgetrs_transposed(long n, const double *factored, const long *pivots, double *rhs) {
    (void)n;
    (void)factored;
    (void)pivots;
    (void)rhs;
    return -1000;
}

int sn_dsyev(long n, double *matrix, double *eigenvalues, int computeVectors) {
    (void)n;
    (void)matrix;
    (void)eigenvalues;
    (void)computeVectors;
    return -1000;
}

#endif
