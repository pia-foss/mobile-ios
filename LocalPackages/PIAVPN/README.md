# PIAVPN

A **simplified, PIA-owned version of the Kape SDK's `KapeVPN`** module. It provides the base
`NEPacketTunnelProvider` and the PIA adapters needed to run the PlatformSDK tunnel, so the app's
Network Extension target stays a thin shell.

It does **not** reimplement the tunnel engine — it reuses the SDK's `KapeVPN-PacketTunnel`
(session controller, system tunnel, WireGuard controller) and `KapeVPN-OpenVPN` (OpenVPN
connection controller). PIAVPN only relocates and hosts PIA's own glue.

## What's inside

| Type | Role | Mirrors in `KapeVPN` |
|------|------|----------------------|
| `PIAPacketTunnelProvider` | `open` base `NEPacketTunnelProvider`; wires the session engine and runs the tunnel | `KapePacketTunnelProvider` |
| `PIAEndpointRepository` | `VpnConfigurationGenerator` — builds WireGuard and/or OpenVPN endpoint configurations from the shared state; autonomously fetches/caches the server list and ranks candidates by latency | `KapeEndpointRepository` |
| `PIAWireguardAuthenticator` | `PacketTunnelWireguardAuthenticator` — performs PIA's WireGuard key exchange | `KapeWireguardAuthenticator` |
| `PIATunnelLogger` | `PacketTunnelLogger` — routes tunnel logs to `os.Logger` | — |

## How it's used

The extension target (`PlatformSDK-Tunnel`) is just:

```swift
import PIAVPN

class PacketTunnelProvider: PIAPacketTunnelProvider, @unchecked Sendable {}
```

— the same pattern as the Kape SDK example (`VPNDemo/PacketTunnel` subclassing `KapePacketTunnelProvider`).

## Scope (intentionally minimal)

- **WireGuard, OpenVPN, and Automatic.** `PIAPacketTunnelProvider` registers both a WireGuard and an
  OpenVPN `ConnectionController`; `PIAEndpointRepository` emits configurations per the selected
  protocol. Automatic mode uses a protocol-major pecking order — WireGuard, OpenVPN-UDP, then
  OpenVPN-TCP — with a fixed number of fastest-first distinct endpoints per step. The order dictates
  the transport, port, and OpenVPN crypto rather than using the saved OpenVPN settings.
- **No app-side manager.** PIA's app side keeps using `KapePlatformSDKTunnelProfile` and
  `PIATunnelSharedState` (in `PIALibrary`); this package is the extension-side engine glue only.
- **Persistent shared state.** Connection inputs (selected location / DIP server, cached server list,
  protocol, latencies, DNS, MTU, token) and extension write-back (`activeConnection`, `tunnelStatus`)
  flow through `PIATunnelSharedState`, a file-based snapshot in the App Group.
- **Live provider messages.** `PIAPacketTunnelRequest.switchLocation` asks the running session to
  re-resolve endpoints after the app changes shared state. `PIAPacketTunnelRequest.dataUsage` queries
  the SDK's cumulative byte counters and returns a `PIADataUsage`-compatible response to the app.

## Custom DNS

The user's DNS choice (Settings → Network) is applied to the PlatformSDK tunnel through PIA's own
components — the SDK does **not** expose custom DNS via `KapeVPNManager`/`KapeEndpointRepository`, so
PIA wires it at the configuration layer it already owns (this is the intended consumer pattern):

- **App side** (`PIALibrary`) — `KapePlatformSDKTunnelProfile.customDnsServers(forVPNType:)` reads the
  selected resolvers and `doSave` writes them into `PIATunnelSharedState` (`openVPNDnsServers` /
  `wireGuardDnsServers`). The read goes through the **raw** persisted custom-config maps, so it does
  not depend on `PIAWireguard` / `TunnelKitOpenVPN` (both being removed).
- **OpenVPN** — `PIAEndpointRepository` passes the list into `OpenVPNConfiguration(..., dnsServers:)`.
- **WireGuard** — `PIAWireguardAuthenticator` returns it on the enriched `WireguardEndpointConfiguration.dnsServers`.

Resolution precedence (per protocol): **user custom DNS → server-provided DNS → SDK fallback**. So an
empty selection keeps the PIA default (server-pushed DNS), which also preserves the Dedicated IP fix
(DIP servers rely on the server-returned resolver rather than the WireGuard internal-IP heuristic).
Multiple resolvers (primary + secondary) are supported.

## Dependencies

- `KapeVPN-PacketTunnel` (from `../KapePlatformSDK`) — the reused tunnel engine + WireGuard controller.
- `KapeVPN-OpenVPN` (from `../KapePlatformSDK`) — the OpenVPN connection controller and configuration type.
- `PIALibrary` — `PIATunnelSharedState`, `AppConstants`, `Server`, and PIA account/crypto helpers.

> Built in Swift 5 language mode to match the code's original (non-strict-concurrency) compilation context.
