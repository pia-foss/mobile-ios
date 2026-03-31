Private Internet Access (PIA) is a VPN application for iOS and tvOS

language Swift 6
dependencies with Swift Package Manager
ui framework SwiftUI
old screens use UIKit and Storyboards, deprecated
platforms iOS 15, tvOS 17
swiftgen for typesafe resource generation
fastlane and xcode cloud are used for ci/cd

## Project Structure

@ADRs/                          contains Architecture Decision Records
@ci_scripts/                    Xcode Cloud CI scripts
@fastlane/                      CI/CD automation
@"PIA VPN/"                     main iOS folder
@"PIA VPN/Core/"                business logic, daemons, protocols
@"PIA VPN/UI/"                  view controllers, storyboards
@"PIA VPN/Bootstrapper.swift"   App initialization & DI
@"PIA VPN AdBlocker/"           Safari Content Blocker
@"PIA VPN-tvOS/"                main tvOS folder
@"PIA VPN Tunnel/"              OpenVPN Network Extension
@"PIA VPN WG Tunnel/"           WireGuard Network Extension
@LocalPackages/PIALibrary/      Shared Core: providers, VPN, persistence
@LocalPackages/PIAUI/           Shared UI components
@Resources/Configurations       xcconfig files, Build configurations
@TestPlans/                     Xcode test plans

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

**Build Configurations** (defined in `Resources/Configurations/`):
- **Development** - Local development with DEVELOPMENT flag, debug logging enabled
- **Staging** - Staging environment with STAGING flag, debug logging enabled
- **Release** - Production build, no development flags

**Schemes** (PIA VPN target with different configurations):
- **`PIA VPN Development`** - Development configuration (use for local testing)
- **`PIA VPN Staging`** - Staging configuration (staging endpoints)
- **`PIA VPN Release`** - Release configuration (production)
- `PIA VPN-tvOS` - tvOS production
- `PIALibrary`, `PIADesignSystem` - Package development

**Compilation Flags**:
- `DEVELOPMENT` - Set for Development configuration via `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
- `STAGING` - Set for Staging configuration via `SWIFT_ACTIVE_COMPILATION_CONDITIONS`

## Common Commands

```bash
# Setup
brew install swiftgen go  # Go 1.25.x required (for Amnezia WireGuard bridge)
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
xcodebuild build -scheme "PIA VPN Development" -configuration Development -destination "platform=iOS Simulator,name=iPhone 17 Pro"
xcodebuild build -scheme "PIA VPN Staging" -configuration Staging -destination "platform=iOS Simulator,name=iPhone 17 Pro"
xcodebuild build -scheme "PIA VPN Release" -configuration Release -destination "platform=iOS Simulator,name=iPhone 17 Pro"
xcodebuild test -scheme "PIA VPN Development" -configuration Development -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

## Code Guidelines

**Build Configurations**:
- Use `PIA VPN Development` scheme for local development (DEVELOPMENT flag set)
- Use `PIA VPN Staging` scheme for staging environment testing (STAGING flag set)
- Use `PIA VPN Release` scheme for production builds
- **Debug Logging**: Automatically enabled and locked ON for Development and Staging builds (set in `Bootstrapper.swift`), user-controllable for Release builds

**Testing**: New features → PIA VPNTests for iOS, Mock providers available in PIALibrary

**Resources**: Use SwiftGen accessors for strings, assets, storyboards (type-safe)

**VPN Extensions**: Separate process, memory constraints, shared app group for IPC, Keychain sharing required

**Feature Flags**: Server-controlled via CSI (Customer Support Integration)

**Compilation Flags**:
- DEVELOPMENT and STAGING flags are set in xcconfig files (`Resources/Configurations/`) via `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
- Use `#if DEVELOPMENT || STAGING` in app-level code for dev/staging-specific behavior
- Avoid relying on compilation flags in PIALibrary package code; handle at app level in `Bootstrapper.swift` instead

## Debugging

**VPN Debugging**:
- Physical device required for Network Extension debugging
- Console.app for PacketTunnel logs (filter by bundle ID)
- Debug logging is automatically enabled for Development and Staging builds
- For Release builds, enable debug logging in Help settings (toggle available to user)
- Check shared app group container for logs

**Debug Logging Behavior**:
- **Development/Staging**: Always ON, toggle disabled in UI (`HelpSettingsViewController.swift`)
- **Release**: User-controllable via Help settings toggle
- Logging implementation: `PIALogHandler.swift` filters based on `Client.preferences.debugLogging`
- Initialization: `Bootstrapper.swift` sets `debugLogging = true` for Development/Staging

**Network Extensions**: Run separate from main app, use `os_log` for debugging

## Dependencies

**PIA Packages**: mobile-ios-releases-{kpi,csi,account,regions,networking}, mobile-ios-{openvpn,wireguard}

**Third-party**: SwiftEntryKit, Reachability, swift-log, Alamofire (legacy), SwiftyBeaver, TweetNacl

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

## Build Issues

- **SwiftGen errors**: Run `brew install swiftgen` and regenerate: `swiftgen config run`
- **Go not found**: Install via `brew install go` (Go 1.25.x required for Amnezia WireGuard bridge)
- **Missing entitlements**: Hotspot Helper requires special Apple approval (see Security section)
- **Network Extension not debugging**: Must use physical device, check Console.app
- **Keychain errors**: Ensure keychain sharing configured in entitlements

## Notes

**Single iOS Target**: The project uses one iOS app target with three build configurations (Development, Staging, Release) and corresponding schemes, rather than separate app targets for each environment

**Configuration Architecture**:
- Build settings defined in xcconfig files (`Resources/Configurations/`)
- Each configuration inherits from Production.xcconfig and adds environment-specific settings
- Compilation flags set via `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
- Base URL and bundle identifier configured per environment in xcconfig

**Development Flow**: Use `PIA VPN Development` scheme for local testing, `PIA VPN Staging` for staging environment testing
