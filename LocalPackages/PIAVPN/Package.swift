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
        .package(path: "../PIALibrary"),
        .package(url: "git@github.com:pia-foss/mobile-ios-networking.git", exact: "1.3.2")
    ],
    targets: [
        .target(
            name: "PIAVPN",
            dependencies: [
                .product(name: "KapeVPN-OpenVPN", package: "KapePlatformSDK"),
                .product(name: "KapeVPN-PacketTunnel", package: "KapePlatformSDK"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "NWHttpConnection", package: "mobile-ios-networking")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
