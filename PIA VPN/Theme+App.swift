//
//  Theme+VPN.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/7/17.
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
import PIALibrary
import SideMenu
import FXPageControl

extension Theme {
    
    // MARK: Customizations
    
    func applySideMenu() {

        let screenSize = UIScreen.main.bounds.size
        let minEdge = min(screenSize.width, screenSize.height)
        
        if SideMenuManager.default.leftMenuNavigationController == nil {
            SideMenuManager.default.leftMenuNavigationController = StoryboardScene.Main.sideMenuNavigationController.instantiate()
        }
        
        SideMenuManager.default.leftMenuNavigationController?.menuWidth = min(320.0, minEdge - 44.0)
        SideMenuManager.default.leftMenuNavigationController?.statusBarEndAlpha = 0
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle = .menuSlideIn
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle.presentingEndAlpha = 0.5
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle.backgroundColor = palette.appearance == .dark ?
            UIColor.black.withAlphaComponent(0.72) :
            UIColor.piaGrey1.withAlphaComponent(0.75)
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
        
    public func applyMenuBackground(_ view: UIView) {
        view.backgroundColor = palette.appearance == .dark ?
            UIColor.piaGrey6 : UIColor.piaWhite
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
    
    public func applyMenuVersionListStyle(_ label: UILabel) {
        label.style(style: palette.appearance == .dark ?
            TextStyle.textStyle11 : TextStyle.textStyle12)
    }

    public func applyClearTextfield(_ textfield: UITextField) {
        textfield.style(style: palette.appearance == .dark ?
            TextStyle.textStyle6 : TextStyle.textStyle7)
        textfield.backgroundColor = .clear
    }
    
    public func applyCountryNameStyleFor(_ label: UILabel) {
        label.style(style: Theme.current.palette.appearance == .dark ?
            TextStyle.textStyle16 : TextStyle.textStyle17)
    }
    
    public func applyFriendReferralsView(_ view: UIView,
                                         appearance: Appearance) {
        view.layer.cornerRadius = 2.3
        if palette.appearance == Appearance.light {
            view.layer.borderColor = UIColor.piaGreenDark20.cgColor
            view.backgroundColor = UIColor.piaGreenDark20
        } else {
            view.layer.borderColor = UIColor.piaGrey10.cgColor
            Theme.current.applySecondaryBackground(view)
        }
        view.layer.borderWidth = 1.0
    }
    
    public func applyFriendReferralsSubtitle(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle16)
        label.textAlignment = textAlignment
    }
    
    public func applyFriendReferralsTitle(_ label: UILabel) {
        label.style(style: TextStyle.textStyle11)
        label.font = Theme.current.typeface.mediumFont(size: 12)
    }
    
    public func applyFriendReferralsMessageLabel(_ label: UILabel) {
        label.style(style: TextStyle.textStyle6)
        label.font = Theme.current.typeface.mediumFont(size: 15)
    }

    public func applyInputOverlay(_ view: UIView) {
        view.layer.cornerRadius = 6.0
        view.backgroundColor = .black
    }
    
    public func applyFriendReferralsButton(_ button: PIAButton,
                                           appearance: Appearance) {
        button.resetButton()
        button.layer.cornerRadius = 1.7
        button.titleLabel?.font = Theme.current.typeface.mediumFont(size: 9)
        if palette.appearance == Appearance.light {
            button.setTitleColor(TextStyle.textStyle14.color,
                                 for: .normal)
            button.setBackgroundImage(UIImage.fromColor(UIColor.white), for: .normal)
        } else {
            button.setTitleColor(TextStyle.textStyle11.color,
                                 for: .normal)
            button.setBackgroundImage(UIImage.fromColor(UIColor.piaGrey10), for: .normal)

        }

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
        let attributes:[NSAttributedString.Key:Any] = [
            NSAttributedString.Key.foregroundColor : TextStyle.textStyle8.color!,
            NSAttributedString.Key.font : TextStyle.textStyle8.font!
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
    
    public func geoImageName() -> String {
        if palette.appearance == .dark {
            return "icon-geo-dark"
        } else {
            return "icon-geo"
        }
    }
    
    public func applyBadgeStyle(_ label: UILabel) {
        label.font = UIFont.mediumFontWith(size: 10)
        label.textColor = palette.principalBackground
        label.layer.cornerRadius = 3.0
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.piaGreen
    }
    
    public func noResultsImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Regions.noResultsDark.image :
            Asset.Piax.Regions.noResultsLight.image
    }
    
    public func mapImage() -> UIImage? {
        
        let image = UIImage(named: "Dark-Map")
        
        if palette.appearance == .light {
            return image?.image(alpha: 0.15)
        }
        
        return image
        
    }
    
    public func dragDropImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Global.dragDropIndicatorDark.image :
            Asset.Piax.Global.dragDropIndicatorLight.image
    }

    public func activeEyeImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Global.eyeActiveDark.image :
            Asset.Piax.Global.eyeActiveLight.image
    }

    public func inactiveEyeImage() -> UIImage {
        return palette.appearance == .dark ?
            Asset.Piax.Global.eyeInactiveDark.image :
            Asset.Piax.Global.eyeInactiveLight.image
    }

    public func applyLicenseMonospaceFontAndColor(_ textView: UITextView,
                                                  appearance: Appearance) {
        textView.font = typeface.monospaceFont(size: 14.0)
        textView.textColor = palette.appearance == .dark ?
            .white :
            palette.textColor(forRelevance: 2, appearance: appearance)
    }
    
    public func textWithColoredLink(withMessage message: String, link: String) -> NSAttributedString {
        let plain = message.replacingOccurrences(
            of: "$1",
            with: link
            ) as NSString
        
        let attributed = NSMutableAttributedString(string: plain as String)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.minimumLineHeight = 16
        let fullRange = NSMakeRange(0, plain.length)
        attributed.addAttribute(.font, value: TextStyle.textStyleSubscriptionInformation.font!, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: TextStyle.textStyle8.color!, range: fullRange)
        attributed.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        let range1 = plain.range(of: link)
        attributed.addAttribute(.foregroundColor, value: TextStyle.textStyle9.color!, range: range1)
        return attributed
    }

    public func smallTextWithColoredLink(withMessage message: String, link: String) -> NSAttributedString {
        let plain = message.replacingOccurrences(
            of: "$1",
            with: link
            ) as NSString
        
        let attributed = NSMutableAttributedString(string: plain as String)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        paragraph.minimumLineHeight = 16
        let fullRange = NSMakeRange(0, plain.length)
        attributed.addAttribute(.font, value: TextStyle.textStyle8.font!, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: TextStyle.textStyle8.color!, range: fullRange)
        attributed.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        let range1 = plain.range(of: link)
        attributed.addAttribute(.foregroundColor, value: TextStyle.textStyle9.color!, range: range1)
        return attributed
    }

}
