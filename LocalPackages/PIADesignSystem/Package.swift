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
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.7")
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
            dependencies: [
                "PIADesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        )
    ]
)
