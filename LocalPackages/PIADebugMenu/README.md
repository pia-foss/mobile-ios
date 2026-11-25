# PIADebugMenu

Internal Swift package providing a full-screen debug overlay for the PIA VPN iOS and tvOS apps. Targets iOS 15 and tvOS 17. Depends on `PIALibrary`.

## What it does

`DebugMenuView` is a SwiftUI view that surfaces diagnostic information and developer actions in a single screen. It is intended for Development, Staging, and TestFlight builds only. It is never shown in production Release builds.

Sections:

| Section | Contents |
|---|---|
| App Info | App version, build environment, base URL |
| VPN | Status, connected via, protocol, local IP, and the VPN IP twice — as PIA's connectivity checker reports it, and as ipify independently sees it (they should agree) |
| Connection Configurations | The endpoints the tunnel will attempt, in attempt order, labelled by protocol — first 25 on screen, all of them in Export |
| Account and Subscription | Username, plan name, product ID, expiration date, expired / renewable / recurring flags |
| Payment Receipt | Base64 receipt preview (first 300 chars); export button on iOS |
| Logs | Last N log entries (newest on top), refreshed every 5 seconds; export button on iOS |
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
#if DEBUG || STAGING
    return true
#else
    return TestFlightDetector.isTestFlight
#endif
```

Note that this check **cannot live in this package**. `DEBUG` and `STAGING` are
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

## File layout

```
Sources/PIADebugMenu/
├── Presentation/
│   ├── DebugMenu.swift                   State, Action, Output, Dependencies
│   ├── DebugMenu+Reducer.swift           state transitions and effects (polling, refresh, report, refund)
│   ├── DebugMenu+Values.swift            read-only values derived from state (previews, export)
│   ├── DebugMenu+Live.swift              the real dependencies: Client, StoreKit, Probes
│   └── DebugMenuStore.swift              Store typealias
├── UI/
│   ├── DebugMenuView.swift               the screen: layout and one private var per section
│   └── Components/                       reusable view pieces (DebugSection, DebugInfoRow, DebugExportFile)
├── Extensions/                           extensions on other types, one file per `X+Y`
└── Probes/                               ask the system or the network something, return a value
```

`Probes/` is the one that needs explaining. `VPNConnectionState` reads NetworkExtension and the tunnel
interfaces; `IpifyAddress` does an HTTP round-trip. Both answer a question about the device rather than
rendering anything, and neither belongs to the view or the reducer — a new data source goes here, and
is reached through a closure on `DebugMenu.Dependencies`.

## Architecture

The menu follows the unidirectional `CoreArchitecture` pattern used by every SwiftUI feature (ADR 0009):

- `DebugMenuView` owns a `DebugMenuStore`, renders `store.state` and dispatches `DebugMenu.Action`s. Sheet and alert flags are bound with `store.binding(_:send:)`, so dismissing one also goes through the reducer.
- `DebugMenu.Reducer` is pure. On `.onAppear` it starts two streams: `pollTicks` (every 5 seconds: app log, account, live VPN info, VPN connection, and the tunnel log unless a CSI report is in flight) and `connectionConfigurationChanges` (event-driven). `.onDisappear` cancels both. The ipify lookup reruns only when the VPN connection changes.
- `DebugMenu.Dependencies.live(emit:)` is the only place that touches `Client`, StoreKit or the probes. The host passes it in and receives `.dismiss` through `emit`:

```swift
DebugMenuView(dependencies: .live(emit: { output in
    switch output {
    case .dismiss: // close the menu
    }
}))
```

Reducer behaviour is covered by `Tests/PIADebugMenuTests` using `TestStore`.

## Adding a new section

1. Add the value to `DebugMenu.State`. If it comes from outside, add a closure to `DebugMenu.Dependencies` (implemented in `DebugMenu+Live.swift`), plus an action that stores the result and an effect in the reducer that fetches it. Derived read-only values go in `DebugMenu+Values.swift`.

2. Add a private `var` in `DebugMenuView.swift` returning a `DebugSection` that reads from state:

```swift
private var mySection: some View {
    DebugSection("My Section") {
        DebugInfoRow(label: "Some Key", value: state.someValue)
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
