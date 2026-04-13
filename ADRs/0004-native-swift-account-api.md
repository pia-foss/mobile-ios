# 0004: Replace KMP PIAAccount with a native Swift implementation

Date: 2026-03-30

## Context

The iOS and tvOS apps relied on a Kotlin Multiplatform (KMP) library (`mobile-ios-releases-account`) for all account-related API operations: login, signup, token management, account details, subscriptions, and logout.

The KMP approach introduced several friction points:

- **Debugging difficulty.** KMP code runs as a compiled binary. Stepping through account operations in the Xcode debugger was not possible — breakpoints could not be set inside the library, error origins were opaque, and crash stack traces pointed into unreadable KMP frames.
- **Slow iteration.** Any change to account API logic required modifying the KMP repository, cutting a release, updating the version pin, and re-integrating. This round-trip added significant delay to even small fixes.
- **Interoperability overhead.** The KMP module exposed Objective-C-compatible types, requiring bridging code and explicit casting throughout Swift call sites. Swift `async/await` could not be used directly with KMP callbacks.
- **Limited testability.** The KMP layer could not be mocked at the Swift level in unit tests without additional wrapper protocols.

## Decision

Replace the KMP `mobile-ios-releases-account` package with a new local Swift package, `PIAAccount`, located at `LocalPackages/PIAAccount/`. The package provides a native Swift implementation of all account API operations and is consumed by `PIALibrary` as a local path dependency.

`PIAWebServices` now consumes `PIAAccountAPI` via `PIAAccountBuilder`. All web service methods are `async throws`, enabling direct use of Swift concurrency throughout `PIALibrary` and removing the callback-based layer entirely.

## Consequences

- Full Xcode debugger support — breakpoints, variable inspection, and stack traces work inside account operations end-to-end.
- Changes to account API behaviour can be made directly in the local package and take effect on the next build, with no external release cycle.
- Native `async/await` throughout, removing all callback indirection in `PIALibrary`'s account layer.
- `PIAAccountAPI` is a protocol, so `PIAAccountClient` can be replaced with a mock in unit tests without additional bridging.
- `PIAAccount` is not independently versioned. Changes to its public API require coordinated updates in `PIALibrary`.
