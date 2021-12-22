//
//  Theme.swift
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
import UIKit
import FXPageControl

/// Defines the look and feel of the client UI.
public class Theme {

    /// Semantic appearance of an accent.
    public enum Appearance {

        /// Dark accent.
        case dark
        
        /// Light accent.
        case light
        
        /// Emphasis accent.
        case emphasis
    }
    
    /// Defines theme values related to colors.
    public final class Palette {

        /// The appearance type theme
        public var appearance: Appearance?
        
        /// The logo image.
        public var logo: UIImage?

        /// The navigation bar back image.
        public var navigationBarBackIcon: UIImage?

        /// The light background color.
        public var secondaryColor: UIColor

        /// The background color of the buttons inside textfields.
        public var textfieldButtonBackgroundColor: UIColor

        /// The brand background color.
        public var brandBackground: UIColor

        /// The secondary background color.
        public var secondaryBackground: UIColor

        /// The solid light background color.
        public var principalBackground: UIColor
        
        /// The emphasis accent color.
        public var emphasis: UIColor
        
        /// The primary accent color.
        public var accent1: UIColor
        
        /// The secondary accent color.
        public var accent2: UIColor

        private var darkText: UIColor

        private var darkTextArray: [UIColor]

        private var lightText: UIColor

        private var lightTextArray: [UIColor]
        
        /// The solid text color for buttons.
        public var solidButtonText: UIColor
        
        /// The divider color.
        public var divider: UIColor
        
        /// The error color.
        public var errorColor: UIColor

        /// The overlay alpha value.
        public var overlayAlpha: CGFloat

        /// The line color.
        public var lineColor: UIColor

        /// :nodoc:
        public init() {
            appearance = .light
            brandBackground = .green
            secondaryColor = .piaGrey10
            secondaryBackground = .white
            principalBackground = .piaGrey1
            textfieldButtonBackgroundColor = .white
            lineColor = .piaGreenDark20
//            primary = .black
            emphasis = .green
            accent1 = .piaOrange
            accent2 = .red

            darkText = .black
            darkTextArray = [
                darkText,
                darkText,
                darkText
            ]
            lightText = .white
            lightTextArray = [
                lightText,
                lightText,
                lightText
            ]
            solidButtonText = .white
            divider = .piaGrey1
            errorColor = .piaRed
            overlayAlpha = 0.3
        }
        
        /**
         Returns the color for the given relevance and appearance.

         - Precondition: `relevance` lies between 1 and 3 (included).
         - Parameter relevance: The color relevance between 1 and 3 (included).
         - Parameter appearance: An `Appearance` value.
         - Returns: The resulting text color.
         */
        public func textColor(forRelevance relevance: Int, appearance: Appearance) -> UIColor {
            precondition(relevance >= 1)
            precondition(relevance <= 3)
            
            switch appearance {
            case .dark:
                return darkTextArray[relevance - 1]
                
            case .light:
                return lightTextArray[relevance - 1]
                
            case .emphasis:
                return emphasis
            }
        }
    }
    
    /// Defines a theme font typeface.
    public final class Typeface {

        /// The font name for regular weight. Defaults to system font.
        public var regularName: String?
        
        /// The font name for medium weight. Defaults to system font.
        public var mediumName: String?
        
        /// The font name for monospace text.
        public var monospaceName: String
        
        /// :nodoc:
        public init() {
            monospaceName = "Courier New"
        }

        private func safeFont(name: String, size: CGFloat) -> UIFont {
            guard let font = UIFont(name: name, size: size) else {
                fatalError("Cannot load font '\(name)'")
            }
            return font
        }

        /**
         Returns a regular-weighted font.
    
         - Parameter size: The size of the font.
         - Returns: A regular-weighted font of the given size.
         */
        public func regularFont(size: CGFloat) -> UIFont {
            guard let name = regularName else {
                return UIFont.systemFont(ofSize: size, weight: .regular)
            }
            return safeFont(name: name, size: size)
        }
        
