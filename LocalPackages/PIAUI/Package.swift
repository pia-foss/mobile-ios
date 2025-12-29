// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PIAUI",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIADesignSystem",
            targets: ["PIADesignSystem"]
        ),
        .library(
            name: "PIAUIKit",
            targets: ["PIAUIKit"]
        ),
        .library(
            name: "PIASwiftUI",
            targets: ["PIASwiftUI"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.18.7"),
        .package(url: "https://github.com/nicklockwood/FXPageControl.git", branch: "master")
    ],
    targets: [
        .target(
            name: "PIADesignSystem",
            resources: [
                .process("Colors/Colors.xcassets")
            ]
        ),
        .target(
            name: "PIAUIKit",
            dependencies: [
                "PIADesignSystem",
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "FXPageControl", package: "FXPageControl")
            ]
        ),
        .target(
            name: "PIASwiftUI",
            dependencies: ["PIADesignSystem"]
        ),
        .testTarget(
            name: "PIADesignSystemTests",
            dependencies: [
                "PIADesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "PIAUIKitTests",
            dependencies: ["PIAUIKit"]
        ),
        .testTarget(
            name: "PIASwiftUITests",
            dependencies: ["PIASwiftUI"]
        )
    ]
)
