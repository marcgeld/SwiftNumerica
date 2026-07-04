// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNumericaMLX",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SwiftNumericaMLX",
            targets: ["SwiftNumericaMLX"]
        )
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.31.0"),
    ],
    targets: [
        .target(
            name: "SwiftNumericaMLX",
            dependencies: [
                .product(name: "SwiftNumerica", package: "SwiftNumerica"),
                .product(name: "MLX", package: "mlx-swift"),
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
