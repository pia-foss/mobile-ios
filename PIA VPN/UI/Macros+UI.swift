//
//  Macros+UI.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import PIAAlertBanners
import PIADesignSystem
import PIALibrary
import PIALocalizations
import UIKit

extension Macros {

    private static let stickyNoteName: String = "sticky_note"

    /**
     Creates an `UIColor` from its RGBA components.

     - Parameter r: The red component
     - Parameter g: The green component
     - Parameter b: The blue component
     - Parameter alpha: The alpha channel component
     - Returns: An `UIColor` with the provided parameters
     */
    public static func color(r: UInt8, g: UInt8, b: UInt8, alpha: UInt8) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }

    /**
     Creates an `UIColor` from its RGBA components expressed as a 24-bit hex plus an alpha channel.

     - Parameter hex: The red, green and blue components expressed as a 24-bit number
     - Parameter alpha: The alpha channel component
     - Returns: An `UIColor` with the provided parameters
     */
    public static func color(hex: UInt32, alpha: UInt8) -> UIColor {
        let r = UInt8((hex >> 16) & 0xff)
        let g = UInt8((hex >> 8) & 0xff)
        let b = UInt8(hex & 0xff)

        return color(r: r, g: g, b: b, alpha: alpha)
    }

    /**
     Creates an `UIColor` from its RGBA components expressed as a String hex plus an alpha channel.

     - Parameter hex: The red, green and blue components expressed as a String
     - Parameter alpha: The alpha channel component
     - Returns: An `UIColor` with the provided parameters
     */
    public static func color(hex: String, alpha: UInt8) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }

    /**
     Returns a localized full version string.

     - Returns: A localized full version string built upon the input `format`
     */
    public static func localizedVersionFullString() -> String? {
        guard let info = Bundle.main.infoDictionary else {
            return nil
        }
        let versionNumber = info["CFBundleShortVersionString"] as! String
        let buildNumber = info[kCFBundleVersionKey as String] as! String
        return L10n.Global.Version.format(versionNumber, buildNumber)
    }

    /**
     Returns a localized version number string. Example "3.9.0"
     */
    public static func localizedVersionNumber() -> String {
        guard let info = Bundle.main.infoDictionary else {
            return ""
        }
        let versionNumber = info["CFBundleShortVersionString"] as! String
        return versionNumber
    }

    /// Shortcut to create a `UIAlertController`.
    ///
    /// - Parameter title: The alert title
    /// - Parameter message: The alert message
    /// - Returns: A `UIAlertController` object
    public static func alert(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }

    /**
     Shortcut to display an error banner.

     - Parameter image: The note image
     - Parameter message: The note message
     - Parameter duration: Optional duration of the note
     */
    @MainActor
    public static func displayImageNote(
        withImage image: UIImage,
        message: String,
        andDuration duration: Double? = nil,
        accessbilityIdentifier: String = ""
    ) {
        RootCoordinator.shared.alertBanners?.show(
            AlertBanner(
                message: message,
                image: image,
                style: .error,
                duration: bannerDuration(duration),
                accessibilityIdentifier: accessbilityIdentifier))
    }

    /**
     Shortcut to display a success banner.

     - Parameter image: The note image
     - Parameter message: The note message
     - Parameter duration: Optional duration of the note
     */
    @MainActor
    public static func displaySuccessImageNote(
        withImage image: UIImage,
        message: String,
        andDuration duration: Double? = nil
    ) {
        RootCoordinator.shared.alertBanners?.show(
            AlertBanner(message: message, image: image, style: .success, duration: bannerDuration(duration)))
    }

    /**
     Shortcut to display a warning banner.

     - Parameter image: The note image
     - Parameter message: The note message
     - Parameter duration: Optional duration of the note
     */
    @MainActor
    public static func displayWarningImageNote(
        withImage image: UIImage,
        message: String,
        andDuration duration: Double? = nil
    ) {
        RootCoordinator.shared.alertBanners?.show(
            AlertBanner(message: message, image: image, style: .warning, duration: bannerDuration(duration)))
    }

    /**
     Shortcut to display an error banner that stays until `removeStickyNote()` is called.

     - Parameter message: The note message
     - Parameter image: The note image
     */
    @MainActor
    public static func displayStickyNote(
        withMessage message: String,
        andImage image: UIImage
    ) {
        RootCoordinator.shared.alertBanners?.show(
            AlertBanner(id: stickyNoteName, message: message, image: image, style: .error, duration: .indefinite))
    }

    /**
     Removes the sticky note, if it is the banner on screen.
    */
    @MainActor
    public static func removeStickyNote() {
        RootCoordinator.shared.alertBanners?.dismiss(id: stickyNoteName)
    }

    private static func bannerDuration(_ seconds: Double?) -> AlertBanner.Duration {
        seconds.map { .seconds($0) } ?? .default
    }

}

extension UIAlertController {
    /// Add a default button with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .default) { _ in
            handler()
        }
        addAction(action)
        preferredAction = action
    }

    /// Add a destructive button with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addDestructiveActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .destructive) { _ in
            handler()
        }
        action.accessibilityIdentifier = Accessibility.Id.Dialog.destructive
        addAction(action)
    }

    /// Add a cancel button with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addCancelActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .cancel) { _ in
            handler()
        }
        addAction(action)
    }

    /// Add a cancel button without handler and dismissing on tap
    /// - Parameter title: The button title
    func addCancelAction(_ title: String) {
        let action = UIAlertAction(title: title, style: .cancel)
        addAction(action)
    }

    /// Add a default button without handler and dismissing on tap
    /// - Parameter title: The button title
    func addDefaultAction(_ title: String) {
        let action = UIAlertAction(title: title, style: .default)
        addAction(action)
        preferredAction = action
    }
}

public extension String {
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
