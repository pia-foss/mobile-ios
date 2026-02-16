// swift-tools-version: 5.10
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
        ),
    ],
    targets: [
        // Main library target (merged for simplicity)
        .target(
            name: "PIAAccount",
            dependencies: [],
            path: "Sources"
        ),
        // Test target using Swift Testing
        .testTarget(
            name: "PIAAccountTests",
            dependencies: ["PIAAccount"]
        ),
    ]
)
