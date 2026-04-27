// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAKPI",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIAKPI",
            targets: ["PIAKPI"]
        )
    ],
    targets: [
        .target(
            name: "PIAKPI"
        )
    ]
)
