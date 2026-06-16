# PIAVPN

A **simplified, PIA-owned version of the Kape SDK's `KapeVPN`** module. It provides the base
`NEPacketTunnelProvider` and the PIA adapters needed to run the PlatformSDK tunnel, so the app's
Network Extension target stays a thin shell.

It does **not** reimplement the tunnel engine — it reuses the SDK's `KapeVPN-PacketTunnel`
(session controller, system tunnel, WireGuard controller). PIAVPN only relocates and hosts PIA's own glue.

## What's inside

| Type | Role | Mirrors in `KapeVPN` |
|------|------|----------------------|
| `PIAPacketTunnelProvider` | `open` base `NEPacketTunnelProvider`; wires the session engine and runs the tunnel | `KapePacketTunnelProvider` |
| `PIAEndpointRepository` | `VpnConfigurationGenerator` — resolves the selected server's WireGuard endpoints from the shared state | `KapeEndpointRepository` |
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

- **WireGuard only.** The `ConnectionController` abstraction is kept, so other protocols can be added later;
  for now any non-WireGuard selection hits a `fatalError` in `PIAPacketTunnelProvider`.
- **No app-side manager.** PIA's app side keeps using `KapePlatformSDKTunnelProfile` and `SharedServerStore`
  (in `PIALibrary`); this package is the extension-side engine glue only.
- The app ↔ extension hand-off (selected location, server list, protocol) flows through `SharedServerStore`
  (file-based shared state in the App Group), read here by `PIAEndpointRepository` / `PIAPacketTunnelProvider`.

## Dependencies

- `KapeVPN-PacketTunnel` (from `../KapePlatformSDK`) — the reused tunnel engine + WireGuard controller.
- `PIALibrary` — `SharedServerStore`, `AppConstants`, `Server`, and PIA account/crypto helpers.

> Built in Swift 5 language mode to match the code's original (non-strict-concurrency) compilation context.
