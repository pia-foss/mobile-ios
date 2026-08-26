# 0007: iOS Navigation Architecture — Coordinator Pattern

Date: 2026-06-05

## Context

The PIA iOS app has no unified navigation architecture. Navigation decisions are scattered across view controllers, `NotificationCenter` observers, and `RootCoordinator.shared` — a singleton that manages the top-level root switch between login and main but does not extend into individual flows.

### Current pain points

**1. `RootCoordinator` is a singleton root-switcher, not an architecture**
`RootCoordinator.shared` handles the `login ↔ main` root swap but exposes itself globally via `static let shared`. It is not composable, not testable in isolation, and cannot be extended to own child flows without becoming a monolithic object.

**2. Navigation via NotificationCenter**
The app uses `NotificationCenter` extensively for navigation-adjacent events (VPN status changes, account updates, theme changes). This means that adding a new screen often requires posting a notification and listening for it in a VC that then decides what to show. The caller has no compile-time knowledge of whether anything is listening.

**3. Views and ViewControllers driving flow**
Login completion is handled inside `PIAWelcomeViewControllerDelegate` methods directly on `RootCoordinator`, mixing authentication callbacks with root UI transitions. The delegate pattern tightly couples the navigation decision to the calling layer.

**4. No flow ownership**
There is no object that owns a flow end-to-end (e.g. onboarding, VPN permission grant, server selection). Individual VCs present or push the next screen themselves, using storyboard segues or direct `present`/`push` calls — making flows hard to trace, reuse, or test.

**5. SwiftUI-first direction, UIKit legacy**
New screens are SwiftUI. The existing architecture (storyboards, `UINavigationController`, `UISplitViewController`) is UIKit. A navigation architecture must bridge both without requiring a big-bang rewrite of legacy screens.

### `RootCoordinator` as starting point

The existing `RootCoordinator` (`PIA VPN/Core/RootCoordinator.swift`) is already structurally close to a coordinator: it owns the `UIWindow`, makes root-switch decisions, and creates child view controllers. It should be evolved into a proper coordinator rather than replaced. Its `static let shared` will be removed as part of adoption — callers that currently reference it will instead receive it through dependency injection.

## Decision

### Core principle

**A screen should never know what comes next.** That responsibility belongs exclusively to the coordinator that owns the flow. This single rule drives every decision below.

### `Coordinator` protocol

```swift
protocol Coordinator: AnyObject {
    func start()
}
```

The protocol is intentionally minimal. `start()` is the only universal contract. `childCoordinator` and `cancellables` are **not** part of the protocol — they are implementation details of coordinators that happen to own child flows. Not all coordinators have children. Swift protocols cannot provide stored property defaults, so including them would force every conformer to carry unused boilerplate.

### Coordinator output events

Every coordinator that communicates results upward exposes a typed `Output` enum and a Combine publisher. The parent subscribes; the child fires events. Neither knows about the other's internals.

```swift
enum OnboardingOutput {
    case didFinish
    case didSkip
}

final class OnboardingCoordinator: Coordinator {
    private let subject = PassthroughSubject<OnboardingOutput, Never>()

    var output: AnyPublisher<OnboardingOutput, Never> {
        subject.eraseToAnyPublisher()
    }
}
```

The parent coordinator subscribes when it starts the child and cancels by releasing the subscription when the child flow ends:

```swift
final class AppCoordinator: Coordinator {
    private var childCoordinator: (any Coordinator)?
    private var cancellables = Set<AnyCancellable>()

    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        childCoordinator = coordinator

        coordinator.output
            .sink { [weak self] event in
                switch event {
                case .didFinish, .didSkip:
                    self?.showMain()
                }
            }
            .store(in: &cancellables)

        coordinator.start()
    }

    private func showMain() {
        cancellables.removeAll() // cancel onboarding subscription
        let coordinator = MainCoordinator(navigationController: navigationController)
        childCoordinator = coordinator
        // ... subscribe to coordinator.output, store in cancellables
        coordinator.start()
    }
}
```

**Key rules:**
- `cancellables.removeAll()` must be called before replacing a child coordinator, to cancel the outgoing subscription.
- The parent holds a `strong` reference to the child via `childCoordinator`. Setting a new value releases the previous coordinator.
- Subscriptions are always stored in `cancellables`. A subscription not stored is silently cancelled immediately.

### VC and View output closures — no coordinator references

ViewControllers and SwiftUI views **do not hold coordinator references**. Instead, they expose output closures that the coordinator injects when it creates the screen. The screen calls the closure; the coordinator decides what happens next.

```swift
// ViewController — no coordinator import, no coordinator type
final class SomeViewController: UIViewController {
    var onContinue: (() -> Void)? // injected by coordinator
    var onCancel: (() -> Void)?
}

// Coordinator wires it up privately
private func showSomeScreen() {
    let vc = SomeViewController()
    vc.onContinue = { [weak self] in self?.showNextScreen() }
    vc.onCancel = { [weak self] in self?.subject.send(.didCancel) }
    navigationController.pushViewController(vc, animated: true)
}
```

This is consistent with how SwiftUI views already communicate — closures are the natural mechanism:

```swift
// SwiftUI view — no UIKit import, no coordinator reference
struct SomeView: View {
    let onContinue: () -> Void  // injected by coordinator
}

// Coordinator wraps and wires it
private func showSomeView() {
    let view = SomeView { [weak self] in self?.showNextScreen() }
    let host = UIHostingController(rootView: view)
    navigationController.pushViewController(host, animated: true)
}
```

