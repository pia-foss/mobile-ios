# 0010: AmneziaWG censorship circumvention

Date: 2026-09-03

**Status: accepted.**

The **provisional measures** below are correct for now and wrong as permanent architecture; each has a
named exit condition.

## Context

KM-16249 adds AmneziaWG (AWG) to the automatic-protocol pecking order as a censorship-circumvention
step: AWG is tried first in censored countries, falling through to plain WireGuard and then OpenVPN.

The client chain is implemented and verified on an iOS device, end to end through the real
country-detection path:

```
Country DE — using the censorship pecking order          (DE temporarily treated as censored, to test)
Step 1/4 (WireGuard amnezia :1338): took 3 of 3 candidate endpoint(s)
AmneziaWG obfuscation resolved — s1: 5, s2: 3, jc: 5, jmin: 25, jmax: 100, h1: 1234567891, …
[wg] UAPI: Updating junk_packet_count … transport_packet_magic_header      (all nine)
[wg] peer(xUpc…iojk) - Received handshake response
result=connected … port: 1338, protocolDescription: "WireGuard+Amnezia"    (3.5s)
```

Traffic flows, with no DNS or IPv6 leaks.

---

## Settled decisions

### 1. Censored countries are resolved in the app, from `/api/geo`

The country comes from `GET /api/geo` (`country_code2`), and `["CN", "IR", "RU"]` selects
`censorshipPeckingOrder`. The lookup lives in the **app**, not the tunnel:

```
ConnectivityDaemon (only while !connectivity.isVPN)
  → geoCheck() → /api/geo → plain.geoCountryCode
KapePlatformSDKTunnelProfile.doSave → PIATunnelSharedState.writeConnectionInputs(…, geoCountryCode:)
PIAEndpointRepository.peckingOrder(for:)  (tunnel) → censorship | normal
```

Why not the tunnel: `generateConfigurations()` runs at connect *and every reconnect*, and a lookup from
inside the tunnel returns the **exit node's** country — a reconnect in China would report "US".
`using_pia_server: false` is only trustworthy while disconnected. It would also add a blocking round
trip to every connect, and the tunnel can start with no app running (on-demand rules), so it needs a
cached answer rather than a live fetch.

Verified on device: geo written while disconnected, and **not** written while connected — only `vpnIP`
was updated then.

Supporting choices:

- **Shared state carries the country code, not a boolean.** The censored set sits beside
  `censorshipPeckingOrder`, so "what counts as censorship" lives next to "what we do about it", and the
  tunnel logs the code so support can see why an order was chosen.
- **Unknown country → normal order (fail open).** Only some regions serve AWG, so guessing censorship
  would waste three connection attempts.
- **A failed lookup keeps the last known value.** A stale country beats none, and a wrong one only
  reorders attempts — it never breaks connectivity.
- **No TTL.** Refresh already happens on every reachability change and disconnect.

**Known gap:** if `/api/geo` is blocked inside a censored country — which is what censorship does — we
fall back to the normal order precisely where the censorship order was wanted. Last-known-good covers a
returning user; a **first** launch behind the firewall gets it wrong. Whether to offer a manual
"I'm in a censored country" override is an open product question.

### 2. Never hardcode the obfuscation parameters

`/add-awg-key` currently returns identical values from every server, and `h1`–`h4` are
`1234567891`–`1234567894` — AmneziaWG's stock example magic headers. Read them per connection anyway.

Fixed magic headers are exactly what DPI fingerprints, so production deployments are expected to
randomise them. This decision is permanent; it is recorded because the constant-looking values invite
the opposite shortcut.

### 3. `awg` is a separate address list, and not user-selectable

Server-list v7 advertises `awg` endpoints as **distinct addresses from `wg`**, each carrying its own
`port` (1338, which serves both the tunnel and the key exchange). There is no `groups.awg` block, so
the port only ever comes from the entry itself.

`amneziaAddressesForUDP` is therefore excluded from `Server.addresses()`, `hasEndpoints(for:)`,
`bestAddress()` and `updateResponseTime`: AWG is an automatic-mode step, not a protocol a user picks,
and it must not make a region pingable or "usable" on its own.

