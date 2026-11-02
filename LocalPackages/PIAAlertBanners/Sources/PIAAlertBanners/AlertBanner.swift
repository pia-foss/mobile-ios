//
//  AlertBanner.swift
//  PIAAlertBanners
//
//  Created by Mario on 21/10/2026.
//

import UIKit

/// A message shown in a banner at the top of the screen, above any presented view controller.
public struct AlertBanner: Sendable {
    public enum Style: Sendable {
        case error
        case warning
        case success
    }

    public enum Duration: Sendable, Equatable {
        /// Dismissed automatically after the given number of seconds.
        case seconds(TimeInterval)
        /// Stays until dismissed by the user or by `AlertBanners.dismiss(id:)`.
        case indefinite

        public static let `default`: Duration = .seconds(2)
    }

    /// Identifies the banner for `AlertBanners.dismiss(id:)` and `AlertBanners.isDisplaying(id:)`.
    public let id: String
    public let message: String
    public let image: UIImage?
    public let style: Style
    public let duration: Duration
    public let accessibilityIdentifier: String?

    public init(
        id: String = UUID().uuidString,
        message: String,
        image: UIImage? = nil,
        style: Style,
        duration: Duration = .default,
        accessibilityIdentifier: String? = nil
    ) {
        self.id = id
        self.message = message
        self.image = image
        self.style = style
        self.duration = duration
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}
