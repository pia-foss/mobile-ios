// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PIADesignSystem",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
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
