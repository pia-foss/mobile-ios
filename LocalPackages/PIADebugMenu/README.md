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

Every trigger is just a poster of `Notification.Name.debugMenuRequested` (declared in
`UIWindow+MotionEnded.swift`). The presentation side observes that one notification, so adding a trigger
for a new platform means posting it — nothing about the menu itself changes.

### iOS — shake gesture

`UIWindow+MotionEnded.swift` overrides `UIWindow.motionEnded(_:with:)` and posts
`.debugMenuRequested` whenever a shake is detected. `AppDelegate+DebugMenu.swift` subscribes and
presents `DebugMenuView` wrapped in a `UINavigationController` over the current top view controller.

```swift
// AppDelegate.swift (or equivalent setup point)
setupDebugMenuObserver()
```

### Mac Catalyst — Debug menu bar item (⌘⇧D)

A Mac cannot be shaken, so the override above is compiled out under
`targetEnvironment(macCatalyst)` and the trigger is a menu bar item instead: **Debug → Debug Menu**,
with ⌘⇧D.

`AppDelegate+DebugMenu.swift` overrides `buildMenu(with:)` to insert the menu as a sibling after
**View**, and its action posts `.debugMenuRequested`. Two things this depends on:

- `AppDelegate` is a `UIResponder` (not `NSObject`). `buildMenu(with:)` is a `UIResponder` method,
  and the responder chain is also how the item finds its action selector — the app delegate is the
  chain's last link, so the item stays enabled on every screen with no per-screen wiring.
- The insert is guarded on `builder.system == .main`, since `buildMenu(with:)` is also called for
  contextual menus.

### tvOS — Play/Pause button

On tvOS there is no shake gesture either. The `View+DebugMenu.swift` modifier listens for
`.onPlayPauseCommand` on the Siri Remote and presents `DebugMenuView` as a `fullScreenCover`. Apply
it to the root view:

```swift
RootContainerView()
    .withDebugMenu()
```

### Build gating

The menu is reachable in Development and Staging builds, and in Release builds running under
TestFlight. It is never reachable in a production App Store build. On iOS/Catalyst that decision is
`DebugMenuAvailability.isEnabled` in `AppDelegate+DebugMenu.swift`, which gates both the notification
observer and the Catalyst menu bar item; tvOS keeps an equivalent check in `View+DebugMenu.swift`.

```swift
#if DEVELOPMENT || STAGING
    return true
#else
    return TestFlightDetector.isTestFlight
#endif
```

Note that this check **cannot live in this package**. `DEVELOPMENT` and `STAGING` are
`SWIFT_ACTIVE_COMPILATION_CONDITIONS` set by `Resources/Configurations/*.xcconfig` on the app
targets, and Xcode does not propagate those conditions to local Swift packages. A copy here would
compile both branches away and leave the menu reachable only under TestFlight — so the gate stays in
the app targets and the package exposes no opinion about it.

## Platform differences

| Behaviour | iOS | tvOS |
|---|---|---|
| Container | `List` with `Section` headers | `ScrollView` with `VStack` |
| `DebugSection` rendering | Native `List` `Section` | Titled card with rounded rectangle background |
| `DebugInfoRow` focus | Not focusable | `.focusable()` applied for Siri Remote navigation |
| Export | `ShareLink` buttons for logs and receipt; "Export All" toolbar item | Not available |
| Subscription section | Shown (refund flow requires StoreKit on iOS) | Hidden |
| Presentation | `UIHostingController` inside `UINavigationController` | `fullScreenCover` |
| Trigger | Shake gesture — on Mac Catalyst, the **Debug → Debug Menu** menu bar item (⌘⇧D) | Play/Pause button on Siri Remote |

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

## Architecture

`DebugMenuView` is a state observer only: it owns a `@StateObject DebugMenuViewModel`, renders `viewModel.*` and forwards user actions to it. All state, polling and side effects live in `DebugMenuViewModel.swift`:

- `@Published` state for every value the view renders or binds to (log snapshots, entitlement JWS, alert/sheet flags, refund transactions).
- `onAppear()` / `onDisappear()` start and cancel a single refresh `Task` that polls the app log and the tunnel log every 5 seconds.
- Intents: `sendReportToSupport()`, `requestRefund()`, `selectTransaction(_:)`, `handleRefundResult(_:)`, `presentManageSubscriptions()`.

Read-only values derived from `PIALibrary` (`appVersion`, `username`, `logs`, previews, `buildExportContent()`, …) live in `Extensions/DebugMenuViewModel+Values.swift`.

## Adding a new section

1. Put any new state or side effect on `DebugMenuViewModel` (`@Published` property plus an intent method), and derived read-only values in `DebugMenuViewModel+Values.swift`.

2. Add a private `var` in `DebugMenuView.swift` returning a `DebugSection` that reads from the view model:

```swift
private var mySection: some View {
    DebugSection("My Section") {
        DebugInfoRow(label: "Some Key", value: viewModel.someValue)
    }
}
```

3. Add it to `mainContent` in both the `#if os(tvOS)` and `#else` branches:

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

4. If the section is platform-specific, wrap it with `#if os(iOS)` / `#if os(tvOS)` as appropriate (see `subscriptionSection` for an example).
