// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIADedicatedIP",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIADedicatedIP",
            targets: ["PIADedicatedIP"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAAssets"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIADedicatedIP",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets", condition: .when(platforms: [.iOS])),
                .product(name: "PIAAssetsFlags", package: "PIAAssets", condition: .when(platforms: [.iOS]))
            ]
        )
    ]
)
