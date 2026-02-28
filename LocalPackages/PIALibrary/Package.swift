// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PIALibrary",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIALibrary",
            targets: ["PIALibrary"]
        )
    ],
    dependencies: [
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-kpi.git", exact: "1.2.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-csi.git", exact: "1.3.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-regions.git", exact: "1.6.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-openvpn.git", branch: "master"),
      .package(url: "git@github.com:pia-foss/mobile-ios-wireguard.git", revision: "bf7b4258d9c9279c6051bba0b7a73ca7d5f9547e"),
      .package(url: "https://github.com/hkellaway/Gloss.git", from: "3.1.0"),
      .package(url: "https://github.com/apple/swift-log", from: "1.8.0"),
      .package(url: "https://github.com/ashleymills/Reachability.swift.git", from: "4.3.0"),
      .package(url: "git@github.com:pia-foss/mobile-ios-networking.git", exact: "1.3.1"),
      .package(path: "../PIAAccount")
    ],
    targets: [
        .target(
            name: "PIALibrary",
            dependencies: [
                "Gloss",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "PIAKPI", package: "mobile-ios-releases-kpi"),
                .product(name: "PIACSI", package: "mobile-ios-releases-csi"),
                .product(name: "PIARegions", package: "mobile-ios-releases-regions"),
                .product(name: "PIAAccount", package: "PIAAccount"),
                .product(name: "PIAWireguard", package: "mobile-ios-wireguard", condition: .when(platforms: [.iOS])),
                .product(name: "TunnelKit", package: "mobile-ios-openvpn", condition: .when(platforms: [.iOS])),
                .product(name: "TunnelKitOpenVPN", package: "mobile-ios-openvpn", condition: TargetDependencyCondition.when(platforms: [.iOS])),
                .product(name: "TunnelKitOpenVPNAppExtension", package: "mobile-ios-openvpn", condition: TargetDependencyCondition.when(platforms: [.iOS])),
                .product(name: "NWHttpConnection", package: "mobile-ios-networking")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PIALibraryTests",
            dependencies: [
                "PIALibrary",
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
