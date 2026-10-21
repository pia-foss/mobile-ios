//
//  AlertBannerHub.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import Foundation

/// Holds the banner on screen. A new banner always replaces the current one.
@AlertBannerActor
final class AlertBannerHub {
    struct Presentation: Identifiable, Sendable {
        let id = UUID()
        let banner: AlertBanner
    }

    typealias Sleep = @Sendable (TimeInterval) async throws -> Void

    private(set) var current: Presentation? {
        didSet { onChange(current) }
    }

    private let sleep: Sleep
    private let onChange: @Sendable (Presentation?) -> Void
    private var dismissTask: Task<Void, Never>?

    nonisolated init(
        sleep: @escaping Sleep = { try await Task.sleep(nanoseconds: UInt64($0 * 1_000_000_000)) },
        onChange: @escaping @Sendable (Presentation?) -> Void = { _ in }
    ) {
        self.sleep = sleep
        self.onChange = onChange
    }

    func show(_ banner: AlertBanner) {
        dismissTask?.cancel()
        let presentation = Presentation(banner: banner)
        current = presentation

        guard case .seconds(let seconds) = banner.duration else { return }
        let sleep = sleep
        dismissTask = Task { [weak self] in
            do {
                try await sleep(seconds)
            } catch {
                return
            }
            self?.dismiss(presentationID: presentation.id)
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = nil
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

    func isDisplaying(bannerID: String) -> Bool {
        current?.banner.id == bannerID
    }
}
