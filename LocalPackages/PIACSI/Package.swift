// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIACSI",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIACSI",
            targets: ["PIACSI"]
        )
    ],
    targets: [
        .target(
            name: "PIACSI"
        )
    ]
)
