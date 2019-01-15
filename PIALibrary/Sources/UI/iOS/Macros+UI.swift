//
//  Macros+UI.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit
import PopupDialog

extension Macros {

    private static let bannerHeight: CGFloat = 78.5
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
     Shortcut to create a `PopupDialog`.
     
     - Parameter title: The alert title
     - Parameter message: The alert message
     - Returns: A `PopupDialog` object
     */
    public static func alert(_ title: String?, _ message: String?) -> PopupDialog {
        Macros.styleAlertPopupDialog()
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal)
        return popup
    }
    
    /**
     Shortcut to create an `UIAlertController`.
     
     - Parameter title: The alert title
     - Parameter message: The alert message
     - Returns: An `UIAlertController` object
     */
    public static func alertController(_ title: String?, _ message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    /**
     Style a `PopupDialog` object.
     */
    public static func stylePopupDialog() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        dialogAppearance.messageFont = TextStyle.textStyle12.font!
        dialogAppearance.messageColor = Theme.current.palette.appearance == .dark ? .white : TextStyle.textStyle12.color
        
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius    = 0
        containerAppearance.shadowEnabled   = false
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color           = .black
        overlayAppearance.blurEnabled     = false
        overlayAppearance.liveBlurEnabled = false
        overlayAppearance.opacity         = 0.5
        
        let buttonAppearance = DefaultButton.appearance()
        buttonAppearance.titleFont      = TextStyle.textStyle21.font!
        buttonAppearance.titleColor     = TextStyle.textStyle21.color
        buttonAppearance.buttonColor    = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        buttonAppearance.separatorColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey10 : UIColor.piaGrey1
    }
    
    /**
    Style a PopupDialog alert view object.
     */
    public static func styleAlertPopupDialog() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        dialogAppearance.titleFont = TextStyle.textStyle7.font!
        dialogAppearance.titleColor = Theme.current.palette.appearance == .dark ? .white : TextStyle.textStyle7.color
        dialogAppearance.messageFont = TextStyle.textStyle12.font!
        dialogAppearance.messageColor = Theme.current.palette.appearance == .dark ? .white : TextStyle.textStyle12.color
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius    = 0
        containerAppearance.shadowEnabled   = false
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color           = .black
        overlayAppearance.blurEnabled     = false
        overlayAppearance.liveBlurEnabled = false
        overlayAppearance.opacity         = 0.5
        
        let buttonAppearance = DefaultButton.appearance()
        buttonAppearance.titleFont      = TextStyle.textStyle14.font!
        buttonAppearance.titleColor     = TextStyle.textStyle14.color
        buttonAppearance.buttonColor    = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        buttonAppearance.separatorColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey10 : UIColor.piaGrey1
        
        let cancelButtonAppearance = CancelButton.appearance()
        cancelButtonAppearance.titleFont      = TextStyle.textStyle21.font!
        cancelButtonAppearance.titleColor     = TextStyle.textStyle21.color
        cancelButtonAppearance.buttonColor    = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        cancelButtonAppearance.separatorColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey10 : UIColor.piaGrey1
        
        let destructiveButtonAppearance = DestructiveButton.appearance()
        destructiveButtonAppearance.titleFont      = TextStyle.textStyle15.font!
        destructiveButtonAppearance.titleColor     = TextStyle.textStyle15.color
        destructiveButtonAppearance.buttonColor    = Theme.current.palette.appearance == .dark ? UIColor.piaGrey6 : .white
        destructiveButtonAppearance.separatorColor = Theme.current.palette.appearance == .dark ? UIColor.piaGrey10 : UIColor.piaGrey1
        
    }


    /**
     Shortcut to display an `EKImageNoteMessageView`.
     
     - Parameter image: The note image
     - Parameter message: The note message
     - Parameter duration: Optional duration of the note
     */
    public static func displayImageNote(withImage image: UIImage,
                                        message: String,
                                        andDuration duration: Double? = nil) {
        
        
        var attributes = EKAttributes()
        attributes = .topToast
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: UIColor.piaRed)
        attributes.positionConstraints.size = .init(width: EKAttributes.PositionConstraints.Edge.fill,
                                                    height: EKAttributes.PositionConstraints.Edge.constant(value: bannerHeight))

        if let duration = duration {
            attributes.displayDuration = duration
        }
        
        let labelContent = EKProperty.LabelContent(text: message,
                                                   style: .init(font: TextStyle.textStyle7.font!,
                                                                color: .white))
        let imageContent = EKProperty.ImageContent(image: image)
        let contentView = EKImageNoteMessageView(with: labelContent,
                                      imageContent: imageContent)
        
        SwiftEntryKit.display(entry: contentView,
                              using: attributes)

    }
    
    /**
     Shortcut to display an infinite `EKImageNoteMessageView`.
     
     - Parameter message: The note message
     - Parameter image: The note image
     */
    public static func displayStickyNote(withMessage message: String,
                                         andImage image: UIImage) {
        
        var attributes = EKAttributes()
        attributes = .topToast
        attributes.name = stickyNoteName
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: UIColor.piaRed)
        attributes.positionConstraints.size = .init(width: EKAttributes.PositionConstraints.Edge.fill,
                                                    height: EKAttributes.PositionConstraints.Edge.constant(value: bannerHeight))
        attributes.displayDuration = .infinity

        let labelContent = EKProperty.LabelContent(text: message,
                                                   style: .init(font: TextStyle.textStyle7.font!,
                                                                color: .white))
        let imageContent = EKProperty.ImageContent(image: image)
        let contentView = EKImageNoteMessageView(with: labelContent,
                                                 imageContent: imageContent)
        SwiftEntryKit.display(entry: contentView,
                              using: attributes)
        
    }
    
    /**
     Removes the current presented sticky note `EKImageNoteMessageView`.
    */
    public static func removeStickyNote() {
        if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: stickyNoteName) {
            SwiftEntryKit.dismiss()
        }
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

