// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIADebugMenu",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PIADebugMenu",
            targets: ["PIADebugMenu"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary")
    ],
    targets: [
        .target(
            name: "PIADebugMenu",
            dependencies: [
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        )
    ]
)
