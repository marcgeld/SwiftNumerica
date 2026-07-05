# SwiftNumericaMLX

SwiftNumericaMLX is an optional adapter package for converting SwiftNumerica
tensors to MLX arrays.

The main `SwiftNumerica` package does not depend on MLX. Projects that need MLX
interoperability can add this adapter as a separate dependency and import it
alongside `SwiftNumerica`.

This adapter is part of the SwiftNumerica 0.1.0 release, but it remains a
separate Swift package so MLX is never resolved by projects that only depend on
the core `SwiftNumerica` product.

## Usage

```swift
import SwiftNumerica
import SwiftNumericaMLX

let tensor = Tensor.vector([1, 2, 3])
let array = tensor.mlxArray()
let roundTrip = Tensor<Double>(mlxArray: array)
```

## Package Dependency

When working from this repository or a checkout of a release tag, add both the
core package and the adapter package by path:

```swift
dependencies: [
    .package(path: "path/to/SwiftNumerica"),
    .package(path: "path/to/SwiftNumerica/Adapters/SwiftNumericaMLX")
]
```

Then depend on both products from your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SwiftNumerica", package: "SwiftNumerica"),
        .product(name: "SwiftNumericaMLX", package: "SwiftNumericaMLX"),
    ]
)
```

Swift Package Manager resolves Git package dependencies from a repository's root
`Package.swift`, so a nested adapter package cannot be consumed directly from
the same repository URL without also making MLX visible to the core package. The
path-based layout keeps the 0.1.0 adapter release-tested while preserving the
core package's no-MLX dependency contract.

## Build Notes

This adapter depends on Apple's MLX Swift package. MLX's documentation notes
that SwiftPM command-line builds cannot build Metal shaders by themselves; final
application builds that use MLX may need to be performed with Xcode or
`xcodebuild`.

In practice, `swift build` is a useful compile-time check for the adapter, but a
plain `swift run` executable that evaluates an `MLXArray` may fail at runtime
with an error such as `Failed to load the default metallib` if MLX's Metal
library has not been bundled. That is an MLX runtime packaging requirement, not
a SwiftNumerica linkage error.
