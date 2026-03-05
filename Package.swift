// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PIAWireguard",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIAWireguard",
            targets: [
                "PIAWireguard",
                "PIAWireguardC",
                "PIAWireguardGo",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git", exact: "1.1.0"),
        .package(url: "git@github.com:pia-foss/mobile-ios-networking.git", exact: "1.3.1"),
    ],
    targets: [
        .target(
            name: "PIAWireguard",
            dependencies: [
                "PIAWireguardC",
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "NWHttpConnection", package: "mobile-ios-networking")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "PIAWireguardC",
            dependencies: [ ]
        ),
        .binaryTarget(
            name: "PIAWireguardGo",
            path: "PIAWireguardGo.xcframework"
        ),
    ]
)

