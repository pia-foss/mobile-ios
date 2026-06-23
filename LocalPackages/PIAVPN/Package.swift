// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PIAVPN",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIAVPN",
            targets: ["PIAVPN"]
        )
    ],
    dependencies: [
        .package(path: "../KapePlatformSDK"),
        .package(path: "../PIALibrary")
    ],
    targets: [
        .target(
            name: "PIAVPN",
            dependencies: [
                .product(name: "KapeVPN-OpenVPN", package: "KapePlatformSDK"),
                .product(name: "KapeVPN-PacketTunnel", package: "KapePlatformSDK"),
                .product(name: "PIALibrary", package: "PIALibrary")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
