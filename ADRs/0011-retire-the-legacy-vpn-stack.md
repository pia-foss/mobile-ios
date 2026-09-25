# 0011: Retire the legacy VPN stack

Date: 2026-09-07 (iOS + Mac Catalyst pass recorded 2026-09-08)

## Context

[ADR-0008](0008-integrate-kape-platform-sdk-vpn-engine.md) introduced the Kape Platform SDK tunnel
behind the CSI flag `ios_platform_sdk_vpn`, and named retiring the legacy per-protocol stack as the
forward path. This ADR records that retirement (KM-18239), which landed **platform by platform**:
tvOS first (2026-09-07), then iOS and Mac Catalyst (2026-09-08). With both passes done, the legacy
engine is gone from the codebase entirely.

### What "the legacy stack" is, per platform

The two platforms carried very different amounts of it.

**tvOS** only ever shipped IKEv2, through the *personal* VPN slot (`NEVPNManager.shared()`) — no
OpenVPN or WireGuard tunnel, and no Network Extension of its own until `PlatformSDK-Tunnel-tvOS`.
TunnelKit and `mobile-ios-wireguard` were already excluded from tvOS by platform conditions in
`PIALibrary/Package.swift`, so there was nothing to unlink. Its legacy surface was: the
`IKEv2Profile` registration, the `usePlatformSDKVPN` branches, and stale signing config.

**iOS** carries the full stack: the `PIA VPN Tunnel` (OpenVPN) and `PIA VPN WG Tunnel` (WireGuard)
extension targets with their own bundle ids, entitlements and provisioning profiles; the
`PIATunnelProfile` / `PIAWGTunnelProfile` / `IKEv2Profile` / `IPSecProfile` /
`OpenVPNProvider+Compat` profile types; and the `TunnelKitPackage` and `mobile-ios-wireguard`
dependencies.

## Decision

**Remove the legacy stack once the PlatformSDK tunnel is at 100% in production on a platform, and
remove the flag with it.**

- **tvOS is done** (2026-09-07). The flag was at 100%, so `usePlatformSDKVPN` and every branch on it
  are gone from the tvOS target. tvOS registers only `KapePlatformSDKTunnelProfile` and offers
  Automatic / WireGuard / OpenVPN.
- **iOS and Mac Catalyst are done** (2026-09-08). Both extension targets (`PIA VPN Tunnel`,
  `PIA VPN WG Tunnel`), all nine legacy profile/algorithm files, the `DefaultVPNProvider` IKEv2/IPSec
  branches, and the `TunnelKitPackage` / `mobile-ios-wireguard` dependencies are deleted. Catalyst
  needed no separate engine work — it already ran the PlatformSDK tunnel — but it does have its own
  Mac-specific branches, which now select automatic negotiation like every other platform.

**The one-time migration is kept.** An upgrading install still has a stale legacy configuration to
remove, so `cleanupLegacyVPNProfilesIfNeeded` / `didCleanupLegacyVPNProfiles` survive the removal and
are the *only* place legacy identifiers may appear.

That migration no longer goes through `IKEv2Profile` on either platform. It calls the shared
`LegacyVPNConfigurationCleanup` (in `PIA Common`), which drives `NEVPNManager.shared()` directly: load, stop the
tunnel, disarm on-demand, remove — and, unlike `IKEv2Profile.disconnect`, it never writes the app's
own VPN status, because it runs while the PlatformSDK profile is the active one. The migration is
recorded as done only on a clean removal, so a failure retries on the next launch.

iOS keeps the tunnel-provider half of that prune — it also had OpenVPN and WireGuard
`NETunnelProviderManager`s — and now folds the personal-slot result into its completion flag, so a
failed IKEv2 removal is retried instead of being recorded as a finished migration.

`SelectableVPNProtocol` (also in `PIA Common`) is the single definition of which protocols the tunnel
can run and what a stored `Client.preferences.vpnType` means. Both platforms' Protocol settings
screens (read) and both migrations (write) go through it, so they cannot disagree about whether a
persisted value is still selectable.

### The settings layer: keep only what the tunnel reads

The part a future reader will most need explained. VPN settings used to exist in **two** places: a
typed `VPNCustomConfiguration` layer whose only concrete conformances were vendor types (TunnelKit's
OpenVPN configuration and `PIAWireguardConfiguration`), and plain scalars on `Client.preferences`
backed by app-group `UserDefaults`.

