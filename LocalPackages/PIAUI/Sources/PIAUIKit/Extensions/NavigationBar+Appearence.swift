//
//  NavigationBar+Appearence.swift
//  PIA VPN
//
//  Created by Said Rehouni on 8/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

public extension UINavigationBar {
    func setBackgroundAppearenceColor(_ color: UIColor?) {
        if color != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            standardAppearance = appearance
            scrollEdgeAppearance = standardAppearance
        } else {
            barTintColor = color
        }
        fillAreaAboveBar(with: color)
    }

    /// - Parameter colorAboveBar: The color at the top edge of `image`, used to fill any space left
    ///   above the bar. Pass `nil` when the image has no single top color.
    func setBackgroundAppearenceImage(_ image: UIImage?, colorAboveBar: UIColor? = nil) {
        if image != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = image
            standardAppearance = appearance
            scrollEdgeAppearance = standardAppearance
            fillAreaAboveBar(with: colorAboveBar)
        } else {
            setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }

    /// The background of an opaque bar extends up to the top edge only while the bar sits right
    /// below a horizontal status bar. Where the status bar is vertical, as on the iPhone Duo outer
    /// display, the bar keeps a margin above it that shows the navigation controller's view, so
    /// that view is painted to match.
    private func fillAreaAboveBar(with color: UIColor?) {
        superview?.backgroundColor = color
    }
}
