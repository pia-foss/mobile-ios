// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "PIAUI",
    platforms: [
        .iOS(.v15),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "PIAUIKit",
            targets: ["PIAUIKit"]
        ),
        .library(
            name: "PIASwiftUI",
            targets: ["PIASwiftUI"]
        )
    ],
    dependencies: [
//        .package(path: "../PIALibrary"),
        .package(path: "../PIADesignSystem"),
    ],
    targets: [
        .target(
            name: "PIAUIKit"
//            dependencies: [
//                .product(name: "PIALibrary", package: "PIALibrary")
//            ]
        ),
        .target(
            name: "PIASwiftUI",
            dependencies: [
                .product(name: "PIADesignSystem", package: "PIADesignSystem")
            ]
        ),
        .testTarget(
            name: "PIAUIKitTests",
            dependencies: ["PIAUIKit"]
        ),
        .testTarget(
            name: "PIASwiftUITests",
            dependencies: ["PIASwiftUI"]
        )
    ]
)
