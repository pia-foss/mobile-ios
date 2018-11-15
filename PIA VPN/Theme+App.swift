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
    }
    
    func applyPageControl(_ pageControl: FXPageControl) {
        pageControl.dotSpacing = 6.0
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
}
