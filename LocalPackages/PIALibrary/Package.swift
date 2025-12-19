
// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            targets: [
                "PIALibrary",
                "PIALibraryUtilObjC"
            ]
        )
    ],
    dependencies: [
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-kpi.git", exact: "1.2.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-csi.git", exact: "1.3.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-account.git", exact: "1.4.5"),
      .package(url: "git@github.com:pia-foss/mobile-ios-releases-regions.git", exact: "1.6.3"),
      .package(url: "git@github.com:pia-foss/mobile-ios-openvpn.git", branch: "master"),
      .package(url: "git@github.com:pia-foss/mobile-ios-wireguard.git", revision: "bf7b4258d9c9279c6051bba0b7a73ca7d5f9547e"),
      .package(url: "https://github.com/hkellaway/Gloss.git", from: "3.1.0"),
      .package(url: "https://github.com/huri000/SwiftEntryKit.git", from: "1.0.3"),
      .package(url: "https://github.com/Orderella/PopupDialog.git", branch: "master"),
      .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: "1.9.0"),
      .package(url: "https://github.com/ashleymills/Reachability.swift.git", from: "4.3.0"),
      .package(url: "git@github.com:pia-foss/mobile-ios-networking.git", exact: "1.3.1")
    ],
    targets: [
        .target(
            name: "PIALibrary",
            dependencies: [
                "SwiftyBeaver",
                "Gloss",
                "PIALibraryUtilObjC",
                .product(name: "PopupDialog", package: "PopupDialog", condition: .when(platforms: [.iOS])),
                .product(name: "SwiftEntryKit", package: "SwiftEntryKit", condition: .when(platforms: [.iOS])),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "PIAKPI", package: "mobile-ios-releases-kpi"),
                .product(name: "PIACSI", package: "mobile-ios-releases-csi"),
                .product(name: "PIARegions", package: "mobile-ios-releases-regions"),
                .product(name: "PIAAccount", package: "mobile-ios-releases-account"),
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
        .target(
            name: "PIALibraryUtilObjC",
            dependencies: []
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
