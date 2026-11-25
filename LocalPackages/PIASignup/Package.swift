// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIASignup",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIASignup",
            targets: ["PIASignup"]
        )
    ],
    dependencies: [
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAUI")
    ],
    targets: [
        .target(
            name: "PIASignup",
            dependencies: [
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations")
            ]
        )
    ]
)
