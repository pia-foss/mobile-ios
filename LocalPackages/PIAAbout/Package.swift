// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAAbout",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIAAbout",
            targets: ["PIAAbout"]
        )
    ],
    dependencies: [
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIAAbout",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations")
            ],
            resources: [.process("Resources")]
        )
    ]
)
