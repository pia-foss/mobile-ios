// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIASettings",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIASettings",
            targets: ["PIASettings"]
        )
    ],
    dependencies: [
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAUI"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIASettings",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIASwiftUI", package: "PIAUI")
            ]
        )
    ]
)
