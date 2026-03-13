# ADR-001: SwiftUI Feature Modules as Swift Packages

**Status:** Accepted
**Date:** 2026-03-13

## Context

The iOS app is a monolithic UIKit target (`PIA VPN/`). All business logic, UI, strings, and assets live in a single app target. The tvOS app organizes features into folders within its target but is not split into packages.

New features will be built in SwiftUI. To enable independent development, testing, and eventual sharing between iOS and tvOS, new features will be implemented as self-contained Swift packages.

Two shared infrastructure packages are prerequisites before any feature package can compile:

1. **Shared image assets** — A new `PIAAssets` package will hold all shared image assets (including `PIAX/Global/` icons used across features), exposed via `Image.pia.*` so packages can reference them via `Bundle.module`.
2. **Localized strings** — A new `PIALocalizations` package will hold all shared localized strings, accessible to all feature packages via `Bundle.module`.

Colors, typography, and fonts are already handled by `PIADesignSystem`.

## Decision

New SwiftUI features are implemented as separate Swift packages in `LocalPackages/`. Each package is self-contained: it owns its strings, feature-specific assets, business logic, and SwiftUI views.

### Package structure per feature

```
LocalPackages/PIAFeatureName/
├── Package.swift
├── Sources/PIAFeatureName/
└── Tests/PIAFeatureNameTests/
```

### Package.swift template

```swift
// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PIAFeatureName",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .tvOS(.v17)],
    products: [
        .library(name: "PIAFeatureName", targets: ["PIAFeatureName"])
    ],
    dependencies: [
        .package(path: "../PIALibrary"),
        .package(path: "../PIAUI"),
        .package(path: "../PIALocalizations"),
        .package(path: "../PIAAssets"),
    ],
    targets: [
        .target(
            name: "PIAFeatureName",
            dependencies: [
                .product(name: "PIALibrary", package: "PIALibrary"),
                .product(name: "PIADesignSystem", package: "PIAUI"),
                .product(name: "PIASwiftUI", package: "PIAUI"),
                .product(name: "PIALocalizations", package: "PIALocalizations"),
                .product(name: "PIAAssets", package: "PIAAssets"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PIAFeatureNameTests",
            dependencies: ["PIAFeatureName"]
        )
    ]
)
```

### Dependency graph

```
PIALibrary  ─────────────────────────────────┐
PIAUI (PIADesignSystem, PIASwiftUI)  ─────────┤
PIALocalizations  ────────────────────────────┤──▶  Feature packages  ──▶  Host apps (iOS, tvOS)
PIAAssets  ──────────────────────────────────┘
```

Feature packages **never depend on each other**. Cross-feature data flows through `PIALibrary` shared models. Cross-feature navigation is wired by the host app's composition root.

### String resources

All shared localized strings live in `PIALocalizations`, accessed via `Bundle.module`. SwiftGen generates a single `L10n` enum for the package. Feature packages depend on `PIALocalizations` for any string shared across features.

### Asset resources

All image assets live in `PIAAssets`, exposed via `Image.pia.*`. SwiftGen generates a single `Asset` enum for the package. Feature packages depend on `PIAAssets` for all images.

### Composition / DI

Each feature package has a `FeatureFactory` (static methods) in `CompositionRoot/` that creates views and view models, injecting dependencies received from the host app. Provider access uses `Client.providers.*` from `PIALibrary`.

### Migration strategy

- Existing iOS UIKit screens are **not rewritten**. The monolithic `L10n` and `Asset` SwiftGen enums in the main app continue to work unchanged.
- New features are built as packages from day one.
- Existing screens migrate to packages incrementally, one feature at a time.
- UIKit hosts can embed SwiftUI feature views via `UIHostingController` or as a child view in a `UIViewController`.

## Consequences

**Positive:**
- Features can be developed and tested in isolation
- Features are shared between iOS and tvOS targets without duplication
- Clean dependency boundaries prevent accidental coupling
- `PIALibrary` and `PIADesignSystem` remain stable, low-level packages

**Constraints:**
- All strings live in `PIALocalizations` — feature packages do not bundle their own `.strings` files
- Feature packages must not import each other — cross-feature data must go through `PIALibrary`
- Colors and typography must come from `PIADesignSystem`; shared icons must come from `PIAAssets` (never from `Bundle.main`)
