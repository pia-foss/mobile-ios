# 0007: Unidirectional Data Flow (MVI) Architecture

Date: 2026-07-07

## Context

This ADR adopts the same **unidirectional data flow (MVI) architecture** defined for the CyberGhost Apple client in [CG ADR 0010] as the shared standard for PIA iOS. The decision, primitives, and dependency model are identical; this document records the PIA-specific context, current pain points, and first adoption targets.

### PIA vs CyberGhost — starting position

PIA is in a better structural position than CyberGhost at the time of this ADR: the codebase is smaller (~42k LOC, 935 Swift files), has more SwiftUI Views than ViewControllers (66 vs 44), and has a more developed reactive substrate (25 files with `@Published`, 21 with `ObservableObject`). The navigation layer is already governed by ADR 0006 (Coordinator pattern).

However, PIA shares the same class of state and testability problems — in a different form.

### Current pain points

**1. `Client.providers` as a global service locator**

`Client.providers` is PIA's equivalent of CyberGhost's singleton web. It is referenced **242 times** across the codebase as the de-facto way to obtain any service — VPN provider, account provider, server provider, preferences. It is a global, mutable, process-wide dependency graph with no injection seam. Code that calls `Client.providers.vpnProvider` cannot be unit tested without the full `Client` stack being initialised.

**2. `NotificationCenter` as an implicit coordination bus**

30 `NotificationCenter.default.post` call sites and 139 `addObserver` call sites. Like in CyberGhost, this is a second hidden dependency graph: events flow between features and layers with no compile-time contract, no defined ownership, and implicit ordering.

**3. Large provider classes with mixed concerns**

The `PIALibrary` local package contains several large, multi-responsibility types:

- `Client+Preferences.swift` — 793 lines, a preferences god object over `UserDefaultsStore`.
- `UserDefaultsStore.swift` — 790 lines, direct `UserDefaults` access with no seam.
- `DefaultAccountProvider.swift` — 701 lines, mixing account API, caching, and domain logic.
- `DefaultVPNProvider.swift` — 448 lines, VPN state, profile management, and connection logic in one class.

These are the `PIALibrary` equivalent of CyberGhost's massive view controllers: no separation between "what is the state" and "how do we mutate it."

**4. VPN connection state is implicit**

`DefaultVPNProvider` manages connection state via a combination of `NEVPNManager` callbacks, `NotificationCenter` posts, and internal mutable properties. There is no single value that represents "what state is the VPN in right now." This makes the VPN state machine hard to reason about, hard to test, and prone to race conditions.

**5. `PIALibrary` is not designed for testability**

The existing test suite has coverage for account use cases (`UpdateAccountUseCaseTests`, 389 lines), but the VPN and preferences layers have little to no unit test coverage. The `Client.providers` dependency model makes it structurally difficult to test any logic that touches VPN state without a real Network Extension.

### Impact

- **Testability:** VPN state and preferences logic depend on `Client.providers`, making them effectively untestable in isolation.
- **Defects:** `NotificationCenter`-coordinated state transitions produce the same class of hard-to-reproduce bugs as in CyberGhost — especially around VPN connect/disconnect sequencing.
- **Onboarding:** new engineers must understand both `Client.providers` and the `NotificationCenter` event map to trace any non-trivial flow.
- **Security:** same as CyberGhost — unpredictable VPN state is a trust and safety concern, not just a code quality one.
- **Shared cost:** the same architecture investment can pay off in both products if the pattern and shared packages are aligned.

### Why not keep the current approach?

PIA's `Client.providers` service locator and `NotificationCenter` coordination layer produce the same failure modes as CyberGhost's singleton web — just with SwiftUI on top. A SwiftUI view calling `Client.providers.vpnProvider` directly is the same anti-pattern as a UIKit view controller calling `VPNManager.shared`. The reactive substrate (`@Published`, `ObservableObject`) already exists in PIA but is used inconsistently; unidirectional flow brings discipline to it rather than adding a new mechanism.

### Why not adopt TCA?

Same reasons as CG ADR 0010: large external dependency with build-time costs, frequent breaking releases, steep learning curve for a rotating team, and iOS 15 deployment target requiring the Perception backport. The hand-rolled store is the right fit for both products.

---

## Decision

We adopt the **same lightweight, hand-rolled unidirectional data flow (MVI) architecture** as CyberGhost (CG ADR 0010). The slogan, primitives, loop, dependency layers, and `Store` implementation are identical. See CG ADR 0010 for the full specification; only PIA-specific details are recorded here.

The slogan: *state flows down, actions flow up.*

### Scope

Same as CG ADR 0010: MVI for features with genuine state-machine complexity; MVVM remains acceptable for simple screens.

The first adoption targets for PIA — where MVI delivers the most leverage:

