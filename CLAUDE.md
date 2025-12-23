# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Private Internet Access (PIA) VPN iOS/tvOS application. Dual-platform codebase with:
- **iOS app**: UIKit-based (iOS 15.0+, Swift 5+)
- **tvOS app**: SwiftUI-based (tvOS 17+)
- **Shared core**: PIALibrary (Swift Package Manager)

## Project Structure

```
pia-mobile-ios-fixes/
├── PIA VPN/                    # Main iOS app (UIKit)
│   ├── Core/                   # Business logic, daemons, protocols
│   │   └── Tiles/              # Dashboard tile system
│   ├── UI/                     # View controllers, storyboards
│   ├── Global/                 # AppConfiguration, AppConstants
│   └── Bootstrapper.swift      # App initialization & DI
├── PIA VPN dev/                # Development app (staging endpoints)
├── PIA VPN-tvOS/               # tvOS app (SwiftUI, feature-based)
├── PIA VPN Tunnel/             # OpenVPN Network Extension
├── PIA VPN WG Tunnel/          # WireGuard Network Extension
├── PIA VPN AdBlocker/          # Safari Content Blocker
├── PIAWidgetExtension/         # iOS Widget
├── LocalPackages/
│   ├── PIALibrary/             # Core: providers, VPN, persistence
│   └── PIADesignSystem/        # Shared UI components
├── TestPlans/                  # Xcode test plans
└── fastlane/                   # CI/CD automation
```

## Architecture

**Provider Pattern (Core)**: Protocol-based services accessed via `Client.providers.*`
- `AccountProvider` - Authentication, subscriptions
- `VPNProvider` - VPN connection (IKEv2/OpenVPN/WireGuard)
- `ServerProvider` - Server list, region management
- `InAppProvider` - Purchase handling

**Daemon Pattern**: Background monitoring services
- `ConnectivityDaemon`, `ServersDaemon`, `VPNDaemon`, `AccountObserver`

**Tile System (iOS)**: Modular dashboard components, CollectionView-based, user-configurable

**Communication**: Extensive NotificationCenter usage for events (VPN status, account, connectivity, theme)

## Key Components

**VPN**: 3 protocols via Network Extensions
- IKEv2 (native), OpenVPN (TunnelKit), WireGuard (WireGuard-Go)
- Each protocol = separate Network Extension target
- IPC via shared app group + Darwin notifications

**Test Targets**: PIALibraryTests, PIADesignSystemTests, **PIA VPNTests (preferred)**, PIA-VPN_E2E_Tests, PIA VPN-tvOSTests, PIA-VPN_tvOS_E2E_Tests, PIA VPN-tvOS snapshot

**Shared Modules**: PIALibrary (core logic), PIADesignSystem (UI components)

## Build Requirements

**Prerequisites**:
- Ruby (rbenv recommended)
- Homebrew: `swiftgen`, `go`
- `gem install bundler && bundle install`

**Schemes**:
- `PIA VPN` - Production iOS
- **`PIA VPN dev` - Development iOS (use for local testing)**
- `PIA VPN-tvOS` - tvOS production
- `PIALibrary`, `PIADesignSystem` - Package development

**Configurations**: Debug, Release

## Common Commands

```bash
# Setup
brew install swiftgen go
gem install bundler && bundle install

# Testing
bundle exec fastlane iOStests                    # iOS unit tests (preferred)
bundle exec fastlane tvOStests                   # tvOS unit tests
bundle exec fastlane ios_e2e_tests               # iOS E2E
bundle exec fastlane tvos_e2e_tests              # tvOS E2E
bundle exec fastlane tvos_snapshot_tests         # tvOS snapshots

# Building
bundle exec fastlane development_build           # Dev build
bundle exec fastlane staging_build               # Staging environment
bundle exec fastlane testflight_build            # iOS TestFlight
bundle exec fastlane testflight_build_tvos       # tvOS TestFlight

# Certificates
bundle exec fastlane get_development_profiles
bundle exec fastlane get_profiles
bundle exec fastlane certificates

# Resources
swiftgen config run --config swiftgen.yml        # Regenerate type-safe resources

# Direct xcodebuild
xcodebuild test -scheme "PIA VPN" -destination "platform=iOS Simulator,name=iPhone 17 Pro"
xcodebuild -scheme "PIA VPN" -configuration Debug build
```

## Code Guidelines

**Schemes**: Use `PIA VPN dev` for development (staging endpoints, feature flags, custom servers)

**Testing**: New features → PIA VPNTests for iOS, Mock providers available in PIALibrary

**Resources**: Use SwiftGen accessors for strings, assets, storyboards (type-safe)

**VPN Extensions**: Separate process, memory constraints, shared app group for IPC, Keychain sharing required

**Feature Flags**: Server-controlled via CSI (Customer Support Integration)

## Debugging

**VPN Debugging**:
- Physical device required for Network Extension debugging
- Console.app for PacketTunnel logs (filter by bundle ID)
- Enable debug logging in app settings
- Check shared app group container for logs

**Network Extensions**: Run separate from main app, use `os_log` for debugging

## Dependencies

**Swift Package Manager only** (no CocoaPods)

**PIA Packages**: mobile-ios-releases-{kpi,csi,account,regions,networking}, mobile-ios-{openvpn,wireguard}

**Third-party**: SwiftEntryKit, Gloss, Reachability, swift-log, Alamofire (legacy), SwiftyBeaver, TweetNacl

## Security

**IMPORTANT**: VPN application handling sensitive data
- **No hardcoded credentials/secrets** in code or logs
- Credentials → Keychain only
- Network Extension security boundaries respected
- Proper VPN entitlements required
- DNS/IPv6 leak protection implemented
- Keychain sharing between app and extensions

### Hotspot Helper API
Requires special Apple entitlement. If unavailable:
- Remove `configureHotspotHelper()` in `AppDelegate.swift`
- Update entitlements accordingly

## CI/CD

**GitLab CI**: `.gitlab-ci.yml` - Testing, archiving, deployment to HockeyApp

**Xcode Cloud**: `ci_scripts/` - Version extraction from git tags, App Store builds

**Fastlane**: Certificates, profiles, builds, TestFlight uploads, release note translation (Claude API)

## Build Issues

- **SwiftGen errors**: Run `brew install swiftgen` and regenerate: `swiftgen config run`
- **Go not found**: Install via `brew install go` (required for WireGuard)
- **Missing entitlements**: Hotspot Helper requires special Apple approval (see Security section)
- **Network Extension not debugging**: Must use physical device, check Console.app
- **Keychain errors**: Ensure keychain sharing configured in entitlements

## Key Files

- `PIA VPN.xcodeproj`, `Podfile` (legacy), `swiftgen.yml`
- `fastlane/Fastfile`, `.gitlab-ci.yml`, `ci_scripts/`
- `README.md`, `CONTRIBUTING.md`
- Test plans: `TestPlans/*.xctestplan`

## Branching Strategy

- Cut feature branches from **`develop`** with prefix `feature/`
- Submit PRs to **`develop`** (not `master`)
- Concise, meaningful commit messages
- Lint before committing

## Notes

**Development Flow**: Use `PIA VPN dev` scheme, staging endpoints, `PIA_DEV` preprocessor flag enables dev features

**Multi-platform**: iOS (UIKit) + tvOS (SwiftUI) share PIALibrary core

**Resource Management**: SwiftGen for type-safe access to Localizable.strings, Assets, Storyboards

**License**: MIT (Expat), GPL v3 for TunnelKit/OpenVPN components
