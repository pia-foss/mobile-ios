// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PIAAssets",
    platforms: [.iOS(.v15), .tvOS(.v17)],
    products: [
        .library(name: "PIAAssetsMobile", targets: ["PIAAssetsMobile"]),
        .library(name: "PIAAssetsTV", targets: ["PIAAssetsTV"]),
        .library(name: "PIAAssetsWidget", targets: ["PIAAssetsWidget"])
    ],
    targets: [
        .target(
            name: "PIAAssetsMobile",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PIAAssetsTV",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "PIAAssetsWidget",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