1. **VPN connection state machine** — today scattered across `DefaultVPNProvider` (448 lines), `NotificationCenter` callbacks, and `NEVPNManager` delegates.
2. **Account / auth flow** — `DefaultAccountProvider` (701 lines) mixes API calls, caching, and domain state.
3. **Server selection** — depends on `Client.providers.serverProvider` and `NotificationCenter` for updates.

### `Client.providers` as the migration seam

`Client.providers` plays the same role as `VPNManager.shared` in CyberGhost: it is the incumbent singleton graph. The migration strategy is identical — wrap it behind a `Dependencies` struct injected into the reducer. The reducer never calls `Client.providers` directly; the live dependency wiring does.

```swift
// Live — wraps Client.providers during migration
extension VPNFeatureDependencies {
    static var live: Self {
        .init(
            connect:      { try await Client.providers.vpnProvider.connect() },
            disconnect:   { await Client.providers.vpnProvider.disconnect() },
            statusStream: { Client.providers.vpnProvider.statusStream() }
        )
    }
}

// Test — no Client.providers, no Network Extension
extension VPNFeatureDependencies {
    static var test: Self {
        .init(
            connect:      { },
            disconnect:   { },
            statusStream: { AsyncStream { $0.finish() } }
        )
    }
}
```

### Relationship to ADR 0006 (Coordinator pattern)

ADR 0006 defines the navigation layer. This ADR defines the state and business logic layer. A coordinator starts a feature by creating its `Store` and handing it to the feature view — the same complementary relationship as in CyberGhost.

### CG + PIA as a shared standard

The `State` / `Action` / `Reducer` / `Dependencies` layer is UI-agnostic. Feature logic that overlaps between CyberGhost and PIA (VPN connection, auth, server selection) belongs in shared SPM packages. Both products converge on the same pattern, the same code-review checklist, and — where features overlap — the same tested implementation.

---

## Consequences

### Positive

- **Testability without a device.** Wrapping `Client.providers` behind `Dependencies` closures makes VPN and account logic testable on CI without a real Network Extension — the same gain as in CyberGhost.
- **Replaces `NotificationCenter` coordination.** State transitions become explicit `Action`s dispatched through the store; `NotificationCenter` observers are replaced by typed state updates.
- **Builds on existing reactive investment.** PIA already has `ObservableObject` and `@Published` in 21 and 25 files respectively. The `Store` uses the same substrate — it brings discipline to what already exists rather than adding a new mechanism.
- **SwiftUI-first codebase is a tailwind.** With 66 SwiftUI Views vs 44 ViewControllers, PIA is already closer to the target state than CyberGhost. New features adopt MVI from day one with less UIKit bridging required.
- **Shared standard with CyberGhost.** Patterns, code-review criteria, and feature logic are shared across both products.

### Neutral

- **`ObservableObject` today, `@Observable` later.** Same as CG ADR 0010 — iOS 15 minimum means `ObservableObject` now; the swap to `@Observable` is localized to the `Store` when the deployment target moves to iOS 17.
- **`Client.providers` remains during migration.** The live wiring still calls `Client.providers`; the change is that the reducer cannot see it. The singleton is progressively replaced as features are migrated, not as a precondition.
- **MVVM and MVI coexist.** Both patterns are intentional; engineers need to know which governs which screen.

### Negative

- **Bespoke pattern — documentation burden.** Same as CG ADR 0010. This ADR and CG ADR 0010 are the canonical references; a reference feature and internal guidelines are needed for long-term maintainability.
- **Effect discipline.** Async cancellation and backoff inside `Effect`s must be reviewed carefully, especially for VPN reconnect logic.
- **No CI enforcement.** Code review is the only gate against a reducer calling `Client.providers` directly.
- **`PIALibrary` refactor is a longer-term investment.** The large provider classes (`DefaultVPNProvider`, `DefaultAccountProvider`) will need to be broken up before their logic can sit cleanly inside a reducer. This is a migration cost, not a blocker — the `Dependencies` seam lets new features be clean while the library evolves.

---

## References

- [CG ADR 0010](/cg_apple/ADRs/0010-unidirectional-mvi-architecture.md) — the shared architecture standard; full specification of primitives, `Store` implementation, dependency layers, and rationale.
- ADR 0006 — iOS Coordinator navigation pattern; the complementary navigation layer.
- `LocalPackages/PIALibrary/Sources/PIALibrary/VPN/DefaultVPNProvider.swift` — primary first migration target.
- `LocalPackages/PIALibrary/Sources/PIALibrary/Account/DefaultAccountProvider.swift` — second migration target.
- [pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) — the reference framework this pattern mirrors; the intended upgrade path if the hand-rolled design is outgrown.
