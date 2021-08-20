//
//  NavigationBar+Appearence.swift
//  NavigationBar+Appearence
//
//  Created by Miguel Berrocal on 20/8/21.
//

import UIKit

extension UINavigationBar {
    func setBackgroundAppearenceColor(_ color: UIColor?) {
        if #available(iOSApplicationExtension 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            standardAppearance = appearance;
            scrollEdgeAppearance = standardAppearance
        }
        barTintColor = color
    }
    
    func setBackgroundAppearenceImage(_ image: UIImage?) {
        setBackgroundImage(image, for: UIBarMetrics.default)
        if #available(iOSApplicationExtension 13.0, *), image != nil {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = image
            standardAppearance = appearance;
            scrollEdgeAppearance = standardAppearance
        }
    }
}
