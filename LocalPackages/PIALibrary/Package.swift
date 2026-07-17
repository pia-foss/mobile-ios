// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PIALibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "PIALibrary",
            targets: ["PIALibrary"]
        )
    ],
    dependencies: [
        .package(path: "../PIAKPI"),
        .package(path: "../PIACSI"),
        .package(path: "../PIAAccount"),
        .package(path: "../PIARegions"),
        .package(url: "git@github.com:pia-foss/mobile-ios-networking.git", exact: "1.3.2"),
        .package(url: "git@github.com:pia-foss/mobile-ios-openvpn.git", exact: "2.2.6"),
        .package(url: "git@github.com:pia-foss/mobile-ios-wireguard.git", exact: "1.0.6"),
        .package(url: "https://github.com/apple/swift-algorithms", exact: "1.2.1"),
        .package(url: "https://github.com/apple/swift-log", exact: "1.13.1"),
        .package(url: "https://github.com/ashleymills/Reachability.swift.git", exact: "5.2.4")
    ],
    targets: [
        .target(
            name: "PIALibrary",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "PIAKPI", package: "PIAKPI"),
                .product(name: "PIACSI", package: "PIACSI"),
                .product(name: "PIARegions", package: "PIARegions"),
                .product(name: "PIAAccount", package: "PIAAccount"),
                .product(
                    name: "PIAWireguard",
                    package: "mobile-ios-wireguard",
                    condition: .when(platforms: [.iOS, .macCatalyst])
                ),
                .product(
                    name: "TunnelKit",
                    package: "mobile-ios-openvpn",
                    condition: .when(platforms: [.iOS, .macCatalyst])
                ),
                .product(
                    name: "TunnelKitOpenVPN",
                    package: "mobile-ios-openvpn",
                    condition: .when(platforms: [.iOS, .macCatalyst])
                ),
                .product(
                    name: "TunnelKitOpenVPNAppExtension",
                    package: "mobile-ios-openvpn",
                    condition: .when(platforms: [.iOS, .macCatalyst])
                ),
                .product(name: "NWHttpConnection", package: "mobile-ios-networking")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PIALibraryTests",
            dependencies: [
                "PIALibrary"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
