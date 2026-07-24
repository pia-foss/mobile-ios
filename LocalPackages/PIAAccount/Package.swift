// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PIAAccount",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PIAAccount",
            targets: ["PIAAccount"]
        )
    ],
    dependencies: [
        .package(path: "../PIABase")
    ],
    targets: [
        // Main library target (merged for simplicity)
        .target(
            name: "PIAAccount",
            dependencies: [
                .product(name: "PIABase", package: "PIABase")
            ],
            path: "Sources"
        ),
        // Test target using Swift Testing
        .testTarget(
            name: "PIAAccountTests",
            dependencies: ["PIAAccount"]
        )
    ]
)
