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
            label.textColor = UIColor.piaGreenDark20

        case .medium:
            label.textColor = UIColor.piaOrange
        
        case .high:
            label.textColor = UIColor.piaRed
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
    
    public func applyClearTextfield(_ textfield: UITextField) {
        textfield.style(style: palette.appearance == .dark ?
            TextStyle.textStyle6 : TextStyle.textStyle7)
        textfield.backgroundColor = .clear
    }

    //MARK: SearchBar
    
    public func applySearchBarStyle(_ searchBar: UISearchBar) {
        
        searchBar.backgroundColor = .clear

        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = .clear
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.backgroundColor = .clear
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.tintColor = UIColor.piaGrey4

        if palette.appearance == .dark {
            //text
            textFieldInsideSearchBar?.style(style: TextStyle.textStyle6)
            //placeholder
            textFieldInsideSearchBarLabel?.style(style: TextStyle.textStyle8)
            searchBar.barTintColor = UIColor.piaGrey10
        } else {
            //text
            textFieldInsideSearchBar?.style(style: TextStyle.textStyle7)
            //placeholder
            textFieldInsideSearchBarLabel?.style(style: TextStyle.textStyle8)
            searchBar.barTintColor = UIColor.white
        }
        
        //Cancel button
        let attributes:[NSAttributedStringKey:Any] = [
            NSAttributedStringKey.foregroundColor : TextStyle.textStyle8.color!,
            NSAttributedStringKey.font : TextStyle.textStyle8.font!
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)

    }

    public func applyFavoriteUnselectedImage(_ imageView: UIImageView) {
        if palette.appearance == .dark {
            imageView.image = Asset.Piax.Global.favoriteUnselectedDark.image
        } else {
            imageView.image = Asset.Piax.Global.favoriteUnselected.image
        }
    }
    
    public func noResultsImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Regions.noResultsDark.image :
            Asset.Piax.Regions.noResultsLight.image
    }
    
    public func mapImageByServerName(_ serverName: String) -> String {
        let prefix = palette.appearance == .dark ? "Dark-Map-" : "Light-Map-"
        return prefix + serverName
    }
    
    public func dragDropImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Global.dragDropIndicatorDark.image :
            Asset.Piax.Global.dragDropIndicatorLight.image
    }

}
