// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIARegions",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIARegions",
            targets: ["PIARegions"]
        )
    ],
    targets: [
        .target(
            name: "PIARegions",
            path: "Sources/Regions"
        ),
        .testTarget(
            name: "PIARegionsTests",
            dependencies: ["PIARegions"],
            path: "Tests/RegionsTests"
        )
    ]
)
