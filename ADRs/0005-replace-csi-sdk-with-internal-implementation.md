# 0004: Replace CSI SDK with internal implementation

Date: 2026-04-02

## Context

The app used an external Swift package (`mobile-ios-releases-csi` v1.3.3) to submit debug reports to the Customer Support Integration (CSI) service. This SDK was built with Kotlin Multiplatform (KMP) and distributed as a pre-built XCFramework, which meant the iOS team had no visibility into its implementation, no ability to patch it, and had to accept its abstractions as-is.

The SDK introduced several pain points:

- It defined its own `ICSIProvider` protocol with `providerType` and `reportType` concepts that did not map cleanly onto our data model, requiring adapter boilerplate in every provider.
- It shipped a large static `DeviceModel` enum that mapped raw `utsname` model identifiers to human-readable strings. Keeping this mapping in sync with new hardware releases required periodic SDK version bumps.
- It required a `logs` parameter to be passed at the call site of `submitDebugReport`, forcing the caller to collect log data before calling into the SDK rather than letting the provider collect it internally.
- Taking an external dependency for a thin HTTP client over a well-documented 3-step API added maintenance overhead with no proportional benefit.

## Decision

We replaced the external CSI SDK with a small internal package (`LocalPackages/PIACSI/`) that has no external dependencies.

The public surface is a single `CSIDataProvider` protocol:

```swift
public protocol CSIDataProvider {
    var sectionName: String { get }
    var content: String? { get }
}
```

The raw `utsname` model code is sent as-is instead of being mapped to a display name. This removes the maintenance burden of the device model enum and is sufficient for support purposes.

Log collection is handled internally by `PIACSILogInformationProvider`, which reads the last 200 entries from `PIALogHandler`. The 200-entry cap keeps submissions within WAF size limits without requiring the caller to pre-truncate.

The HTTP flow (POST `/create` → POST `/{code}/add` → POST `/{code}/finish`) is implemented in `CSIClient.swift` using `URLSession` with a random UUID multipart boundary per submission to prevent collisions with log content.

## Consequences

- The external `mobile-ios-releases-csi` dependency is removed from `PIALibrary`.
- New data providers only need to conform to `CSIDataProvider` and be added to the providers array in `PIAWebServices+Ephemeral.swift`; no SDK knowledge is required.
- Device model display names are no longer translated — support tooling receives the raw `utsname` identifier (e.g. `iPhone14,2`).
- The `DeviceModel.swift` file (~500 lines) is deleted.
- All data is collected internally by providers; `submitDebugReport` requires no parameters.
