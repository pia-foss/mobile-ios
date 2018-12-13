//
//  ThemeStrategy+App.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/11/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import PIALibrary

extension ThemeCode {
    func apply(theme: Theme, reload: Bool) {
        switch self {
        case .light:
            theme.palette = .light
            theme.strategy = LightThemeStrategy()
            
        case .dark:
            theme.palette = .dark
            theme.strategy = DarkThemeStrategy()
        }
        
        // share font type across all themes
        theme.typeface = AppConstants.Fonts.typeface
        
        if reload {
            theme.reload()
        }
    }
}

private struct LightThemeStrategy: ThemeStrategy {
    func applyNavigationBarStyle(to viewController: AutolayoutViewController, theme: Theme) {
        guard let navigationBar = viewController.navigationController?.navigationBar else {
            return
        }
        if let _ = viewController as? DashboardViewController {
            theme.applyLightNavigationBar(navigationBar)
            return
        }
        
        if viewController is BrandableNavigationBar {
            theme.applyLightBrandLogoNavigationBar(navigationBar)
        } else {
            theme.applyBrandNavigationBar(navigationBar)
        }

    }
    
    func statusBarAppearance(for viewController: AutolayoutViewController) -> UIStatusBarStyle {
        switch viewController {
        case is WalkthroughViewController,
             is PIAWelcomeViewController,
             is GetStartedViewController,
             is SignupInProgressViewController,
             is SignupFailureViewController,
             is SignupSuccessViewController,
             is SignupUnreachableViewController,
             is RestoreSignupViewController,
             is VPNPermissionViewController,
             is ConfirmVPNPlanViewController:
            return .default
        default:
            if AppPreferences.shared.lastVPNConnectionStatus == VPNStatus.connected {
                return .lightContent
            }
            return Theme.current.palette.appearance == .dark ? .lightContent : .default
        }
    }
    
    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets {
        if ((mask == .landscape) && Macros.isDevicePad) {
            return UIEdgeInsetsMake(0, AppConfiguration.UI.iPadLandscapeMargin, 0, AppConfiguration.UI.iPadLandscapeMargin)
        }
        return .zero
    }
}

private struct DarkThemeStrategy: ThemeStrategy {
    func applyNavigationBarStyle(to viewController: AutolayoutViewController, theme: Theme) {
        guard let navigationBar = viewController.navigationController?.navigationBar else {
            return
        }
        
        if viewController is BrandableNavigationBar {
            theme.applyLightBrandLogoNavigationBar(navigationBar)
        } else {
            theme.applyBrandNavigationBar(navigationBar)
        }

    }
    
    func statusBarAppearance(for viewController: AutolayoutViewController) -> UIStatusBarStyle {
        return .lightContent
    }
    
    func autolayoutContainerMargins(for mask: UIInterfaceOrientationMask) -> UIEdgeInsets {
        if ((mask == .landscape) && Macros.isDevicePad) {
            return UIEdgeInsetsMake(0, AppConfiguration.UI.iPadLandscapeMargin, 0, AppConfiguration.UI.iPadLandscapeMargin)
        }
        return .zero
    }
}
