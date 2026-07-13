[![PIA logo][pia-image]][pia-url]

# Private Internet Access

Private Internet Access is the world's leading consumer VPN service. At Private Internet Access we believe in unfettered access for all, and as a firm supporter of the open source ecosystem we have made the decision to open source our VPN clients. For more information about the PIA service, please visit our website [privateinternetaccess.com][pia-url] or check out the [Wiki][pia-wiki].

# PIA VPN for iOS & tvOS

With the Private Internet Access VPN app for iOS and tvOS, you can access our network of VPN servers across the world from your iPhone, iPad, iPod touch, or Apple TV. Choose among many available countries and connect easily. Features include kill switch, multiple VPN protocols, DNS/IPv6 leak protection and ad-blocking.

## Features

- [x] Plenty of countries to connect to
- [x] IKEv2, OpenVPN and WireGuard VPN protocols (iOS) / IKEv2 (tvOS)
- [x] Kill switch
- [x] Fine-grained VPN settings
- [x] DNS leak protection
- [x] IPv6 leak protection
- [x] Safari Content Blocker (iOS only)
- [x] Dark theme
- [x] Hotspot Helper (iOS only)
- [x] tvOS support

## Requirements

- iOS 15.0+ / tvOS 17.0+
- Xcode 26+
- [Homebrew][dep-brew]
- [SwiftGen][dep-swiftgen] (`brew install swiftgen`)
- [Go][dep-golang] (`brew install go`, required for WireGuard)
- Ruby with rbenv (recommended)
- Bundler (`gem install bundler && bundle install`)
- A Cloudsmith entitlement token to pull the Kape Platform SDK (see [Kape Platform SDK](#kape-platform-sdk))

## Installation

```bash
# Install system dependencies
brew install swiftgen go

# Install Ruby dependencies
gem install bundler && bundle install

# Pull the Kape Platform SDK (required before building — see below)
CLOUDSMITH_TOKEN=<your-token> ./scripts/pull-kape-platform-sdk.sh
```

## Kape Platform SDK

The VPN packet-tunnel engine is provided by the **Kape Platform SDK**, a Swift package
that is **not committed to this repository**. It is pulled from a private Cloudsmith
registry into `LocalPackages/KapePlatformSDK/` (gitignored) by
`scripts/pull-kape-platform-sdk.sh`, and pinned to a specific version in
`scripts/kape-platform-sdk.version` with its archive SHA-256 pinned in
`scripts/kape-platform-sdk.checksum`.

Because `PIALibrary` (consumed by nearly every target) depends on this package,
**no target will resolve Swift packages or build until the SDK has been pulled.** A clean
checkout that skips this step fails with an opaque "missing local package" SPM error.

### 1. Provide a Cloudsmith token

You need a Cloudsmith entitlement token with read access to the SDK repository. The script
resolves the token in this order:

1. `CLOUDSMITH_TOKEN` environment variable
2. `CLOUDSMITH_API_KEY` environment variable
3. A `.cloudsmith` file in the repo root (gitignored, containing just the token)

### 2. Pull the SDK

```bash
# Using an environment variable
CLOUDSMITH_TOKEN=<your-token> ./scripts/pull-kape-platform-sdk.sh

# Or, with a .cloudsmith file present in the repo root
./scripts/pull-kape-platform-sdk.sh
```

The script downloads the pinned version, verifies its SHA-256 against the committed
checksum pin, and unpacks it into `LocalPackages/KapePlatformSDK/`. Verification is
mandatory — an archive that fails or lacks a checksum is never installed. It is
idempotent — re-running it when the pinned version is already installed is a no-op.

### 3. Build as usual

Open the workspace in Xcode (or run `xcodebuild` / `fastlane`) and let SwiftPM resolve.

> **CI:** the same pull runs automatically before the build — `ci_scripts/ci_post_clone.sh`
> for Xcode Cloud and the GitHub Actions workflows. `CLOUDSMITH_TOKEN` must be configured as
> a secret environment variable there.

### Updating the pinned version

```bash
# Fetch the latest version from the registry, update the version and checksum pins, then pull
CLOUDSMITH_TOKEN=<your-token> ./scripts/pull-kape-platform-sdk.sh --update
```

## Build Configurations & Schemes

The project uses three build configurations, each with iOS and tvOS variants:

| Scheme | Endpoints | Use for |
|--------|-----------|---------|
| `PIA VPN Development` | Production | Local development |
| `PIA VPN Staging` | Staging | Staging environment testing |
| `PIA VPN Release` | Production | Release builds |
| `PIA VPN-tvOS Development` | Production | tvOS local development |
| `PIA VPN-tvOS Staging` | Staging | tvOS staging environment testing |
| `PIA VPN-tvOS Release` | Production | tvOS release builds |

## Testing

```bash
# Unit tests
bundle exec fastlane iOStests
bundle exec fastlane tvOStests
```

## Hotspot Helper API

We use a special entitlement to participate in the process of joining Wi-Fi/hotspot networks (https://developer.apple.com/documentation/networkextension/nehotspothelper).

You need to request this entitlement from Apple, or remove the call to `configureHotspotHelper()` in `AppDelegate.swift` and adapt the entitlements file to your needs.

## swift-format

To maintain consistency across developers, we use [`swift-format`][dep-swift-format]. The default formatting rules are defined in the `.swift-format` file. A pre-commit hook is available that automatically formats staged Swift files and blocks the commit if any changes are needed. To install it, run from the repo root:

```sh
ln -s ../../Tools/hooks/pre-commit .git/hooks/pre-commit
```

## Contributing

By contributing to this project you are agreeing to the terms stated in the Contributor License Agreement (CLA) [here](/CLA.rst).

For more details please see [CONTRIBUTING](/CONTRIBUTING.md).

Issues and Pull Requests should use these templates: [ISSUE](/.github/ISSUE_TEMPLATE.md) and [PULL REQUEST](/.github/PULL_REQUEST_TEMPLATE.md).

## License

This project is licensed under the [MIT (Expat) license](https://choosealicense.com/licenses/mit/), which can be found [here](/LICENSE).

[pia-image]: https://assets-cms.privateinternetaccess.com/img/frontend/pia_menu_logo_light.svg
[pia-url]: https://www.privateinternetaccess.com/
[pia-wiki]: https://en.wikipedia.org/wiki/Private_Internet_Access

[dep-swift-format]: https://github.com/swiftlang/swift-format
[dep-swiftgen]: https://github.com/SwiftGen/SwiftGen
[dep-brew]: https://brew.sh/
[dep-golang]: https://golang.org/
