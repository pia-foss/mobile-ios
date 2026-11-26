// swift-tools-version: 6.2

import PackageDescription

// The accessibility identifiers the apps set and the UI tests query (see ADR-0015).
// It must stay dependency-free: the UI test bundles link it and must not pull in the app's modules.
let package = Package(
    name: "PIAAccessibility",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIAAccessibility",
            targets: ["PIAAccessibility"]
        )
    ],
    targets: [
        .target(name: "PIAAccessibility")
    ]
)
