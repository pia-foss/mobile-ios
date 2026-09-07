// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PIAPaywall",
    defaultLocalization: "en",
    // iOS only: tvOS has its own signup flow in `PIA VPN-tvOS/Signup`, and this design is
    // iPhone/iPad specific. A package may declare fewer platforms than its dependencies.
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PIAPaywall",
            targets: ["PIAPaywall"]
        )
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAAssets"),
        .package(url: "https://github.com/pia-foss/apple-core.git", exact: "0.2.0")
    ],
    targets: [
        .target(
            name: "PIAPaywall",
            dependencies: [
                .product(name: "CoreArchitecture", package: "apple-core"),
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIAAssetsMobile", package: "PIAAssets")
            ],
            // Swift 5 language mode, matching PIAAssets. `AccountProvider` and `InAppProvider` are
            // not `Sendable` yet expose `nonisolated async` methods, so every call into PIALibrary
            // reads as a cross-actor send under Swift 6 checking. Making PIALibrary concurrency-safe
            // is a much larger piece of work; until then the feature pins itself to `@MainActor`
            // explicitly (see `PaywallStore` and `PaywallDependencies`) rather than pretending the
            // library is safe.
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "PIAPaywallTests",
            dependencies: [
                "PIAPaywall",
                .product(name: "CoreArchitecture", package: "apple-core")
            ]
        )
    ]
)