        /**
         Returns a medium-weighted font.
    
         - Parameter size: The size of the font.
         - Returns: A medium-weighted font of the given size.
         */
        public func mediumFont(size: CGFloat) -> UIFont {
            guard let name = mediumName else {
                return UIFont.systemFont(ofSize: size, weight: .medium)
            }
            return safeFont(name: name, size: size)
        }
        
        /**
         Returns a monospace font.
    
         - Parameter size: The size of the font.
         - Returns: A monospace font of the given size.
         */
        public func monospaceFont(size: CGFloat) -> UIFont {
            return safeFont(name: monospaceName, size: size)
        }
    }

    /// The current UI theme.
    public static let current = Theme()
    
    /// The `Palette` holding the theme colors.
    public var palette: Palette

    /// The `Typeface` holding the theme fonts.
    public var typeface: Typeface
    
    /// The `ThemeStrategy` for dynamic styling.
    public var strategy: ThemeStrategy

    private let cornerRadius: CGFloat
    
//    private let dotSpacing: CGFloat
    
    private init() {
        palette = .light
        typeface = Typeface()
        strategy = DefaultThemeStrategy()

        cornerRadius = 4.0
//        dotSpacing = 6.0
    }
    
    /**
     Reloads the theme, every observer of `Notification.Name.PIAThemeDidChange` is notified for refreshing.

     - Postcondition: Posts `Notification.Name.PIAThemeDidChange` notification.
     */
    public func reload() {
        Macros.postNotification(.PIAThemeDidChange)
    }
    
    // MARK: Backgrounds
    
    /// :nodoc:
    public func applySecondaryBackground(_ view: UIView) {
        view.backgroundColor = palette.appearance == .dark ?
            palette.secondaryBackground.withAlphaComponent(0.3) :
            palette.secondaryBackground
    }
    
    /// :nodoc:
    public func applyPrincipalBackground(_ view: UIView) {
        view.backgroundColor = palette.principalBackground
    }

    /// :nodoc:
    public func applyRegionSolidLightBackground(_ view: UIView) {
        view.backgroundColor = palette.appearance == .dark ? UIColor.piaGrey6 : palette.principalBackground
    }
    
    /// :nodoc:
    public func applyWarningBackground(_ view: UIView) {
        view.backgroundColor = palette.accent1
    }
    
    /// :nodoc:
    public func applyMessagesBackground(_ view: UIView) {
        view.backgroundColor = palette.appearance == .dark ? UIColor.piaGrey8 : UIColor.piaGrey2
    }
    
    // MARK: Table View Utils
    
    /// :nodoc:
    public func applyDivider(_ view: UIView) {
        view.backgroundColor = palette.divider
    }
    
    /// :nodoc:
    public func applyDividerToSeparator(_ tableView: UITableView) {
        tableView.separatorColor = palette.divider
    }
    
    // MARK: Images

    /// :nodoc:
    public func applyCenteredMap(_ imageView: UIImageView) {
        imageView.image = palette.appearance == .dark ?
            Asset.centeredDarkMap.image : Asset.centeredLightMap.image
    }
    
    // MARK: Navigation bar

