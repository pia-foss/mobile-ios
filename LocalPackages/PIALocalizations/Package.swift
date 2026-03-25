// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PIALocalizations",
    defaultLocalization: "en",
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
