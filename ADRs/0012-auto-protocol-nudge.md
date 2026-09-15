# 0012: Nudge users pinned to a failing protocol to switch to Automatic

Date: 2026-09-15

## Context

After [ADR-0008](0008-integrate-kape-platform-sdk-vpn-engine.md) and
[ADR-0011](0011-retire-the-legacy-vpn-stack.md), every platform runs the PlatformSDK tunnel and
protocol is a *preference*, not a profile: the tunnel reads `Client.preferences.vpnType` and runs
`automatic` (WireGuard first, then OpenVPN), `wireGuard`, or `openVPN`. **Automatic is the default**
and, because ADR-0011 rewrites unsupported persisted values, the default-protocol migration half of
this work is already done on iOS and tvOS.

What is missing is the recovery path for a user **pinned to a concrete protocol that cannot connect
on their network** — e.g. WireGuard UDP blocked, or an endpoint whose protocol listener is unhealthy.
Automatic would fall through to another protocol; the pinned selection does not. The SDK never emits a
terminal "this protocol will never work" failure, so the tunnel retries forever and the user sees
*Connecting…* with no hint that switching to Automatic would fix it.

The natural place to detect this is the extension, not the app:

- The connection runs in the **extension**, and the app only observes the flattened `VPNStatus`
  (`NEVPNStatus` folded with the tunnel's reported status). Attempt-level failures are not visible
  app-side.
- The app is usually **suspended** while the tunnel retries, so an app-side poll would not run when
  the problem occurs.
- The SDK exposes a **per-session / per-connection / per-attempt event stream**
  (`VpnConnectionAnalytics`) inside the extension, which is a strictly stronger signal than status
  transitions.

## Decision

### Detect in the tunnel from the SDK's analytics stream

`AutoProtocolNudgeDetector: VpnConnectionAnalytics` (in the `PIAVPN` package) is wired in
`PIAPacketTunnelProvider.start()` through `SessionControllerFactory.make(analytics:selectedProtocol:)`.
Detection runs where the events are produced, not in the app.

- The class holds all state under a `Mutex` and keeps the frequent per-attempt callbacks cheap. The
  one exception is `sessionDidBegin`, which reads the shared-state file — it is the only callback that
  does I/O, and only once per session.
- `sessionDidBegin` takes the user's protocol from `PIATunnelSharedState` rather than from the event:
  the event's `selectedProtocol` string is fixed at session start, while shared state is re-read after
  an in-place protocol switch, so the detector stops as soon as the user really moves to Automatic.
- The only SDK-side change the feature required was making `PIATunnelSharedState.TunnelProtocol`
  `Sendable`; no engine behaviour was modified.

### "Stuck" is inferred from the run of attempts

The SDK reports no terminal failure, so the detector infers it:

- **Qualifying failures only.** A failure counts only if `PacketTunnelError.suggestsProtocolChange` is
  true. Auth, no-endpoints, license-excluded endpoints, unsupported-protocol, and every DIP error are
  excluded — those follow the user to every protocol and must never nudge.
- **Dwell floor.** A session must have been failing for at least `connectTimeout` (30 s) before it can
  nudge, so a one-off slow attempt does not.
- **Trigger: a batch wrap, or an attempt-count floor.** Re-dialling an endpoint that this session
  already tried means the configuration generator wrapped — the tunnel has exhausted what this
  protocol offers, a far stronger signal than any count. Without endpoint identity (the config reports
  none), the fallback is `qualifyingAttempts` (6) failures.
- **Once per interval, at most.** Posts are rate-limited by `minimumInterval` (180 s). Because the app
  may be suspended and miss a post, the detector keeps re-posting on continued failure; this interval
  is the only retry mechanism.
- **After a successful connect, this session stops nudging.** If the protocol connected, it works;
  mid-session drops and reconnects are not treated as "pinned protocol is wrong".

### Hand off with a payload-less Darwin signal; the app owns the decision

The detector posts `PIATunnelSignal.switchToAutomaticSuggested`. Cross-process `NotificationCenter`
does not exist, so `PIATunnelSignal` bridges Darwin notifications onto the main queue, and this work
centralised the app/tunnel Darwin signals into that single `enum` rather than scattering raw names.

- The signal carries **no payload** and is **best-effort**: Darwin notifications do not wake a
  suspended process, and rapid posts coalesce. It is a prod to act on state, never the state itself.
  The app re-reads the authoritative `vpnType` and its own persisted history when it receives it.
- The signal is dropped, not queued, when the app cannot act (backgrounded, already presenting);
  the tunnel re-posts on continued failure.

### Eligibility and frequency caps live in the app

`AutoProtocolNudgeCaps` (in `PIA Common`, shared by iOS and tvOS) is pure policy — it takes a
`History` snapshot and a clock and answers `allowsPrompt`. `History` is persisted by
`AppPreferences` (prompt dates, dismiss count, last dismissal, accepted flag) and surfaced through
`autoProtocolNudgeHistory` / `record…` helpers. The caps are shared by iOS and tvOS so both platforms
nag at the same rate:

| Cap | Value |
|---|---|
| Minimum time between prompts | 14 days |
| Lifetime prompt cap | 3 |
| Dismiss cooldown | 7 days |
| Dismissals that stop it permanently | 2 |
| Stop after accepting | yes, forever |

Keeping this in the app — not the tunnel — keeps the extension side stateless about UI policy, and
matches where the prompt and the user's preferences already live.

### The prompt is advisory; accepting is an in-place protocol switch

- **iOS** presents a `PopupDialog` via `SwitchToAutomaticPrompt` (a singleton observing the signal),
  guarded by app-active, not-already-Automatic, and the caps. **tvOS** presents a SwiftUI alert bound
  to `SwitchToAutomaticPromptViewModel`, seeded with the live scene phase so it is fail-closed.
- Accepting writes `vpnType = automatic`, posts `.ReloadSettings`, and calls `connect()`. On a live
  PlatformSDK tunnel `connect()` writes the new target to shared state and sends `switchLocation`, so
  the change is an **in-place session restart** — no profile reinstall and no disconnect flash. It
  only re-applies when a session is up; accepting while disconnected just changes the preference.
- Strings live in `PIALocalizations` as `auto_protocol_nudge.{title,message,confirm,dismiss}` and are
  rendered through `L10n` on both platforms.

### Scoping: what this is not

- It is **not** the default-protocol migration — that shipped with ADR-0011.
- It does **not** try to detect a connected-but-dead tunnel. That needs app-side reachability and
  conflicts with "stop after a successful connect"; the analytics stream does not provide it.
- The trigger is tuned to the signal the SDK actually gives (batch wrap / attempt count) rather than
  to a fixed failure count, and the caps exist so the prompt cannot become noise.

## Consequences

- **The nudge is best-effort by construction.** A post that lands while the app is suspended is lost,
  and the app can wait up to `minimumInterval` (180 s) after returning to the foreground for the next
  one. A persisted "suggestion pending" marker read on foreground would remove that latency; it was
  considered and deferred as a UX improvement, not a correctness fix.
- **Post-connect failures are not nudged.** A tunnel that connects once and then cannot re-establish
  on the pinned protocol will not be offered Automatic for the rest of the session. This was chosen
  deliberately ("if it connected, the protocol works"), at the cost of not catching a protocol that
  connects and then immediately drops.
- **Tuning is a release.** Thresholds live in `AppConstants.AutoProtocolNudge` (PIALibrary), compiled
  in so both the tunnel detector and the shared caps read one source of truth; changing them needs an
  app/extension release. They are injectable (`AutoProtocolNudgeDetector.Thresholds`, `now`, `post`,
  `selectedProtocol`) so the decision is unit-tested without wall-clock or OS dependencies.
- **Testing spans three homes.** The detector's decision logic is tested in the package
  (`LocalPackages/PIAVPN/Tests/PIAVPNTests/`); the iOS guard/caps via `shouldPresent` in
  `PIA VPNTests`; the tvOS view model in `PIA VPN-tvOSTests`. The package test target was added to the
  iOS test plan.
- **The feature is one more consumer of the app/tunnel IPC.** It relies on the
  `PIATunnelSharedState` + `PIATunnelSignal` model from ADR-0008, and it keeps the extension free of
  UI/preferences policy: detection in the tunnel, decision and presentation in the app.
