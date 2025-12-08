// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "PIADesignSystem",
    platforms: [
        .iOS(.v12),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "PIADesignSystem",
            targets: ["PIADesignSystem"]
        )
    ],
    targets: [
        .target(
            name: "PIADesignSystem",
            resources: [
                .process("Colors/Colors.xcassets")
            ]
        ),
        .testTarget(
            name: "PIADesignSystemTests",
            dependencies: ["PIADesignSystem"]
        )
    ]
)
