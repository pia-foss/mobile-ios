// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIADashboard",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "PIADashboard",
            targets: ["PIADashboard"],
        ),
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIALocalizations"),
    ],
    targets: [
        .target(
            name: "PIADashboard",
            dependencies: [
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
            ],
        ),
    ],
)
