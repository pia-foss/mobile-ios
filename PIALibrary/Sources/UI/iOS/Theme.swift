//
//  Theme.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

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

        /// The logo image.
        public var logo: UIImage?

        /// The brand background color.
        public var brandBackground: UIColor

        /// The light background color.
        public var lightBackground: UIColor
        
        /// The solid light background color.
        public var solidLightBackground: UIColor

//        public var primary: UIColor
        
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

        /// The overlay alpha value.
        public var overlayAlpha: CGFloat

        /// :nodoc:
        public init() {
            brandBackground = .green
            lightBackground = .lightGray
            solidLightBackground = .white
//            primary = .black
            emphasis = .green
            accent1 = .orange
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
            divider = .lightGray
            overlayAlpha = 0.3
        }
        
        /**
         Sets the color for light text. Variants will be cached for alpha-based relevance.

         - Precondition: `(alphas.count == 3)`.
         - Parameter color: The color.
         - Parameter alphas: An array of relevance alphas. Size must be 3.
         */
        public func setLightText(_ color: UIColor, alphas: [CGFloat] = [1.0, 1.0, 1.0]) {
            precondition(alphas.count == 3)
            
            lightText = color
            for i in lightTextArray.enumerated() {
                lightTextArray[i.offset] = color.withAlphaComponent(alphas[i.offset])
            }
        }

        /**
         Sets the color for dark text. Variants will be cached for alpha-based relevance.

         - Precondition: `(alphas.count == 3)`.
         - Parameter color: The color.
         - Parameter alphas: An array of relevance alphas. Size must be 3.
         */
        public func setDarkText(_ color: UIColor, alphas: [CGFloat] = [1.0, 1.0, 1.0]) {
            precondition(alphas.count == 3)

            darkText = color
            for i in darkTextArray.enumerated() {
                darkTextArray[i.offset] = color.withAlphaComponent(alphas[i.offset])
            }
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
    public func applyBrandBackground(_ view: UIView) {
        view.backgroundColor = palette.brandBackground
    }
    
    /// :nodoc:
    public func applyBrandTint(_ view: UIView) {
        view.tintColor = palette.brandBackground
    }
    
    /// :nodoc:
    public func applyLightBackground(_ view: UIView) {
        view.backgroundColor = palette.lightBackground
    }
    
    /// :nodoc:
    public func applyLightTint(_ view: UIView) {
        view.tintColor = palette.lightBackground
    }
    
    /// :nodoc:
    public func applySolidLightBackground(_ view: UIView) {
        view.backgroundColor = palette.solidLightBackground
    }
    
    /// :nodoc:
    public func applyWarningBackground(_ view: UIView) {
        view.backgroundColor = palette.accent1
    }
    
    /// :nodoc:
    public func applySelection(_ view: UIView) {
        view.backgroundColor = palette.emphasis.withAlphaComponent(0.1)
    }

    /// :nodoc:
    public func applySolidSelection(_ view: UIView) {
        view.backgroundColor = palette.emphasis
    }

    /// :nodoc:
    public func applyDivider(_ view: UIView) {
        view.backgroundColor = palette.divider
    }
    
    /// :nodoc:
    public func applyDividerToSeparator(_ tableView: UITableView) {
        tableView.separatorColor = palette.divider
    }
    
    /// :nodoc:
    public func applyOverlay(_ view: UIView) {
        view.backgroundColor = UIColor(white: 0.0, alpha: palette.overlayAlpha)
    }
    
    // MARK: Navigation bar

    /// :nodoc:
    public func applyBrandNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.tintColor = palette.textColor(forRelevance: 1, appearance: .light)
        navigationBar.barTintColor = palette.brandBackground
    }
    
    // MARK: Typography

    /// :nodoc:
    public func applyTitle(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 16.0)
        label.textColor = palette.textColor(forRelevance: 1, appearance: appearance)
    }
    
    /// :nodoc:
    public func applySubtitle(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 13.0)
        label.textColor = palette.textColor(forRelevance: 2, appearance: appearance)
    }

    /// :nodoc:
    public func applyBody2(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.mediumFont(size: 14.0)
        label.textColor = palette.textColor(forRelevance: 1, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyBody2Monospace(_ textView: UITextView, appearance: Appearance) {
        textView.font = typeface.monospaceFont(size: 14.0)
        textView.textColor = palette.textColor(forRelevance: 1, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyBody1(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 14.0)
        label.textColor = palette.textColor(forRelevance: 2, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyBody1Monospace(_ textView: UITextView, appearance: Appearance) {
        textView.font = typeface.monospaceFont(size: 14.0)
        textView.textColor = palette.textColor(forRelevance: 2, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyCaption(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 12.0)
        label.textColor = palette.textColor(forRelevance: 2, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyCaption(_ button: UIButton, appearance: Appearance) {
        button.titleLabel?.font = typeface.regularFont(size: 12.0)
        button.setTitleColor(palette.textColor(forRelevance: 2, appearance: appearance), for: .normal)
    }
    
    /// :nodoc:
    public func applySmallCaption(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 10.0)
        label.textColor = palette.textColor(forRelevance: 3, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyLabel(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 12.0)
        label.textColor = palette.textColor(forRelevance: 3, appearance: appearance)
    }
    
    /// :nodoc:
    public func applySmallInfo(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 13.0)
        label.textColor = palette.textColor(forRelevance: 3, appearance: appearance)
    }
    
    /// :nodoc:
    public func applyTag(_ label: UILabel, appearance: Appearance) {
        label.font = typeface.regularFont(size: 12.0)
        label.textColor = palette.textColor(forRelevance: 1, appearance: appearance)
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
    
    /// :nodoc:
    public func applyTextButton(_ button: UIButton) {
        button.titleLabel?.font = typeface.mediumFont(size: 14.0)
        button.tintColor = palette.emphasis
    }
    
    /// :nodoc:
    public func applyTextButton(_ label: UILabel) {
        label.font = typeface.mediumFont(size: 14.0)
        label.textColor = palette.emphasis
    }
    
    /// :nodoc:
    public func applyWarningText(_ label: UILabel) {
        label.font = typeface.mediumFont(size: 10.0)
        label.textColor = palette.accent1
    }
    
    /// :nodoc:
    public func applyWarningText(_ button: UIButton) {
        button.titleLabel?.font = typeface.mediumFont(size: 10.0)
        button.tintColor = palette.accent1
    }
    
    /// :nodoc:
    public func applyHighlightedText(_ label: UILabel) {
        label.font = typeface.regularFont(size: 13.0)
        label.textColor = palette.emphasis
    }
    
    /// :nodoc:
    public func applyInput(_ textField: UITextField) { // hint is placeholder
        textField.font = typeface.regularFont(size: 14.0)
        textField.textColor = palette.textColor(forRelevance: 1, appearance: .dark)

        if let borderedTextField = textField as? BorderedTextField {
            borderedTextField.borderColor = palette.divider
            borderedTextField.highlightedBorderColor = palette.emphasis
            borderedTextField.highlightsWhileEditing = true
        }
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
        label.textColor = palette.emphasis
    }

    /// :nodoc:
    public func applyTableSectionFooter(_ view: UIView) {
        guard let hfv = view as? UITableViewHeaderFooterView, let label = hfv.textLabel else {
            return
        }
        label.textColor = palette.textColor(forRelevance: 3, appearance: .dark)
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
        return .lightContent
    }

    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets {
        return .zero
    }
}
