//
//  Theme+VPN.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary
import SideMenu
import FXPageControl

extension Theme {

    // MARK: Navigation bar
    
    public func applyLightNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.tintColor = palette.textColor(forRelevance: 1, appearance: .dark)
        navigationBar.barTintColor = palette.lightBackground
    }
    
    /**
     Set color values for a custom navigation bar.
     
     - Parameter navigationBar: The navigationBar where the changes are going to be applied.
     - Parameter tintColor: The tintColor for the navigationBar. If nil: self.palette.textColor(forRelevance: 1, appearance: .dark)
     - Parameter barTintColors: Array of colors for the background of the navigationBar. If the array contains 2 colors, it will generate a gradient. If the array contains more than 2 colors or nil, it will set the default value: self.palette.lightBackground. If the array only contains 1 color, a solid background color will be set.
     */
    public func applyCustomNavigationBar(_ navigationBar: UINavigationBar,
                                         withTintColor tintColor: UIColor?,
                                         andBarTintColors barTintColors: [UIColor]?) {
        
        UIView.animate(withDuration: 0.3) {
            if let tintColor = tintColor {
                navigationBar.tintColor = tintColor
            } else {
                navigationBar.tintColor = self.palette.textColor(forRelevance: 1, appearance: .dark)
            }
            
            if let barTintColors = barTintColors,
                barTintColors.count > 0,
                barTintColors.count <= 2 {
                if barTintColors.count == 1 {
                    navigationBar.barTintColor = barTintColors.first
                    navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
                } else {
                    var updatedFrame = navigationBar.bounds
                    updatedFrame.size.height += navigationBar.frame.origin.y
                    let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: barTintColors)
                    navigationBar.setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
                }
            } else {
                navigationBar.barTintColor = self.palette.lightBackground
                navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            }
            navigationBar.layoutIfNeeded()
        }
        
    }

    
    public func applyLightBrandLogoNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.tintColor = palette.textColor(forRelevance: 1, appearance: .dark)
        navigationBar.barTintColor = palette.lightBackground
    }

    // MARK: Typography

    func applyHighlightedText(_ button: UIButton) {
        guard let label = button.titleLabel else {
            return
        }
        applyHighlightedText(label)
        button.tintColor = label.textColor
    }
    
    // MARK: Customizations
    
    func applySideMenu() {
        let menuSettings = SideMenuManager.default
        let screenSize = UIScreen.main.bounds.size
        let minEdge = min(screenSize.width, screenSize.height)
        menuSettings.menuWidth = min(320.0, minEdge - 44.0)
        menuSettings.menuFadeStatusBar = false
        menuSettings.menuPresentMode = .menuSlideIn
        menuSettings.menuAnimationFadeStrength = 0.5
        menuSettings.menuAnimationBackgroundColor = palette.appearance == .dark ?
            UIColor.black.withAlphaComponent(0.72) :
            UIColor.piaGrey1.withAlphaComponent(0.75)
    }
    
    func applyPageControl(_ pageControl: FXPageControl) {
        pageControl.dotSpacing = 6.0
        pageControl.selectedDotImage = Asset.Piax.Global.pagecontrolSelectedDot.image
        pageControl.dotImage = Asset.Piax.Global.pagecontrolUnselectedDot.image
    }
    
    func applyPingTime(_ label: UILabel, time: Int) {
        switch AppConfiguration.ServerPing.from(value: time) {
        case .low:
            label.textColor = palette.emphasis

        case .medium:
            label.textColor = palette.accent1
        
        case .high:
            label.textColor = palette.accent2
        }
    }

    func applyVPNStatus(_ label: UILabel, forStatus status: VPNStatus) {
        label.font = typeface.mediumFont(size: 24.0)
        
        switch status {
        case .connected:
            label.textColor = palette.emphasis
        
        case .connecting, .disconnecting:
            label.textColor = palette.accent1
        
        case .disconnected:
            label.textColor = palette.accent2
        }
    }
    
    public func applyScrollableMap(_ imageView: UIImageView) {
        imageView.image = palette.appearance == .dark ?
            Asset.Piax.Global.scrollableMapDark.image : Asset.Piax.Global.scrollableMapLight.image
    }
    
    public func applyMenuBackground(_ view: UIView) {
        view.backgroundColor = palette.appearance == .dark ?
            UIColor.piaGrey10 : UIColor.piaWhite
    }

    public func applyMenuSubtitle(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle13)
        label.textAlignment = textAlignment
    }

    public func applyWarningMenuBackground(_ view: UIView) {
        view.backgroundColor = UIColor.piaRed
    }

    public func applyMenuCaption(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle17)
        label.textAlignment = textAlignment
    }
    
    public func applyMenuSmallCaption(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle11)
        label.text = label.text?.capitalized
        label.textAlignment = textAlignment
    }

    public func applyMenuListStyle(_ label: UILabel) {
        label.style(style: palette.appearance == .dark ?
            TextStyle.textStyle6 : TextStyle.textStyle7)
    }

    /// :nodoc:
    public func applySettingsCellTitle(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.light {
            label.style(style: TextStyle.textStyle7)
        } else {
            label.style(style: TextStyle.textStyle6)
        }
    }
}
