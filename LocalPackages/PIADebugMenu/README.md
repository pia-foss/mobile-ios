# PIADebugMenu

Internal Swift package providing a full-screen debug overlay for the PIA VPN iOS and tvOS apps. Targets iOS 15 and tvOS 17. Depends on `PIALibrary`.

## What it does

`DebugMenuView` is a SwiftUI view that surfaces diagnostic information and developer actions in a single screen. It is intended for Development, Staging, and TestFlight builds only. It is never shown in production Release builds.

Sections:

| Section | Contents |
|---|---|
| App Info | App version, build environment, base URL |
| Account and Subscription | Username, plan name, product ID, expiration date, expired / renewable / recurring flags |
| Payment Receipt | Base64 receipt preview (first 300 chars); export button on iOS |
| Logs | Last N log entries (newest on top), refreshed every 2 seconds; export button on iOS |
| Subscription | Test Refund Request button (iOS only — triggers StoreKit refund sheet) |
| Support | "Send to Support (CSI)" button — calls `Client.submitDebugReport()` and displays the returned report code |

## Triggering the debug menu

### iOS — shake gesture

`UIWindow+MotionEnded.swift` overrides `UIWindow.motionEnded(_:with:)` and posts `Notification.Name.debugShakeDetected` whenever a shake event is detected. `AppDelegate+DebugMenu.swift` subscribes to that notification and presents `DebugMenuView` wrapped in a `UINavigationController` over the current top view controller.

```swift
// AppDelegate.swift (or equivalent setup point)
setupDebugMenuObserver()
```

The observer is registered only in Development/Staging builds, or in Release builds running under TestFlight:

```swift
#if DEVELOPMENT || STAGING
addDebugMenuObserver()
#else
if TestFlightDetector.shared.isTestFlight {
    addDebugMenuObserver()
}
#endif
```

### tvOS — Play/Pause button

On tvOS there is no shake gesture. Instead, the `View+DebugMenu.swift` modifier listens for `.onPlayPauseCommand` on the Siri Remote and presents `DebugMenuView` as a `fullScreenCover`. Apply it to the root view:

```swift
RootContainerView()
    .withDebugMenu()
```

The same Development/Staging/TestFlight gate applies.

## Platform differences

| Behaviour | iOS | tvOS |
|---|---|---|
| Container | `List` with `Section` headers | `ScrollView` with `VStack` |
| `DebugSection` rendering | Native `List` `Section` | Titled card with rounded rectangle background |
| `DebugInfoRow` focus | Not focusable | `.focusable()` applied for Siri Remote navigation |
| Export | `ShareLink` buttons for logs and receipt; "Export All" toolbar item | Not available |
| Subscription section | Shown (refund flow requires StoreKit on iOS) | Hidden |
| Presentation | `UIHostingController` inside `UINavigationController` | `fullScreenCover` |
| Trigger | Shake gesture | Play/Pause button on Siri Remote |

## Key components

### DebugSection

`DebugSection` is a generic container view that adapts its layout per platform.

```swift
DebugSection("My Section") {
    DebugInfoRow(label: "Key", value: "Value")
}
```

On iOS it renders as a `List` `Section`. On tvOS it renders as a bold uppercase title above a rounded card.

### DebugInfoRow

`DebugInfoRow` displays a single labelled value.

```swift
DebugInfoRow(label: "Environment", value: "Staging")
```

The label renders in `.caption` / `.secondary` style above the value in `.body` / `.primary`. On tvOS `.focusable()` is applied so rows can be highlighted with the Siri Remote.

### DebugExportFile

`DebugExportFile` is a `Transferable` wrapper used by iOS `ShareLink` buttons. It writes the given string to a named temporary file and vends it as a file transfer. It is not used on tvOS.

## Adding a new section

1. Add a private `var` in `DebugMenuView.swift` returning a `DebugSection`:

```swift
private var mySection: some View {
    DebugSection("My Section") {
        DebugInfoRow(label: "Some Key", value: someValue)
    }
}
```

2. Add it to `mainContent` in both the `#if os(tvOS)` and `#else` branches:

```swift
// tvOS
VStack(alignment: .leading, spacing: 40) {
    appInfoSection
    // ...
    mySection
}

// iOS
List {
    appInfoSection
    // ...
    mySection
}
```

3. If the section is platform-specific, wrap it with `#if os(iOS)` / `#if os(tvOS)` as appropriate (see `subscriptionSection` for an example).
