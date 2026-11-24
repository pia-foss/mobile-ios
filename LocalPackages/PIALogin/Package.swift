// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIALogin",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIALogin",
            targets: ["PIALogin"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAUI"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIALogin",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations")
            ]
        ),
        .testTarget(
            name: "PIALoginTests",
            dependencies: [
                "PIALogin",
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        )
    ]
)