    /// :nodoc:
    public func applyBrandNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.tintColor = palette.textColor(forRelevance: 1, appearance: .light)
        navigationBar.setBackgroundAppearenceColor(palette.brandBackground)
    }
    
    // MARK: Typography
    /// :nodoc:
    public func applyButtonLabelStyle(_ button: UIButton) {
        if palette.appearance == Appearance.light {
            button.style(style: TextStyle.textStyle9)
        } else {
            button.style(style: TextStyle.textStyle6)
        }
    }
    
    public func applyButtonLabelMediumStyle(_ button: UIButton) {
        if palette.appearance == Appearance.light {
            button.style(style: TextStyle.textStyle9Medium)
        } else {
            button.style(style: TextStyle.textStyle6Medium)
        }
    }
    
    public func applyVersionNumberStyle(_ label: UILabel) {
        label.style(style: TextStyle.versionNumberStyle)
    }

    /// :nodoc:
    public func applyTitle(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.light {
            label.style(style: TextStyle.textStyle2)
        } else {
            label.style(style: TextStyle.textStyle1)
        }
    }
    
    /// :nodoc:
    public func applyBigTitle(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.light {
            label.style(style: TextStyle.textStyle23)
        } else {
            label.style(style: TextStyle.textStyle22)
        }
    }
    
    /// :nodoc:
    public func applySubtitle(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle8)
        label.textAlignment = textAlignment
    }
    
    public func applySmallSubtitle(_ label: UILabel) {
        let textAlignment = label.textAlignment
        label.style(style: TextStyle.textStyle21)
        label.textAlignment = textAlignment
    }
    
    /// :nodoc:
    public func applyBody1Monospace(_ textView: UITextView, appearance: Appearance) {
        textView.font = typeface.monospaceFont(size: 14.0)
        textView.textColor = palette.textColor(forRelevance: 2, appearance: appearance)
    }
    
    /// :nodoc:
    public func applySmallInfo(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.light {
            label.style(style: TextStyle.textStyle12)
        } else {
            label.style(style: TextStyle.textStyle11)
        }
    }
    
    /// Method to apply a second style for the same UILabel
    /// label.text should be previously set
    public func makeSmallLabelToStandOut(_ label: UILabel,
                                         withTextToStandOut textToStandOut: String,
                                         andAppearance appearance: Appearance = Appearance.dark) {

        if let text = label.text {
            let rangeSecondText = (text as NSString).range(of: textToStandOut)
            let attributedString = NSMutableAttributedString(string: text)
            
            var foregroundColor = TextStyle.textStyle1.color!
            if palette.appearance == Appearance.light {
                foregroundColor = TextStyle.textStyle2.color!
            }

            attributedString.addAttribute(.foregroundColor,
                                          value: foregroundColor,
                                          range: rangeSecondText)

            label.attributedText = attributedString
        }
        
    }
    
    /// :nodoc:
    public func applyTag(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 12.0)
        label.textColor = palette.textColor(forRelevance: 1, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyBlackLabelInBox(_ label: UILabel) {
        label.font = typeface.regularFont(size: 12.0)
        label.textColor = .black
    }
    
    /// :nodoc:
    public func applyList(_ label: UILabel, appearance: Appearance) {
        applyList(label, appearance: appearance, relevance: 2)
    }
    
    /// :nodoc:
    public func applyList(_ label: UILabel, appearance: Appearance, relevance: Int) {
        label.font = typeface.regularFont(size: 15.0)
        label.textColor = palette.textColor(forRelevance: relevance, appearance: appearance)
    }
    
    // MARK: Textfields
    
    /// :nodoc:
    public func applyInput(_ textField: UITextField) { // hint is placeholder
        
        textField.style(style: TextStyle.textStyle8)
        textField.backgroundColor = Theme.current.palette.secondaryColor

        if let borderedTextField = textField as? BorderedTextField {
            borderedTextField.borderColor = palette.divider
            borderedTextField.highlightedBorderColor = palette.emphasis
            borderedTextField.highlightsWhileEditing = true
        }
    }
    
    /// :nodoc:
    public func applyInputError(_ textField: UITextField) { // hint is placeholder
        
        textField.style(style: TextStyle.textStyle8)
        textField.backgroundColor = Theme.current.palette.secondaryColor
        
        if let borderedTextField = textField as? BorderedTextField {
            borderedTextField.borderColor = palette.errorColor
            borderedTextField.highlightedBorderColor = palette.errorColor
            borderedTextField.highlightsWhileEditing = true
        }
    }

    // MARK: Buttons

    /// :nodoc:
    public func applyTransparentButton(_ button: PIAButton,
                                       withSize size: CGFloat) {
        button.setBorder(withSize: size,
                         andColor: palette.lineColor)
        button.setTitleColor(palette.lineColor,
                             for: .normal)
    }
    
    /// :nodoc:
    public func applyActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        activityIndicator.color = palette.appearance == Appearance.light ? .piaGreen : .piaWhite
    }
    
    /// :nodoc:
    public func applyActionButton(_ button: ActivityButton) {
        button.font = typeface.mediumFont(size: 15.0)
        button.backgroundColor = palette.emphasis
        button.textColor = palette.solidButtonText
        button.cornerRadius = cornerRadius
    }
    
    /// :nodoc:
    public func applyCancelButton(_ button: UIButton, appearance: Appearance) {
        button.setTitle("×", for: .normal)
        button.titleLabel?.font = typeface.mediumFont(size: 36.0)
        button.setTitleColor(palette.textColor(forRelevance: 1, appearance: appearance), for: .normal)
    }
    
    public func applyUnderlinedSubtitleButton(_ button: UIButton) {
        button.style(style: TextStyle.textStyle8)
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let title = button.title(for: .normal) ?? ""
       
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
    }
    
    /// :nodoc:
    public func agreementText(withMessage message: String, tos: String, tosUrl: String, privacy: String, privacyUrl: String) -> NSAttributedString {
        let plain = message.replacingOccurrences(
            of: "$1",
            with: tos
            ).replacingOccurrences(
                of: "$2",
                with: privacy
            ) as NSString
        
        let attributed = NSMutableAttributedString(string: plain as String)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 16
        let fullRange = NSMakeRange(0, plain.length)
        attributed.addAttribute(.font, value: UIFont.regularFontWith(size: 12), range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.piaGrey4, range: fullRange)
        attributed.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        let range1 = plain.range(of: tos)
        let range2 = plain.range(of: privacy)
        attributed.addAttribute(.link, value: tosUrl, range: range1)
        attributed.addAttribute(.link, value: privacyUrl, range: range2)
        return attributed
    }
    
    public func messageWithLinkText(withMessage message: String, link: String) -> NSAttributedString {
        let plain = message.replacingOccurrences(
            of: "$1",
            with: link
            ) as NSString
        
        let attributed = NSMutableAttributedString(string: plain as String)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 16
        let fullRange = NSMakeRange(0, plain.length)
        attributed.addAttribute(.font, value: UIFont.mediumFontWith(size: 14), range: fullRange)
        if Theme.current.palette.appearance == .dark {
            attributed.addAttribute(.foregroundColor, value: UIColor.white, range: fullRange)
        } else {
            attributed.addAttribute(.foregroundColor, value: UIColor.piaGrey6, range: fullRange)
        }
        attributed.addAttribute(.paragraphStyle, value: paragraph, range: fullRange)
        let range1 = plain.range(of: link)
        attributed.addAttribute(.link, value: link, range: range1)
        return attributed
    }
    

    // MARK: Composite

    /// :nodoc:
    public func applyAppearance() {
        let navBarAppearance = UINavigationBar.appearance()
        let switchAppearance = UISwitch.appearance()
        let activityIndicatorAppearance = UIActivityIndicatorView.appearance()
        let pageControlAppearance = UIPageControl.appearance()
        
        switchAppearance.onTintColor = palette.emphasis
        activityIndicatorAppearance.color = palette.textColor(forRelevance: 2, appearance: .dark)
        pageControlAppearance.pageIndicatorTintColor = UIColor.groupTableViewBackground
        pageControlAppearance.currentPageIndicatorTintColor = palette.emphasis
        
        navBarAppearance.barStyle = .black
        navBarAppearance.isTranslucent = false
        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navBarAppearance.shadowImage = UIImage()
    }
    
    /// :nodoc:
    public func applyTableSectionHeader(_ view: UIView) {
        guard let hfv = view as? UITableViewHeaderFooterView, let label = hfv.textLabel else {
            return
        }
        label.style(style: TextStyle.textStyle14)
    }

    /// :nodoc:
    public func applyTableSectionFooter(_ view: UIView) {
        guard let hfv = view as? UITableViewHeaderFooterView, let label = hfv.textLabel else {
            return
        }
        label.style(style: TextStyle.textStyle21)
    }

    /// :nodoc:
    public func applyDetailTableCell(_ cell: UITableViewCell) {
        if let label = cell.textLabel {
            applyList(label, appearance: .dark, relevance: 2)
        }
        if let detail = cell.detailTextLabel {
            applyList(detail, appearance: .dark, relevance: 3)
        }
    }

    /// :nodoc:
    public func applyCorner(_ view: UIView) {
        applyCorner(view, factor: 1.0)
    }
    
    /// :nodoc:
    public func applyCorner(_ view: UIView, factor: CGFloat) {
        view.layer.cornerRadius = cornerRadius * factor
//        view.layer.masksToBounds = true
    }
    
    /// :nodoc:
    public func applyBorder(_ view: UIView, selected: Bool) {
        applyBorder(view, selected: selected, factor: 1.0)
    }
    
    /// :nodoc:
    public func applyBorder(_ view: UIView, selected: Bool, factor: CGFloat) {
        view.layer.cornerRadius = cornerRadius * factor
        view.layer.borderWidth = 1.0
        view.layer.borderColor = (selected ? palette.emphasis : palette.divider).cgColor
        view.clipsToBounds = true
    }
    
    /// :nodoc:
    public func applyCircleProgressView(_ circleProgressView: CircleProgressView) {
        circleProgressView.outerColor = palette.brandBackground
        circleProgressView.innerColor = palette.divider
        circleProgressView.fixedColor = palette.emphasis
    }
    
    /// :nodoc:
    public func applyLinkAttributes(_ textView: UITextView) {
        textView.tintColor = palette.lineColor
    }
    
    public func applyMessageLinkAttributes(_ textView: UITextView, withColor color: UIColor) {
        textView.tintColor = color
    }
    
    /// :nodoc:
    public func applyScrollableMap(_ imageView: UIImageView) {
        imageView.image = palette.appearance == .dark ?
            Asset.scrollableMapDark.image : Asset.scrollableMapLight.image
    }

    /// :nodoc:
    func applyPageControl(_ pageControl: FXPageControl) {
        pageControl.dotSpacing = 6.0
        pageControl.selectedDotImage = Asset.pagecontrolSelectedDot.image
        pageControl.dotImage = Asset.pagecontrolUnselectedDot.image
    }

    
    // MARK: Strategy

    /// :nodoc:
    func applyNavigationBarStyle(to viewController: AutolayoutViewController) {
        strategy.applyNavigationBarStyle(to: viewController, theme: self)
    }
    
    /// :nodoc:
    func statusBarAppearance(for viewController: AutolayoutViewController) -> UIStatusBarStyle {
        return strategy.statusBarAppearance(for: viewController)
    }

    /// :nodoc:
    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets {
        return strategy.autolayoutContainerMargins(for: mask)
    }
    
    // MARK: Navigation bar
    
    public func applyLightNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.setBackgroundAppearenceColor(palette.principalBackground)
        navigationBar.tintColor = UIColor.piaGrey4

    }
    
    // MARK: Refresh control
    public func applyRefreshControlStyle(_ refreshControl: UIRefreshControl) {
        if palette.appearance == Appearance.light {
            refreshControl.style(style: ViewStyle.refreshControlLight)
        } else {
            refreshControl.style(style: ViewStyle.refreshControlDark)
        }
    }
    
    /**
     Set color values for a custom navigation bar.
     
     - Parameter navigationBar: The navigationBar where the changes are going to be applied.
     - Parameter tintColor: The tintColor for the navigationBar. If nil: self.palette.textColor(forRelevance: 1, appearance: .dark)
     - Parameter barTintColors: Array of colors for the background of the navigationBar. If the array contains 2 colors, it will generate a gradient. If the array contains more than 2 colors or nil, it will set the default value: self.palette.secondaryBackground. If the array only contains 1 color, a solid background color will be set.
     */
    public func applyCustomNavigationBar(_ navigationBar: UINavigationBar,
                                         withTintColor tintColor: UIColor?,
                                         andBarTintColors barTintColors: [UIColor]?) {
        
        UIView.animate(withDuration: 0.3) {
            if let tintColor = tintColor {
                navigationBar.tintColor = tintColor
            } else {
                navigationBar.tintColor = UIColor.piaGrey4
            }
            
            if let barTintColors = barTintColors,
               barTintColors.count > 0,
               barTintColors.count <= 2 {
                if barTintColors.count == 1 {
                    navigationBar.setBackgroundAppearenceColor(barTintColors.first)
                    navigationBar.setBackgroundAppearenceImage(nil)
                } else {
                    var updatedFrame = navigationBar.bounds
                    updatedFrame.size.height += navigationBar.frame.origin.y
                    let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: barTintColors)
                    navigationBar.setBackgroundAppearenceImage(gradientLayer.createGradientImage())
                }
            } else {
                navigationBar.setBackgroundAppearenceColor(self.palette.principalBackground)
                navigationBar.setBackgroundAppearenceImage(nil)
            }
            navigationBar.setNeedsLayout()
        }
        
    }
    
    
    public func applyLightBrandLogoNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.tintColor = palette.textColor(forRelevance: 1, appearance: .dark)
        navigationBar.setBackgroundAppearenceColor(palette.principalBackground)
    }
    
    //MARK: Cell
    /// :nodoc:
    public func applySettingsCellTitle(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.light {
            label.style(style: TextStyle.textStyle7)
        } else {
            label.style(style: TextStyle.textStyle6)
        }
    }
    
    /// :nodoc:
    public func applyRegionIPCell(_ label: UILabel, appearance: Appearance) {
        label.style(style: TextStyle.ipTextStyle)
    }
    
    public func applyRegionIPTitleCell(_ label: UILabel, appearance: Appearance) {
        label.style(style: TextStyle.ipTitleTextStyle)
    }

    //MARK: Tile Usage
    /// :nodoc:
    public func applySubtitleTileUsage(_ label: UILabel, appearance: Appearance) {
        if palette.appearance == Appearance.dark {
            label.style(style: TextStyle.textStyle16)
        } else {
            label.style(style: TextStyle.textStyle17)
        }
    }

}

