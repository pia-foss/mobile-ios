# 0008: Integrate the Kape Platform SDK VPN engine

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

**Dependency model — vendored, pinned, checksum-verified, pulled in CI.** The SDK is not a
normal SPM dependency. It is pulled from a private Cloudsmith registry by
`scripts/pull-kape-platform-sdk.sh` into `LocalPackages/KapePlatformSDK/` (gitignored). Two pins
guard it: the version (a semver with a source-commit suffix, e.g. `1.0.0-99f3be8`) in
`scripts/kape-platform-sdk.version`, and the archive's SHA-256 in
`scripts/kape-platform-sdk.checksum`. The pull is **fail-closed on integrity**: the script
verifies the downloaded archive's SHA-256 against the committed checksum on every run — including
cached archives — and never installs an archive that lacks or fails its checksum. CI caches the
*archive* (not the unpacked package) precisely so this verification re-runs each time.
`ci_scripts/ci_post_clone.sh` and the CI workflows run the pull (and cache it) before resolving
SPM. Imported products:

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

**One extension, shared source, per-platform target.** A single new Network Extension source
folder, **PlatformSDK-Tunnel** (iOS + tvOS), replaces the per-protocol extensions when active.
The same sources are built by two platform targets — `PlatformSDK-Tunnel-iOS` and
`PlatformSDK-Tunnel-tvOS`, producing `PlatformSDK-Tunnel-iOS.appex` and
`PlatformSDK-Tunnel-tvOS.appex`. The app-side profile
`KapePlatformSDKTunnelProfile: NetworkExtensionProfile` (in `PIALibrary`) configures it.

**App ↔ extension IPC — bidirectional shared state plus provider messages.** State flows in
both directions through `PIATunnelSharedState` (a namespace whose payload is a nested `State`),
persisted as `pia_platformsdk_state.json` in the shared app group (on tvOS under
`Library/Caches`). Every write posts a Darwin notification so the other side observes the change
rather than polling.

- **App → extension (connection inputs).** The extension reads its parameters — selected
  server/location, DIP server, protocol, custom DNS, MTU, OpenVPN/WireGuard settings, token, and
  app-measured latencies — from shared state. The server list is not solely app-supplied: when
  the cached list is stale or absent the extension autonomously fetches a fresh one
  (`Client.downloadServerList()`) and caches it back with a TTL, so on-demand reconnects work
  with no app running (the `servers` cache is therefore written by both sides).
- **Extension → app (write-back).** Once connected the extension writes back `activeConnection`
  (the resolved protocol / region / transport) and a live `tunnelStatus`. The app reads these to
  show the actually-resolved endpoint and to drive the *Connecting* UI — `tunnelStatus` is folded
  into `VPNStatus.resolve(system:tunnel:)` so mid-session reconnects and in-place region switches
  surface as *Connecting* even while `NEVPNStatus` stays `.connected`.
- **Provider message (`switchLocation`).** To change region on a live tunnel without tearing
  down the extension process, the app writes the new target to shared state and sends a
  `PIAPacketTunnelRequest.switchLocation` message via `sendProviderMessage()`; the extension
  re-resolves its endpoints from shared state in place. This replaced an earlier client-side
  server-switch marker.
- **Provider message (`dataUsage`).** The app queries the active session's cumulative byte counters
  with `PIAPacketTunnelRequest.dataUsage`. The extension reads them from the SDK session controller
  and returns a `PIADataUsage`-compatible JSON payload, which `KapePlatformSDKTunnelProfile` maps to
  PIALibrary's existing `Usage` model. The profile also exposes the Network Extension connection's
  `connectedDate`, preserving the existing dashboard duration and usage features.

