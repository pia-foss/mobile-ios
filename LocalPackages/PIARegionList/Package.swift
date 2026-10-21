// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIARegionList",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17),
    ],
    products: [
        // Shared with tvOS: region filtering, sorting and search history.
        .library(
            name: "PIARegionListDomain",
            targets: ["PIARegionListDomain"]
        ),
        // iOS region selection screen.
        .library(
            name: "PIARegionList",
            targets: ["PIARegionList"]
        ),
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIAFavorites"),
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAAssets"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0"),
    ],
    targets: [
        .target(
            name: "PIARegionListDomain",
            dependencies: [
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIAFavorites", package: "PIAFavorites"),
            ]
        ),
        .target(
            name: "PIARegionList",
            dependencies: [
                "PIARegionListDomain",
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIAFavorites", package: "PIAFavorites"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets", condition: .when(platforms: [.iOS])),
                .product(name: "PIAAssetsFlags", package: "PIAAssets", condition: .when(platforms: [.iOS])),
            ]
        ),
        .testTarget(
            name: "PIARegionListTests",
            dependencies: [
                "PIARegionList",
                "PIARegionListDomain",
                .product(name: "CoreArchitecture", package: "apple-core"),
            ]
        ),
    ]
)