/// Defines a dynamic strategy for complex styles.
///
/// - Seealso: `Theme.strategy`
public protocol ThemeStrategy {

    /**
     Applies a style to a `UINavigation` based on an input `AutolayoutViewController`, in order to provide per-controller navigation bar styling.
     
     - Parameter viewController: The target `AutolayoutViewController` to apply the navigation bar style to.
     - Parameter theme: The `Theme` to apply.
     */
    func applyNavigationBarStyle(to viewController: AutolayoutViewController, theme: Theme)

    /**
     Returns a `UIStatusBarStyle` based on an input `AutolayoutViewController`, in order to provide per-controller styling.

     - Parameter viewController: The target `AutolayoutViewController` to apply the status bar style to.
     - Returns: The desired `UIStatusBarStyle` on the given view controller.
     */
    func statusBarAppearance(for viewController: AutolayoutViewController) -> UIStatusBarStyle

    /**
     Returns a set of margins to apply to `AutolayoutViewController.viewContainer` in a specific orientation mask.
     
     - Parameter mask: The current `UIInterfaceOrientationMask`.
     - Returns: The desired `UIEdgeInsets` margins to apply to `AutolayoutViewController.viewContainer`.
     */
    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets
}

private struct DefaultThemeStrategy: ThemeStrategy {
    func applyNavigationBarStyle(to viewController: AutolayoutViewController, theme: Theme) {
        guard let navigationBar = viewController.navigationController?.navigationBar else {
            return
        }
        theme.applyBrandNavigationBar(navigationBar)
    }
    
    func statusBarAppearance(for viewController: AutolayoutViewController) -> UIStatusBarStyle {
        if let _ = viewController as? PIAWelcomeViewController {
            return .default
        }
        if let _ = viewController as? GetStartedViewController {
            return .default
        }
        return .lightContent
    }

    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets {
        return .zero
    }
}
