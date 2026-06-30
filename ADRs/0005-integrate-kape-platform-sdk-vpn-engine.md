# 0005: Integrate the Kape Platform SDK VPN engine

Date: 2026-06-25

## Context

PIA historically ships three independent VPN protocol stacks, each as its own Network
Extension target with its own connection, crypto, and reconnection logic:

- **IKEv2** — native `NEVPNProtocolIKEv2`.
- **OpenVPN** — a TunnelKit fork via `mobile-ios-openvpn`.
- **WireGuard** — WireGuard-Go via `mobile-ios-wireguard`.

Maintaining three divergent tunnel implementations is expensive: every protocol fix,
reconnection improvement, or path-monitoring change has to be made (and tested) up to three
times, and the implementations have drifted in behaviour over time.

Kape (the parent organisation) provides the **Kape Platform SDK** (`kp_platform_sdks`):
platform-native Swift/Kotlin SDKs layered on top of the Rust-based Kape Client SDK. The Apple
side (`apple/KapePlatformSDK`) exposes a packet-tunnel engine that already implements OpenVPN
and WireGuard (and Lightway) on a single shared core, with reconnection and network-path
handling built in. Consolidating PIA's VPN engine onto this core lets PIA share one maintained
implementation with the rest of Kape's brands instead of carrying its own.

## Decision

We integrate **only the Platform SDK's VPN packet-tunnel engine** — not its account, auth,
subscription, or UI layers. PIA keeps its existing `AccountProvider`, `ServerProvider`,
regions, CSI, KPI, and UI; only the tunnel implementation is swapped.

**Dependency model — vendored, pinned, pulled in CI.** The SDK is not a normal SPM dependency.
It is pulled from a private Cloudsmith registry by `scripts/pull-kape-platform-sdk.sh` into
`LocalPackages/KapePlatformSDK/` (gitignored), pinned by hash in
`scripts/kape-platform-sdk.version`. `ci_scripts/ci_post_clone.sh`
and the GitHub workflows run the pull (and cache it) before resolving SPM. Imported products:

- `KapeVPN-PacketTunnel` — the tunnel engine, WireGuard controller, and internal reconnection.
- `KapeVPN-OpenVPN` — the OpenVPN connection controller.
- `TunnelKitPackage` (the Kape TunnelKit fork) — consumed by `PIALibrary` for OpenVPN config types.

**Adapter layer — new `LocalPackages/PIAVPN/` package.** PIA bridges its own data model onto
the SDK's interface protocols with thin adapters that run inside the extension:

| PIA adapter | Kape interface | Responsibility |
|---|---|---|
| `PIAPacketTunnelProvider` | `NEPacketTunnelProvider` | Extension entry point; wires up the SDK session/connection controllers. |
| `PIAEndpointRepository` | `VpnConfigurationGenerator` | Resolves endpoints/settings from shared state; autonomously fetches and caches the server list, and ranks candidates by latency (see below). |
| `PIAWireguardAuthenticator` | `PacketTunnelWireguardAuthenticator` | WireGuard key exchange + TLS pinning to the bundled PIA root CA. |
| `PIATunnelLogger` | `PacketTunnelLogger` | Bridges SDK logging to `os.Logger`. |

**One extension target.** A single new Network Extension, **PlatformSDK-Tunnel** (iOS + tvOS),
replaces the per-protocol extensions when active. The app-side profile
`KapePlatformSDKTunnelProfile: NetworkExtensionProfile` (in `PIALibrary`) configures it.

**App ↔ extension IPC via file-based shared state.** The extension reads its connection
parameters (selected server, protocol, custom DNS, MTU, token, app-measured latencies) from
`PIATunnelSharedState`, persisted as `pia_platformsdk_state.json` in the shared app group. The
server list itself is not solely app-supplied: when the cached list is stale or absent the
extension autonomously fetches a fresh one (`Client.downloadServerList()`) and caches it back to
shared state with a TTL, so on-demand reconnects work with no app running.

**Three protocol modes, automatic by default.** Protocol selection is mapped through
`KapePlatformSDKVPNType`, which centralises the persisted identifiers — `"PIA"` (OpenVPN),
`"PIAWG"` (WireGuard), and `"PIAAutomatic"` (automatic: WireGuard first, then OpenVPN) — so
PlatformSDK code never references the legacy `PIATunnelProfile` / `PIAWGTunnelProfile` / TunnelKit
types directly. **Automatic is the default** when the flag is on (set in `Bootstrapper` on iOS and
`BootstraperFactory` on tvOS, which also migrate users on an unsupported persisted protocol —
e.g. legacy IKEv2 — to automatic).

**Server resolution.** For a concrete region the extension connects to that server; for a
Dedicated IP it uses the per-user DIP server carried in full through shared state (it is absent
from the public list). For the Automatic region (no selected location) the extension fans out
across every online server, fastest first, ordered by the app-measured latencies mirrored into
shared state by `ServersPinger`.

**Reconnection is owned by the SDK.** The engine handles transient network loss and endpoint
cycling internally. When the feature flag is on, `VPNDaemon` suppresses its own reconnect,
fallback-timer, and disconnect-error handling so the app does not fight the SDK's recovery.

**Gated rollout.** The integration is gated behind the CSI-controlled `usePlatformSDKVPN`
feature flag. On first launch under the flag, the legacy IKEv2/OpenVPN/WireGuard profiles are
removed (`cleanupLegacyVPNProfilesIfNeeded`).

## Consequences

- **One maintained tunnel engine** shared across Kape brands; OpenVPN + WireGuard (and, later,
  Lightway) run behind a single extension instead of three, with reconnection and path
  monitoring handled by the core.
- **Build/CI now depend on a network pull.** Because `PIALibrary` (consumed by nearly every
  target) depends on the vendored SDK, no target resolves SPM until `pull-kape-platform-sdk.sh`
  has run. Clean checkouts and CI require `CLOUDSMITH_TOKEN`; any new build entry point must run
  the pull first or it fails with an opaque SPM error.
- **tvOS gains OpenVPN, WireGuard, and Automatic protocol selection** through the same engine
  (`ProtocolSelectionView` / `ProtocolSelectionUseCase`).
- **New layering rule:** PlatformSDK code must not reference the legacy tunnel-profile or
  TunnelKit types (they are slated for removal); the `KapePlatformSDKVPNType` enum is the seam.
- **Migration / security trade-offs to track.** VPN credentials now flow through the shared-state
  file rather than only the Keychain (the OpenVPN password is a protection downgrade vs. the
  legacy Keychain-`passwordReference` model), and legacy-profile cleanup is a one-time migration.
- **Forward path:** once the engine is stable behind the flag, the legacy IKEv2/OpenVPN/WireGuard
  extensions and the `mobile-ios-openvpn` / `mobile-ios-wireguard` dependencies can be retired.
