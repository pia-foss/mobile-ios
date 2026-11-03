// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAVPNPermission",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIAVPNPermission",
            targets: ["PIAVPNPermission"]
        )
    ],
    dependencies: [
        .package(path: "../PIAAssets"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAUI"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.15.1")
    ],
    targets: [
        .target(
            name: "PIAVPNPermission",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations")
            ]
        ),
        .testTarget(
            name: "PIAVPNPermissionTests",
            dependencies: [
                "PIAVPNPermission",
                .product(name: "CoreArchitecture", package: "apple-core")
            ]
        )
    ]
)
