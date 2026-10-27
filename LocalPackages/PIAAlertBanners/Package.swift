// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAAlertBanners",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIAAlertBanners",
            targets: ["PIAAlertBanners"]
        )
    ],
    dependencies: [
        .package(path: "../PIAUI")
    ],
    targets: [
        .target(
            name: "PIAAlertBanners",
            dependencies: [
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI")
            ]
        ),
        .testTarget(
            name: "PIAAlertBannersTests",
            dependencies: ["PIAAlertBanners"]
        )
    ]
)
