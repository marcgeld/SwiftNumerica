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
        )
    ],
    targets: [
        .target(
            name: "SwiftNumerica"
        ),
        .testTarget(
            name: "SwiftNumericaTests",
            dependencies: ["SwiftNumerica"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
