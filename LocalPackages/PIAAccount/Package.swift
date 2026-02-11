// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PIAAccountSwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PIAAccountSwift",
            targets: ["PIAAccountSwift"]
        ),
    ],
    targets: [
        // Main library target (merged for simplicity)
        .target(
            name: "PIAAccountSwift",
            dependencies: [],
            path: "Sources"
        ),
        // Test target using Swift Testing
        .testTarget(
            name: "PIAAccountTests",
            dependencies: ["PIAAccountSwift"]
        ),
    ]
)