/// Convenience methods for `PopupDialog`.
public extension PopupDialog {
    
    /// Add a PopupDialog DefaultButton with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let button = DefaultButton(title: title.uppercased(), dismissOnTap: true) {
            handler()
        }
        self.addButton(button)
    }

    /// Add a PopupDialog DestructiveButton with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addDestructiveActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let button = DestructiveButton(title: title.uppercased(), dismissOnTap: true) {
            handler()
        }
        self.addButton(button)
    }
    
    /// Add a PopupDialog CancelButton with the handler action
    /// - Parameter title: The button title
    /// - Parameter handler: The button action
    func addCancelActionWithTitle(_ title: String, handler: @escaping () -> Void) {
        let button = CancelButton(title: title.uppercased(), dismissOnTap: true) {
            handler()
        }
        self.addButton(button)
    }
    
    /// Add a PopupDialog Button with the handler action depending of the UIAlertAction given
    /// - Parameter action: The UIAlertAction to convert into PopupDialog button
    /// - Parameter handler: The button action
    func addAction(_ action: UIAlertAction, handler: @escaping () -> Void) {
        if let title = action.title {
            switch action.style {
            case .cancel:
                let button = CancelButton(title: title.uppercased(), dismissOnTap: true) {
                    handler()
                }
                self.addButton(button)
            default:
                let button = DefaultButton(title: title.uppercased(), dismissOnTap: true) {
                    handler()
                }
                self.addButton(button)
            }
        }
    }
    
    /// Add a PopupDialog simple CancelButton without handler and dismissing on tap
    /// - Parameter title: The button title
    func addCancelAction(_ title: String) {
        let button = CancelButton(title: title.uppercased(), dismissOnTap: true, action: nil)
        self.addButton(button)
    }
    
    /// Add a PopupDialog simple DefaultButton without handler and dismissing on tap
    /// - Parameter title: The button title
    func addDefaultAction(_ title: String) {
        let button = DefaultButton(title: title.uppercased(), dismissOnTap: true, action: nil)
        self.addButton(button)
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
