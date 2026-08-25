import Combine
import PIADebugMenu
import PIALibrary
import SwiftUI

/// Whether this build may expose the debug menu. Lives in the app target because `DEVELOPMENT` and
/// `STAGING` are app-target compilation conditions that Xcode does not propagate to local packages.
private enum DebugMenuAvailability {
    static var isEnabled: Bool {
        #if DEVELOPMENT || STAGING
            return true
        #else
            return TestFlightDetector.shared.isTestFlight
        #endif
    }
}

extension AppDelegate {
    func setupDebugMenuObserver() {
        guard DebugMenuAvailability.isEnabled else { return }

        NotificationCenter.default
            .publisher(for: .debugMenuRequested)
            .receive(on: RunLoop.main)
            .sink(receiveValue: presentDebugMenu)
            .store(in: &cancellables)
    }

    private func presentDebugMenu(_ notification: Notification) {
        guard
            #available(iOS 16, *),
            let top = RootCoordinator.shared.topPresentedViewController()
        else {
            return
        }

        let navVC = UINavigationController()
        let hostingVC = UIHostingController(
            rootView: DebugMenuView(onDismiss: { [weak navVC] in
                navVC?.dismiss(animated: true)
            }))

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        navVC.setViewControllers([hostingVC], animated: false)
        navVC.navigationBar.standardAppearance = appearance
        navVC.navigationBar.scrollEdgeAppearance = appearance
        navVC.navigationBar.compactAppearance = appearance
        navVC.navigationBar.setBackgroundImage(nil, for: .default)
        navVC.navigationBar.shadowImage = nil
        navVC.navigationBar.isTranslucent = false
        navVC.modalPresentationStyle = .overCurrentContext
        top.present(navVC, animated: true)
    }
}

// MARK: - Mac Catalyst trigger

#if targetEnvironment(macCatalyst)

    /// The debug menu is reached from the menu bar (⌘⇧D).
    extension AppDelegate {
        override func buildMenu(with builder: UIMenuBuilder) {
            super.buildMenu(with: builder)

            // `buildMenu(with:)` is also called for contextual menus.
            guard builder.system == .main, DebugMenuAvailability.isEnabled else { return }

            let openDebugMenu = UIKeyCommand(
                title: "Debug Menu",
                action: #selector(requestDebugMenu(_:)),
                input: "d",
                modifierFlags: [.command, .shift]
            )

            let debugMenu = UIMenu(
                title: "Debug",
                identifier: UIMenu.Identifier("com.privateinternetaccess.menu.debug"),
                children: [openDebugMenu]
            )

            builder.insertSibling(debugMenu, afterMenu: .view)
        }

        @objc private func requestDebugMenu(_ sender: Any?) {
            NotificationCenter.default.post(name: .debugMenuRequested, object: nil)
        }
    }

#endif