**Trap this creates:** anything that maps a connected host back to a server must include the `awg`
addresses. `PIAPacketTunnelProvider.advertises(_:host:)` did not, so `serverId` came back `nil`, the
write-back cleared the active connection, and the app showed "Automatic" with dashes in the connection
tile — while the debug menu and CSI obfuscation rows went blank for the same reason. Note the guard in
`writeBackActiveConnection` clears silently, which is why this surfaced as a UI oddity rather than a
log line; check it first if app-side connection details ever go blank while the tunnel is up.

---

## Provisional measures

### T1. Force-load the Amnezia Go archive in the tunnel targets

Two static archives export an identical `wg*` C API:

| archive | source | Amnezia support |
|---|---|---|
| `PIAWireguardGo.a` | `mobile-ios-wireguard` 1.0.6, via `PIALibrary` | no |
| `libwg-go.a` | `KapePlatformSDK/WireGuardKitGo` | yes |

`PlatformSDK-Tunnel-iOS` links `PIAVPN` + `PIALibrary`, and `PIALibrary` pulls `PIAWireguard` for the
legacy WireGuard path. Static-archive members load only on demand, so the plain archive satisfied every
`wg*` symbol first and `libwg-go.a` was never pulled: the tunnel ran a wireguard-go with no Amnezia
support and rejected the parameters with `IPC error -22: invalid UAPI device key: jc`.

**Measure:** force-load the Amnezia archive, via per-SDK `OTHER_LDFLAGS` on all three configurations of
`PlatformSDK-Tunnel-iOS`:

| SDK condition | slice |
|---|---|
| `[sdk=iphoneos*]` | `ios-arm64` |
| `[sdk=iphonesimulator*]` | `ios-arm64_x86_64-simulator` |
| `[sdk=macosx*]` (Mac Catalyst) | `ios-arm64_x86_64-maccatalyst` |

`PlatformSDK-Tunnel-tvOS` needs nothing: `PIALibrary/Package.swift` gates `PIAWireguard` behind
`.when(platforms: [.iOS, .macCatalyst])`, so the plain archive is never in the tvOS link.

Safe because the two archives export exactly the same symbol set (verified with `nm`), so the plain
archive is never pulled and the link stays free of duplicate symbols. Verified on all four platforms:
the built tunnel binary contains the Amnezia backend in every case.

**Why provisional:** it hardcodes vendored xcframework paths into three build configurations, must be
repeated for every new platform or slice, and leaves the wrong archive in the link — relying on load
order rather than removing it.

**Exit condition:** `PIAWireguard` no longer reaches the tunnel extension's link — remove
`mobile-ios-wireguard` from `PIALibrary/Package.swift` once the legacy WireGuard path is retired
(`KapePlatformSDKVPNType` already notes `PIAWGTunnelProfile` is "being removed"), then delete the
`OTHER_LDFLAGS` overrides. Delete the three `OTHER_LDFLAGS[sdk=...]` blocks whole rather than editing
them: a per-SDK conditional *replaces* the base `OTHER_LDFLAGS` instead of appending to it, which is why
each block repeats `-lresolv`. Removing them falls back to the base `OTHER_LDFLAGS = "-lresolv"` — which
is exactly what `PlatformSDK-Tunnel-tvOS` already carries, so matching tvOS is the check that the
removal is complete.

### T2. All-zero placeholder before auth, failing closed after it

The pecking order must decide it is building an amnezia endpoint before the parameters exist — the
value gates the endpoint's label and the SDK's `amneziaEnabled` skip.

**Measure:** build the step with `PIAEndpointRepository.amneziaPlaceholder` (all zeros) and have
`PIAWireguardAuthenticator` overwrite it from the response. If an amnezia endpoint's response carries no
`obfuscation`, the authenticator throws `.missingObfuscation` rather than connecting: zeroed magic
headers would otherwise burn three attempts on a handshake that cannot succeed.

**Why provisional:** a placeholder that is only ever valid because something downstream replaces it is a
sharp edge. The SDK modelling "amnezia, parameters pending" explicitly would be cleaner.

**Exit condition:** either an SDK obfuscation case expressing "pending", or backend delivery of the
parameters in the server list, which removes the ordering problem entirely.

**Known test gap:** the assignment and the fail-closed path are not unit-tested — `authenticate`
performs the request and the enrichment in one method, and a seam introduced to test them was
deliberately reverted as not worth a single-call-site indirection. The success path is device-verified;
the guard is verified by inspection only, since the server has always returned the parameters.
