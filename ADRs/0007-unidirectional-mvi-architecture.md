# 0007: Unidirectional Data Flow (MVI) Architecture

Date: 2026-07-07

## Context

PIA iOS adopts a **lightweight, hand-rolled unidirectional data flow (MVI) architecture** as the shared Apple-platform standard for new and migrated features. This document records the PIA-specific context, current pain points, and first adoption targets.

### Starting position

The navigation layer is already governed by ADR 0006 (Coordinator pattern). The codebase has more SwiftUI Views than ViewControllers and has a developed reactive substrate with `ObservableObject` and `@Published` in use. However, PIA shares a class of state and testability problems that unidirectional data flow is designed to solve.

### Current pain points

**1. `Client.providers` as a global service locator**

`Client.providers` is referenced across the codebase as the de-facto way to obtain any service — VPN provider, account provider, server provider, preferences. It is a global, mutable, process-wide dependency graph with no injection seam. Code that calls `Client.providers.vpnProvider` cannot be unit tested without the full `Client` stack being initialised.

**2. `NotificationCenter` as an implicit coordination bus**

30 `NotificationCenter.default.post` call sites and `addObserver` call sites. This is a second hidden dependency graph: events flow between features and layers with no compile-time contract, no defined ownership, and implicit ordering.

**3. Large provider classes with mixed concerns**

The `PIALibrary` local package contains several large, multi-responsibility types:

- `Client+Preferences.swift` — 793 lines, a preferences god object over `UserDefaultsStore`.
- `UserDefaultsStore.swift` — 790 lines, direct `UserDefaults` access with no seam.
- `DefaultAccountProvider.swift` — 701 lines, mixing account API, caching, and domain logic.
- `DefaultVPNProvider.swift` — 448 lines, VPN state, profile management, and connection logic in one class.

These classes have no separation between "what is the state" and "how do we mutate it."

**4. VPN connection state is implicit**

`DefaultVPNProvider` manages connection state via a combination of `NEVPNManager` callbacks, `NotificationCenter` posts, and internal mutable properties. There is no single value that represents "what state is the VPN in right now." This makes the VPN state machine hard to reason about, hard to test, and prone to race conditions.

**5. `PIALibrary` is not designed for testability**

The existing test suite has coverage for account use cases (`UpdateAccountUseCaseTests`, 389 lines), but the VPN and preferences layers have little to no unit test coverage. The `Client.providers` dependency model makes it structurally difficult to test any logic that touches VPN state without a real Network Extension.

### Impact

- **Testability:** VPN state and preferences logic depend on `Client.providers`, making them effectively untestable in isolation.
- **Defects:** `NotificationCenter`-coordinated state transitions produce hard-to-reproduce bugs — especially around VPN connect/disconnect sequencing.
- **Onboarding:** new engineers must understand both `Client.providers` and the `NotificationCenter` event map to trace any non-trivial flow.
- **Security:** unpredictable VPN state is a trust and safety concern, not just a code quality one.

### Why not keep the current approach?

The `Client.providers` service locator and `NotificationCenter` coordination layer produce unpredictable, untestable state transitions. A SwiftUI view calling `Client.providers.vpnProvider` directly is the same anti-pattern as a UIKit view controller calling a shared singleton. The reactive substrate (`@Published`, `ObservableObject`) already exists in PIA but is used inconsistently; unidirectional flow brings discipline to it rather than adding a new mechanism.

### Why not adopt TCA?

TCA is the best-known library embodiment of this pattern in Swift and is the reference design this ADR mirrors. We are not adopting it (yet) because:

1. It is a large external dependency with documented build-time regressions caused by SwiftSyntax macro compilation, conflicting with the project's minimal-dependency philosophy.
2. The iOS 15 deployment target requires Point-Free's Perception backport.
3. Its steep learning curve is a real cost for a rotating team.
4. Frequent breaking releases create lockstep upgrade pressure across all teams consuming it.

The door remains open: a hand-rolled store that mirrors TCA's core concepts is a natural stepping stone. If needs outgrow this design, migrating to TCA is an evolution, not a rewrite.

---

## Decision

We adopt a **lightweight, hand-rolled unidirectional data flow (MVI) architecture** for complex features in PIA iOS. The pattern is commonly labelled **MVI (Model–View–Action)**; in native Swift the same concept is called a *Redux-like / unidirectional store*. It is the same idea as TCA's core loop, without the framework.

