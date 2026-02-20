import Combine
import SwiftUI
import PIADebugMenu

extension AppDelegate {
    func setupDebugMenuObserver() {
        #if DEVELOPMENT || STAGING
        addDebugMenuObserver()
        #else
        if TestFlightDetector.shared.isTestFlight {
            addDebugMenuObserver()
        }
        #endif
    }

    private func addDebugMenuObserver() {
        NotificationCenter.default
            .publisher(for: .debugShakeDetected)
            .receive(on: RunLoop.main)
            .sink(receiveValue: presentDebugMenu)
            .store(in: &cancellables)
    }

    private func presentDebugMenu(_ notification: Notification) {
        guard
            #available(iOS 16, *),
            let rootVC = window?.rootViewController
        else {
            return
        }

        var top = rootVC
        while let presented = top.presentedViewController {
            top = presented
        }

        let navVC = UINavigationController()
        let hostingVC = UIHostingController(rootView: DebugMenuView(onDismiss: { [weak navVC] in
            navVC?.dismiss(animated: true)
        }))

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        navVC.setViewControllers([hostingVC], animated: false)
        navVC.navigationBar.standardAppearance = appearance
        navVC.navigationBar.scrollEdgeAppearance = appearance
        navVC.navigationBar.compactAppearance = appearance
        navVC.modalPresentationStyle = .overCurrentContext
        top.present(navVC, animated: true)
    }
}
