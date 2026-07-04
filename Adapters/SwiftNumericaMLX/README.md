# SwiftNumericaMLX

SwiftNumericaMLX is an optional adapter package for converting SwiftNumerica
tensors to MLX arrays.

The main `SwiftNumerica` package does not depend on MLX. Projects that need MLX
interoperability can add this adapter as a separate dependency and import it
alongside `SwiftNumerica`.

## Usage

```swift
import SwiftNumerica
import SwiftNumericaMLX

let tensor = Tensor.vector([1, 2, 3])
let array = tensor.mlxArray()
let roundTrip = Tensor<Double>(mlxArray: array)
```

## Package Dependency

When working from this repository, add the adapter as a local package:

```swift
dependencies: [
    .package(path: "path/to/SwiftNumerica/Adapters/SwiftNumericaMLX")
]
```

Then depend on the adapter product from that package:

```swift
.product(name: "SwiftNumericaMLX", package: "SwiftNumericaMLX")
```

For public distribution, publish this adapter as its own package/repository so
projects that only need `SwiftNumerica` do not resolve MLX at all.

## Build Notes

This adapter depends on Apple's MLX Swift package. MLX's documentation notes
that SwiftPM command-line builds cannot build Metal shaders by themselves; final
application builds that use MLX may need to be performed with Xcode or
`xcodebuild`.