**Only the scalars survive.** The PlatformSDK tunnel reads `"OpenVPNCipher"`, `"OpenVPNAuth"`,
`"OpenVPNPort"`, `"PIASocketType"` and `"UseSmallPackets"` straight out of the app group; it never
consulted the typed layer at all (`parsedCustomConfiguration` returned `nil` by design). Settings had
been writing *both* on every change, so the typed writes were pure duplication and deleting them
changed no stored data. `openVPNAuth` moved onto `Client.preferences` in the process, which also
fixed a real bug: it was the one OpenVPN setting written immediately rather than staged, so Cancel
reverted every other setting but not the auth digest.

**Custom DNS was the exception** and the one place data could be lost. `openVPNDnsServers` /
`wireGuardDnsServers` already existed as preferences, but the *tunnel* still read DNS from the legacy
map — so installs that chose DNS before those keys shipped had it in the map only.
`LegacyCustomDNSMigration` backfills them once at bootstrap, before the first tunnel-settings build,
and must understand **two different shapes**: WireGuard stored a flat `customDNSServers`, while
OpenVPN nested it under `configuration.dnsServers` — the shape TunnelKit's synthesised `Codable`
produced. A populated preference always wins; an empty legacy list is *not* migrated, because empty
means "PIA default DNS" rather than "override with nothing".

It then **deletes** `VPNCustomConfigurationMaps` from the app group — after the commit, so a crash in
between cannot lose a setting that never reached the preferences. That makes the migration genuinely
one-shot and leaves no legacy blob behind, at the cost of erasing data any *external* reader (support
tooling, diagnostics) might still have depended on: confirm none exists before shipping.

## Consequences

- **No kill switch on any platform.** Removing the flag means a regression in the PlatformSDK tunnel
  can no longer be mitigated from CSI; it needs an app release. This is the deliberate cost of deleting the
  second engine, and it is why removal is gated on 100% rollout rather than on the code being ready.
- **One VPN extension per platform.** tvOS ships `PlatformSDK-Tunnel-tvOS`; iOS ships
  `PlatformSDK-Tunnel-iOS` alongside the unrelated AdBlocker and Widget extensions; Mac Catalyst
  ships the same minus the widget.
- **The app must link OpenSSL explicitly.** It used to arrive transitively through
  `PIALibrary → TunnelKitPackage → OpenSSL`, and because the *app* pulled it, Xcode embedded
  `OpenSSL.framework` into the bundle. Dropping that dependency edge left the tunnel extension still
  linking `@rpath/OpenSSL.framework/OpenSSL` with nothing embedding it — the extension failed to
  launch on device. Both app targets now link the `OpenSSL` package product directly. tvOS already
  did, precisely because TunnelKit was excluded there first.
- **`allow-vpn` must stay in both apps' entitlements.** `com.apple.developer.networking.vpn.api` looks
  like IKEv2-era residue, but the migration drives the personal-VPN API and requires it. It can only
  go once the migration itself is retired — which needs a release where no supported install can
  still be carrying a legacy configuration.
- **Signing config had drifted.** The tvOS fastlane lanes still named
  `com.privateinternetaccess.ios.PIA-VPN.PacketTunnel`, the extension deleted when the PlatformSDK
  tunnel landed, so `testflight_build_tvos` was exporting against a bundle id that no longer exists.
  They now name `...PlatformSDK-Tunnel-tvOS`; the matching App Store Connect identifier and profile
  still have to be created.
- **The tvOS Protocols setting is now unconditional.** Users upgrading from an IKEv2-only build are
  migrated onto Automatic, since IKEv2 is not connectable through the PlatformSDK tunnel.
- **KPI reporting changed.** `ServiceQualityManager` no longer emits `.ipsec`. It now reports the
  protocol the tunnel actually negotiated (`actualConnection`), which is the only correct answer under
  Automatic. Any dashboard grouping on `.ipsec` sees that series go to zero.
- **What is left to retire, and when.** The migration is the only legacy surface still compiled:
  `cleanupLegacyVPNProfilesIfNeeded`, `LegacyVPNConfigurationCleanup`, `LegacyCustomDNSMigration`,
  `KapePlatformSDKVPNType.iKEv2` and the `allow-vpn` entitlement. They can all go in a release where
  no supported install can still be carrying a legacy configuration — worth its own ticket rather
  than an open-ended TODO.
