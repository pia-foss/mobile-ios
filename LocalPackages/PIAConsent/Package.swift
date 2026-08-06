// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAConsent",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PIAConsent",
            targets: ["PIAConsent"]
        )
    ],
    dependencies: [
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAAssets")
    ],
    targets: [
        .target(
            name: "PIAConsent",
            dependencies: [
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets")
            ]
        ),
        .testTarget(
            name: "PIAConsentTests",
            dependencies: ["PIAConsent"]
        )
    ]
)
