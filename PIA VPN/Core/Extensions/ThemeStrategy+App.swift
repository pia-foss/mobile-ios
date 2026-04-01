//
//  ThemeStrategy+App.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/11/18.
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
import UIKit
import PIAUIKit

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
        theme.typeface = Theme.Fonts.typeface
        
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
        case is PIAWelcomeViewController,
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
            return UIEdgeInsets(top: 0, left: AppConfiguration.UI.iPadLandscapeMargin, bottom: 0, right: AppConfiguration.UI.iPadLandscapeMargin)
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
            return UIEdgeInsets(top: 0, left: AppConfiguration.UI.iPadLandscapeMargin, bottom: 0, right: AppConfiguration.UI.iPadLandscapeMargin)
        }
        return .zero
    }
}
