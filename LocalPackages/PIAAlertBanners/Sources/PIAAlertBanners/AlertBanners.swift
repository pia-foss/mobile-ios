//
//  AlertBanners.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Combine
import SwiftUI
import UIKit

/// Shows `AlertBanner`s in a pass-through window above every other window, so a banner stays on
/// top of any presented view controller.
@MainActor
public final class AlertBanners {
    let presenter = AlertBannerPresenter()

    #if DEBUG
        public init() {}
    #endif

    /// Sets the scene banners appear in. Without it, the first foreground scene is used.
    public init(windowScene: UIWindowScene) {
        presenter.install(in: windowScene)
    }

    /// Shows `banner`, replacing the one on screen.
    public func show(_ banner: AlertBanner) {
        presenter.show(banner)
    }

    /// Dismisses the banner on screen if its id is `id`.
    public func dismiss(id: String) {
        presenter.dismiss(bannerID: id)
    }

    /// Dismisses the banner on screen, whatever it is.
    public func dismiss() {
        presenter.dismiss()
    }
}

/// Holds the banner on screen and owns the overlay window. A new banner always replaces the
/// current one. On Mac Catalyst a sheet lives in a scene of its own, so the window follows the
/// scene of the topmost presented view controller.
@MainActor
final class AlertBannerPresenter: ObservableObject {
    struct Presentation: Identifiable {
        let id = UUID()
        let banner: AlertBanner
    }

    @Published private(set) var current: Presentation? {
        didSet { currentDidChange(from: oldValue) }
    }

    private weak var windowScene: UIWindowScene?
    private var window: AlertBannerWindow?
    private var hideTask: Task<Void, Never>?
    private var windowObservation: AnyCancellable?

    func install(in windowScene: UIWindowScene) {
        guard windowScene !== self.windowScene else { return }
        self.windowScene = windowScene
        window?.isHidden = true
        window = nil
        if current != nil {
            showWindow()
        }
    }

    func show(_ banner: AlertBanner) {
        current = Presentation(banner: banner)
    }

    func dismiss() {
        guard current != nil else { return }
        current = nil
    }

    func dismiss(bannerID: String) {
        guard current?.banner.id == bannerID else { return }
        dismiss()
    }

    func dismiss(presentationID: UUID) {
        guard current?.id == presentationID else { return }
        dismiss()
    }

    private func currentDidChange(from previous: Presentation?) {
        hideTask?.cancel()
        hideTask = nil

        guard let current else {
            window?.bannerFrame = .zero
            // Keeps the window up until the exit transition has finished.
            hideTask = Task { [weak self] in
                try? await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled, let self, self.current == nil else { return }
                self.window?.isHidden = true
            }
            return
        }

        showWindow()
        if current.id != previous?.id {
            UINotificationFeedbackGenerator().notificationOccurred(current.banner.style.feedbackType)
            UIAccessibility.post(notification: .announcement, argument: current.banner.message)
        }
    }

    private func showWindow() {
        observeWindowsIfNeeded()
        makeWindowIfNeeded()?.isHidden = false
        followTopScene()
    }

    private func observeWindowsIfNeeded() {
        guard windowObservation == nil else { return }
        let notificationCenter = NotificationCenter.default
        windowObservation = Publishers.MergeMany(
            notificationCenter.publisher(for: UIWindow.didBecomeVisibleNotification),
            notificationCenter.publisher(for: UIWindow.didBecomeHiddenNotification),
            notificationCenter.publisher(for: UIScene.didDisconnectNotification)
        )
        .filter { !($0.object is AlertBannerWindow) }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            MainActor.assumeIsolated { self?.followTopScene() }
        }
    }

    private func followTopScene() {
        guard let window, !window.isHidden, let scene = topScene(), scene !== window.windowScene else { return }
        window.windowScene = scene
        window.frame = scene.coordinateSpace.bounds
    }

    /// The scene of the topmost presented view controller.
    private func topScene() -> UIWindowScene? {
        guard let baseScene = windowScene ?? Self.foregroundScene() else { return nil }
        let appWindows = baseScene.windows.filter { !($0 is AlertBannerWindow) && !$0.isHidden }
        guard var top = (appWindows.first { $0.isKeyWindow } ?? appWindows.first)?.rootViewController else {
            return baseScene
        }
        while let presented = top.presentedViewController, !presented.isBeingDismissed {
            top = presented
        }
        return top.viewIfLoaded?.window?.windowScene ?? baseScene
    }

    private func makeWindowIfNeeded() -> AlertBannerWindow? {
        if let window { return window }
        guard let scene = topScene() else { return nil }

        let window = AlertBannerWindow(windowScene: scene)
        let overlay = AlertBannerOverlay(presenter: self) { [weak window] frame in
            window?.bannerFrame = frame
        }
        let controller = AlertBannerHostingController(rootView: overlay)
        controller.statusBarAppearanceSource = { [weak window] in
            window?.windowScene?.windows.first { $0 !== window && $0.isKeyWindow }?.rootViewController
        }
        window.rootViewController = controller
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        self.window = window
        return window
    }

    private static func foregroundScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }
}

/// Lets every touch outside the banner through to the windows below.
final class AlertBannerWindow: UIWindow {
    var bannerFrame: CGRect = .zero

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard bannerFrame.contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }
}

final class AlertBannerHostingController: UIHostingController<AlertBannerOverlay> {
    var statusBarAppearanceSource: () -> UIViewController? = { nil }

    override init(rootView: AlertBannerOverlay) {
        super.init(rootView: rootView)
        view.backgroundColor = .clear
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var childForStatusBarStyle: UIViewController? { statusBarAppearanceSource() }
    override var childForStatusBarHidden: UIViewController? { statusBarAppearanceSource() }
}

extension AlertBanner.Style {
    fileprivate var feedbackType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .error: .error
        case .warning: .warning
        case .success: .success
        }
    }
}
