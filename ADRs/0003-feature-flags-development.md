# 0003: Development with feature flags

Date: 2026-03-20

## Context

Pull requests that are open for too long are difficult to merge: conflicts appear while it is open. We want to merge pull requests in a timely manner. However, we might want to ship a build without a certain merged feature: buggy, not validated, or otherwise unfit to be released. Normally we would need a revert commit to remove this feature. This leads to messy git history, and the need to un-revert the change again in the future.

## Decision

We have decided that new features should be behind feature flags. Flags can either be local variables that can easily be turned off and on again at compile time, or remote configurable ones that are checked at runtime. In general, new feature flags should be remote configurable, with the default value being the old state.

All feature flags should include purpose and expiration. Anyone reading the code should understand if the flag is still valid or has become stale. Expiration can either be a date, an app release version, or a project completion.

```swift
/// Enables "some cool" feature
/// expires: after version 1.2.3
let someCoolFeature: Bool
/// Enables SwiftUI created views
/// expires: swiftui migration completed
let useSwiftUI: Bool
```

When a flag expires, a cleanup task can be created to remove it. To remove a flag is to remove the old code and the name of the flag from the remote configuration service.

## Consequences

- Feature branches can be merged knowing features can be disabled in an easy manner.
- It's clear when a flag is not needed anymore and can be deleted.
