[![PIA logo][pia-image]][pia-url]

# PIAWireguard

WireGuard® tunnel library for the Private Internet Access iOS app. This local Swift package provides the `PIAWireguard` product consumed by `PIALibrary`.

## Overview

The package is built on top of [Amnezia WireGuard Go](https://github.com/amnezia-vpn/amneziawg-go) — a fork of `wireguard-go` that adds optional DPI-evasion obfuscation. It currently operates in **vanilla WireGuard mode** (no obfuscation active), providing a drop-in replacement that lays the foundation for future obfuscation support.

## Rebuilding the Go binary

The xcframework is pre-built and committed. Only rebuild when changing Go source or dependencies.

**Requirements:** Go 1.25+, Xcode command line tools

```bash
cd wireguard-go-bridge
./build.sh                         # compiles → lib/

cd ..
./create-libwg-go-xcframework.sh   # packages → PIAWireguardGo.xcframework
```

Then commit the updated `PIAWireguardGo.xcframework`.

> **Important:** `build.sh` uses `GOOS=ios` (not `GOOS=darwin`). This is required for correct syscall and signal handling in the iOS Network Extension sandbox.

## How the tunnel works

1. `WGPacketTunnelProvider` starts the tunnel by calling `wgTurnOn` with a WireGuard UAPI config string
2. A connectivity timer checks RX bytes every 10 seconds — if bytes are stale and the last handshake is older than 120 seconds, a ping is sent; after 6 consecutive failures the tunnel is stopped so the app can trigger server failover
3. `wgBumpSockets` is called on network path changes to rebind the UDP socket
4. `wgTurnOff` tears down the tunnel cleanly

## Requirements

- iOS 15+, tvOS 17+
- Swift 6
- Go 1.25+ (only needed to rebuild the xcframework)

## Acknowledgements

- [WireGuard®](https://www.wireguard.com/) — © Jason A. Donenfeld
- [Amnezia WireGuard Go](https://github.com/amnezia-vpn/amneziawg-go) — © Amnezia VPN contributors

[pia-image]: https://www.privateinternetaccess.com/assets/PIALogo2x-0d1e1094ac909ea4c93df06e2da3db4ee8a73d8b2770f0f7d768a8603c62a82f.png
[pia-url]: https://www.privateinternetaccess.com/