UIKit ViewControllers and SwiftUI views use an **identical communication pattern** — output closures injected by the coordinator. The UIKit/SwiftUI distinction is a wrapping detail managed entirely by the coordinator.

### UIKit/SwiftUI bridge

The coordinator is the seam between UIKit and SwiftUI. It creates SwiftUI views, wraps them in `UIHostingController`, and passes typed closures in. The SwiftUI view never imports UIKit.

```
UINavigationController
    └── UIHostingController<SomeView>   ← coordinator creates this
            └── SomeView                ← no UIKit, receives closures only
```

For purely SwiftUI flows, `NavigationStack` with a typed `Destination` enum is preferred over `UINavigationController`. The coordinator initialises the `NavigationStack` and owns the `RouteNavigationViewModel`:

```swift
// For a fully SwiftUI sub-flow
final class SettingsCoordinator: Coordinator {
    func start() {
        let viewModel = RouteNavigationViewModel<SettingsRoute>()
        let view = SettingsRootView(viewModel: viewModel) { [weak self] in
            self?.subject.send(.didFinish)
        }
        let host = UIHostingController(rootView: view)
        navigationController.pushViewController(host, animated: true)
    }
}
```

### Replacing `RootCoordinator.shared`

`RootCoordinator` should be evolved into a proper `AppCoordinator` conforming to `Coordinator`. The `static let shared` singleton is replaced with an instance retained by `AppDelegate` or the scene entry point.

Callers currently using `RootCoordinator.shared` directly should receive the coordinator through the existing `Client.providers` DI infrastructure or through closure injection — whichever is appropriate for the call site.

```swift
// AppDelegate / SceneDelegate
let coordinator = AppCoordinator(window: window)
self.appCoordinator = coordinator
coordinator.start()
```

### Data flow between coordinators

Data collected in one flow is passed to the next via initialiser arguments on the receiving coordinator. No singleton, no `NotificationCenter`, no `Client.providers` accessor is used to carry navigation-level data between flows.

```swift
// Output carries data
enum LoginOutput {
    case didAuthenticate(user: UserAccount)
}

// Parent passes it forward via init
loginCoordinator.output
    .sink { [weak self] event in
        switch event {
        case .didAuthenticate(let user):
            self?.showMain(user: user)
        }
    }
    .store(in: &cancellables)
```

### Migration path

Adoption is incremental. No existing screen needs to change until it is wrapped in a coordinator.

**Phase 1 — Foundation**
- Define the `Coordinator` protocol.
- Evolve `RootCoordinator` into `AppCoordinator` conforming to the protocol; remove `static let shared`.
- Replace `PIAWelcomeViewControllerDelegate` login callbacks with a `LoginCoordinator` that fires an output event on authentication success.

**Phase 2 — High-value flows**
- Wrap the VPN permission grant flow in a `VPNPermissionCoordinator`.
- Wrap server selection in a `ServerSelectionCoordinator`.
- Replace `NotificationCenter`-driven navigation with coordinator output events where flows are involved.

**Phase 3 — Full adoption**
- One coordinator per feature flow.
- All new SwiftUI screens use closure outputs from day one.
- New UIKit screens (rare) follow the same closure pattern.

## Consequences

### Positive

- **Single owner per flow.** Each coordinator owns exactly one slice of the navigation stack. Navigation decisions have a clear home.
- **Screens are reusable and isolated.** A VC or SwiftUI view with only closure outputs can be presented from any coordinator without modification.
- **Replaces NotificationCenter for navigation.** Typed output events are compile-time safe and traceable; `NotificationCenter` navigation is not.
- **Removes the `RootCoordinator.shared` singleton.** Navigation becomes injectable and testable.
- **UIKit and SwiftUI use the same pattern.** The bridge is a wrapping detail, not an architectural seam.
- **Incremental adoption.** Each new coordinator is independently testable and does not require touching existing flows.
- **Compatible with SwiftUI-first direction.** Fully SwiftUI flows can use `NavigationStack` internally, owned by a coordinator — no architecture change needed as UIKit screens migrate.

### Neutral

- **Coordinators proliferate with flow count.** Each distinct flow gets a coordinator. Expected and manageable with the naming convention `<FlowName>Coordinator`.
- **Two navigation paradigms coexist during migration.** Coordinator-based and legacy (`NotificationCenter`, direct push/present) navigation coexist until Phase 2 is complete.
- **tvOS is unaffected for now.** This ADR applies to iOS. tvOS can adopt the same pattern independently.

### Negative

- **Subscription lifecycle requires discipline.** A Combine subscription not stored in `cancellables` is silently cancelled. `cancellables.removeAll()` must be called before replacing a child coordinator. Both are easy to miss in code review.
- **`weak` references require care.** All coordinator closures must capture `self` as `weak`. A strong capture creates a retain cycle. This must be enforced in code review.
- **`RootCoordinator.shared` callsites require updating.** Any code that currently accesses `RootCoordinator.shared` directly must be updated when the singleton is removed. This is a bounded, one-time migration cost.

## References

- `PIA VPN/Core/RootCoordinator.swift` — existing root coordinator; starting point for `AppCoordinator` evolution
- `PIA VPN/UI/` — existing ViewControllers; candidates for closure output adoption per flow
- [ADR 0003](0003-swiftui-feature-modules-as-swift-packages.md) — SwiftUI feature modules as Swift packages (complementary to coordinator-owned SwiftUI flows)
