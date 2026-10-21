// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAFavorites",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "PIAFavorites",
            targets: ["PIAFavorites"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary")
    ],
    targets: [
        .target(
            name: "PIAFavorites",
            dependencies: [
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        ),
        .testTarget(
            name: "PIAFavoritesTests",
            dependencies: [
                "PIAFavorites",
                .product(name: "PIALibrary", package: "PIALibrary"),
            ]
        ),
    ]
)
