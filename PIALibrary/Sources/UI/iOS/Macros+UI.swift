//
//  Macros+UI.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

extension Macros {

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
     Checks iPad device.

     - Returns: `true` if the device is an iPad
     */
    public static var isDevicePad: Bool {
        return (UI_USER_INTERFACE_IDIOM() == .pad)
    }
    
    /**
     Checks iPhone Plus device.

     - Returns: `true` if the device is an iPhone Plus
     */
    public static var isDevicePlus: Bool {
        let screen = UIScreen.main
        let maxEdge = max(screen.bounds.size.width, screen.bounds.size.height)
        return ((screen.scale >= 3.0) && (maxEdge < 812.0))
    }
    
    /**
     Checks big devices, typically an iPad or iPhone Plus.

     - Returns: `true` if the device is an iPad or an iPhone Plus
     */
    public static var isDeviceBig: Bool {
        return (isDevicePad || (UIScreen.main.scale >= 3.0))
    }

    /**
     Returns a localized full version string.

     - Parameter format: A localized format string with two `String` parameters:
         - The first one is replaced with the x.y.z version
         - The second one is replaced with the build number
     - Returns: A localized full version string built upon the input `format`
     */
    public static func localizedVersionFullString() -> String? {
        guard let info = Bundle.main.infoDictionary else {
            return nil
        }
        let versionNumber = info["CFBundleShortVersionString"] as! String
        let buildNumber = info[kCFBundleVersionKey as String] as! String
        return L10n.Ui.Global.Version.format(versionNumber, buildNumber)
    }

    /**
     Shortcut to create an `UIAlertController` with `.alert` preferred style.
     
     - Parameter request: The alert title
     - Parameter message: The alert message
     - Returns: An `UIAlertController` with `.alert` preferred style
     */
    public static func alert(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }

    /**
     Shortcut to create an `UIAlertController` with `.actionSheet` preferred style.
     
     - Parameter request: The sheet title
     - Parameter message: The sheet message
     - Returns: An `UIAlertController` with `.actionSheet` preferred style
     */
    public static func actionSheet(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    }
}

/// Convenience methods for `UIAlertController`.
public extension UIAlertController {

    /**
     Adds a default action to an `UIAlertController`.
     
     - Parameter title: The action title
     - Parameter handler: The action handler
     */
    public func addDefaultAction(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .default) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
    }

    /**
     Adds a cancel action to an `UIAlertController`.
     
     - Parameter title: The action title
     */
    public func addCancelAction(_ title: String) {
        let action = UIAlertAction(title: title, style: .cancel)
        addAction(action)
        if (actions.count == 1) {
            preferredAction = action
        }
    }

    /**
     Adds a destructive action to an `UIAlertController`.
     
     - Parameter title: The action title
     - Parameter handler: The action handler
     */
    public func addDestructiveAction(_ title: String, handler: @escaping () -> Void) {
        let action = UIAlertAction(title: title, style: .destructive) { (action) in
            handler()
        }
        addAction(action)
        preferredAction = action
    }
}

extension String {
    func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
