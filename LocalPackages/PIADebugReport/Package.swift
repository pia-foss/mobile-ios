// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIADebugReport",
    defaultLocalization: "en",
    // iOS only: the Help settings flow this screen belongs to is iOS/Mac Catalyst.
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
    ],
    products: [
        .library(
            name: "PIADebugReport",
            targets: ["PIADebugReport"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0"),
    ],
    targets: [
        .target(
            name: "PIADebugReport",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
            ]
        ),
        .testTarget(
            name: "PIADebugReportTests",
            dependencies: [
                "PIADebugReport",
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
            ]
        ),
    ]
)