**Three protocol modes, automatic by default.** Protocol selection is mapped through
`KapePlatformSDKVPNType`, which centralises the persisted identifiers — `"PIA"` (OpenVPN),
`"PIAWG"` (WireGuard), and `"PIAAutomatic"` (automatic: a weighted protocol *pecking order* —
WireGuard, then OpenVPN-UDP, then OpenVPN-TCP, each tried against a fixed number of
fastest-first distinct endpoints, with transport, port, and OpenVPN crypto (AES-128-GCM /
SHA256) dictated by the order rather than the user's saved OpenVPN settings) — so
PlatformSDK code never references the legacy `PIATunnelProfile` / `PIAWGTunnelProfile` / TunnelKit
types directly. The enum also carries a fourth, non-connectable `"IKEv2"` case: it exists only to
recognise the value left by pre-PlatformSDK installs so those users can be migrated. **Automatic
is the default** when the flag is on (set in `Bootstrapper` on iOS and `BootstraperFactory` on
tvOS, which also migrate users on an unsupported persisted protocol — e.g. legacy IKEv2 — to
automatic).

**Server resolution.** For a concrete region the extension connects to that server; for a
Dedicated IP it uses the per-user DIP server carried in full through shared state (it is absent
from the public list). For the Automatic region (no selected location) the extension fans out
across every online non-DIP server, fastest first, ordered by the app-measured latencies mirrored
into shared state by `ServersPinger`. When the protocol is also Automatic, endpoint selection
within that fan-out is **protocol-major**: each pecking-order step draws up to its attempt count
of distinct endpoints fastest-first (across the eligible servers) before falling through to the
next protocol, rather than emitting a full per-server WireGuard+OpenVPN batch.

**Reconnection is owned by the SDK.** The engine handles transient network loss and endpoint
cycling internally. When the feature flag is on, `VPNDaemon` suppresses its own reconnect,
fallback-timer, and disconnect-error handling so the app does not fight the SDK's recovery.

**Gated rollout.** The integration is gated behind the CSI-controlled `usePlatformSDKVPN`
feature flag (`ios_platform_sdk_vpn`). On first launch under the flag, the legacy
IKEv2/OpenVPN/WireGuard profiles are removed (`cleanupLegacyVPNProfilesIfNeeded`).

> **Current state:** the flag is temporarily hard-forced `true` in `FeatureFlagHolder` on both
> iOS and tvOS (a `// TODO: [PlatformSDK]` override), so the CSI-driven gating is bypassed while
> the engine is under active development. Removing that override restores CSI control.

## Consequences

- **One maintained tunnel engine** shared across Kape brands; OpenVPN + WireGuard (and, later,
  Lightway) run behind a single extension instead of three, with reconnection and path
  monitoring handled by the core.
- **Build/CI now depend on a checksum-verified network pull.** Because `PIALibrary` (consumed by
  nearly every target) depends on the vendored SDK, no target resolves SPM until
  `pull-kape-platform-sdk.sh` has run. Clean checkouts and CI require `CLOUDSMITH_TOKEN`; any new
  build entry point must run the pull first or it fails with an opaque SPM error. The pull is
  fail-closed on the committed SHA-256 (`scripts/kape-platform-sdk.checksum`), so bumping the
  pinned version means updating both the version and checksum pins together.
- **tvOS gains OpenVPN, WireGuard, and Automatic protocol selection** through the same engine
  (`ProtocolSelectionView` / `ProtocolSelectionUseCase`).
- **New layering rule:** PlatformSDK code must not reference the legacy tunnel-profile or
  TunnelKit types (they are slated for removal); the `KapePlatformSDKVPNType` enum is the seam.
- **Migration / security trade-offs to track.** VPN credentials now flow through the shared-state
  file rather than only the Keychain (the OpenVPN password is a protection downgrade vs. the
  legacy Keychain-`passwordReference` model), and legacy-profile cleanup is a one-time migration.
- **Forward path:** once the engine is stable behind the flag, the legacy IKEv2/OpenVPN/WireGuard
  extensions and the `mobile-ios-openvpn` / `mobile-ios-wireguard` dependencies can be retired.
