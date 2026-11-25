// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIADebugMenu",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIADebugMenu",
            targets: ["PIADebugMenu"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIADebugMenu",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        ),
        .testTarget(
            name: "PIADebugMenuTests",
            dependencies: [
                "PIADebugMenu",
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        )
    ]
)
