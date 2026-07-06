// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftNumerica",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "SwiftNumerica",
            targets: ["SwiftNumerica"]
        ),
        .library(
            name: "SwiftNumericaMLX",
            targets: ["SwiftNumericaMLX"]
        ),
    ],
    traits: [
        .trait(
            name: "MLX",
            description: "Enables MLX interoperability: Tensor, Matrix, and Vector conversions to and from MLXArray through the SwiftNumericaMLX product."
        ),
        .default(enabledTraits: []),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift", from: "0.31.0")
    ],
    targets: [
        .target(
            name: "CNumericaLAPACK",
            cSettings: [
                .define("ACCELERATE_NEW_LAPACK"),
                .define("ACCELERATE_LAPACK_ILP64"),
            ],
            linkerSettings: [
                .linkedFramework(
                    "Accelerate",
                    .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])
                )
            ]
        ),
        .target(
            name: "SwiftNumerica",
            dependencies: ["CNumericaLAPACK"]
        ),
        .target(
            name: "SwiftNumericaMLX",
            dependencies: [
                "SwiftNumerica",
                .product(name: "MLX", package: "mlx-swift", condition: .when(traits: ["MLX"])),
            ]
        ),
        .testTarget(
            name: "SwiftNumericaTests",
            dependencies: ["SwiftNumerica"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