The slogan: *state flows down, actions flow up.*

### Scope

This architecture is **not applied universally**. Unidirectional MVI is the right choice when:

- State is a genuine state machine (e.g. connecting / connected / reconnecting / error).
- There are optimistic updates, error recovery, or multiple transient states.
- Correctness must be unit-test-provable (VPN, auth, purchases).
- Multiple async inputs converge (engine + API + timers).

**MVVM remains acceptable** for simple, read-only, or low-risk screens.

The first adoption targets for PIA — where MVI delivers the most leverage:

1. **VPN connection state machine** — today scattered across `DefaultVPNProvider` (448 lines), `NotificationCenter` callbacks, and `NEVPNManager` delegates.
2. **Account / auth flow** — `DefaultAccountProvider` (701 lines) mixes API calls, caching, and domain state.
3. **Server selection** — depends on `Client.providers.serverProvider` and `NotificationCenter` for updates.

### `Client.providers` as the migration seam

`Client.providers` is the incumbent singleton graph. The migration strategy wraps it behind a `Dependencies` struct injected into the reducer. The reducer never calls `Client.providers` directly; the live dependency wiring does.

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

ADR 0006 defines the navigation layer. This ADR defines the state and business logic layer. A coordinator starts a feature by creating its `Store` and handing it to the feature view — the two are complementary.

### Shared Apple-platform standard

The `State` / `Action` / `Reducer` / `Dependencies` layer is UI-agnostic. Feature logic shared across Apple-platform products (VPN connection, auth, server selection) belongs in shared SPM packages. All products converge on:

- the same unidirectional pattern and code-review checklist,
- shared, tested feature logic for overlapping domains,
- per-app thin SwiftUI view and live-dependency wiring only.

---

## Consequences

### Positive

- **Testability without a device.** Wrapping `Client.providers` behind `Dependencies` closures makes VPN and account logic testable on CI without a real Network Extension.
- **Replaces `NotificationCenter` coordination.** State transitions become explicit `Action`s dispatched through the store; `NotificationCenter` observers are replaced by typed state updates.
- **Builds on existing reactive investment.** PIA already has `ObservableObject` and `@Published` in use. The `Store` uses the same substrate — it brings discipline to what already exists rather than adding a new mechanism.
- **SwiftUI-first codebase is a tailwind.** With more SwiftUI Views than ViewControllers, new features adopt MVI from day one with less UIKit bridging required.

### Neutral

- **`ObservableObject` today, `@Observable` later.** iOS 15 minimum means `ObservableObject` now; the swap to `@Observable` is localized to the `Store` when the deployment target moves to iOS 17.
- **`Client.providers` remains during migration.** The live wiring still calls `Client.providers`; the change is that the reducer cannot see it. The singleton is progressively replaced as features are migrated, not as a precondition.
- **MVVM and MVI coexist.** Both patterns are intentional; engineers need to know which governs which screen.

### Negative

- **Bespoke pattern — documentation burden.** This is not a named library. It must be documented, maintained across iOS releases, and onboarded into by every new engineer. This ADR is the starting point; it is not sufficient long-term without a reference feature implementation and internal guidelines.
- **Effect discipline.** Async cancellation and backoff inside `Effect`s must be reviewed carefully, especially for VPN reconnect logic.
- **No CI enforcement.** Code review is the only gate against a reducer calling `Client.providers` directly.
- **`PIALibrary` refactor is a longer-term investment.** The large provider classes (`DefaultVPNProvider`, `DefaultAccountProvider`) will need to be broken up before their logic can sit cleanly inside a reducer. This is a migration cost, not a blocker — the `Dependencies` seam lets new features be clean while the library evolves.

---

## References

- ADR 0006 — iOS Coordinator navigation pattern; the complementary navigation layer.
- `LocalPackages/PIALibrary/Sources/PIALibrary/VPN/DefaultVPNProvider.swift` — primary first migration target.
- `LocalPackages/PIALibrary/Sources/PIALibrary/Account/DefaultAccountProvider.swift` — second migration target.
- [pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) — the reference framework this pattern mirrors; the intended upgrade path if the hand-rolled design is outgrown.
