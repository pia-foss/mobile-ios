// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAAccountDetails",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIAAccountDetails",
            targets: ["PIAAccountDetails"]
        )
    ],
    dependencies: [
        .package(path: "../PIAAssets"),
        .package(path: "../PIALibrary"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAUI"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIAAccountDetails",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations")
            ]
        ),
        .testTarget(
            name: "PIAAccountDetailsTests",
            dependencies: [
                "PIAAccountDetails",
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        )
    ]
)
