// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PIALocalizations",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(name: "PIALocalizations", targets: ["PIALocalizations"])
    ],
    targets: [
        .target(
            name: "PIALocalizations",
            resources: [.process("Resources")]
        )
    ]
)
