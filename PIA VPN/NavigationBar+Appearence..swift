//
//  NavigationBar+Appearence..swift
//  PIA VPN
//
//  Created by Said Rehouni on 8/11/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    func setBackgroundAppearenceColor(_ color: UIColor?) {
        if #available(iOS 13.0, *), color != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            standardAppearance = appearance
            scrollEdgeAppearance = standardAppearance
        }
        else {
            barTintColor = color
        }
    }
    
    func setBackgroundAppearenceImage(_ image: UIImage?) {
        if #available(iOS 13.0, *), image != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = image
            standardAppearance = appearance
            scrollEdgeAppearance = standardAppearance
        }
        else {
            setBackgroundImage(image, for: UIBarMetrics.default)
        }
    }
}
