//
//  RatingManager.swift
//  PIA VPN
//  
//  Created by Jose Antonio Blaya Garcia on 13/05/2020.
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
import PIALibrary
import PopupDialog
import SwiftyBeaver
import StoreKit

private let log = SwiftyBeaver.self

class RatingManager {
    
    static let shared = RatingManager()

    private var successDisconnectionsUntilPrompt: Int
    private var successConnectionsUntilPrompt: Int
    private var successConnectionsUntilPromptAgain: Int
    private var timeIntervalUntilPromptAgain: Double
    private var errorInConnectionsUntilPrompt: Int
    
    private var isRatingFlagAvailable: Bool {
        return Client.configuration.featureFlags.contains(Client.FeatureFlags.disableSystemRatingDialog)
    }
    
    private var targetDisconnectionsReachedForPrompt: Bool {
        guard AppPreferences.shared.successConnections < self.successConnectionsUntilPrompt else {
            return false // We do not check this because alert was already shown
        }
        return AppPreferences.shared.successDisconnections == self.successDisconnectionsUntilPrompt
    }
    
    private var targetConnectionsReachedForPrompt: Bool {
        return AppPreferences.shared.successConnections == self.successConnectionsUntilPrompt
    }
    
    init() {
        self.successDisconnectionsUntilPrompt = AppConfiguration.Rating.successDisconnectionsUntilPrompt
        self.successConnectionsUntilPrompt = AppConfiguration.Rating.successConnectionsUntilPrompt
        self.successConnectionsUntilPromptAgain = AppConfiguration.Rating.successConnectionsUntilPromptAgain
        self.errorInConnectionsUntilPrompt = AppConfiguration.Rating.errorInConnectionsUntilPrompt
        self.timeIntervalUntilPromptAgain = AppConfiguration.Rating.timeIntervalUntilPromptAgain
    }
    
    func handleConnectionStatusChanged() {
        // By default do not use custom alert
        // and comparison should be: when vpn is disconnected
        if Client.providers.vpnProvider.vpnStatus == (isRatingFlagAvailable ? .connected : .disconnected) {
            showAppReviewWith(customPopup: isRatingFlagAvailable)
        }
    }
    
    private func showAppReviewWith(customPopup useCustomDialog: Bool) {
        let shouldShowRatingAlert = useCustomDialog ? targetConnectionsReachedForPrompt : targetDisconnectionsReachedForPrompt
        if shouldShowRatingAlert {
            log.debug("Show rating")
            if useCustomDialog {
                showCustomAlertForReview()
            } else {
                showDefaultAlertForReview()
            }
        } else if AppPreferences.shared.canAskAgainForReview {
            let now = Date()

            if AppPreferences.shared.successConnections >= self.successConnectionsUntilPromptAgain,
                let lastTime = AppPreferences.shared.lastRatingRejection,
                lastTime.addingTimeInterval(self.timeIntervalUntilPromptAgain) < now {
                log.debug("Show rating")
                reviewAppWithoutPrompt()
            }
        }
    }
    
    func handleConnectionError() {
        if Client.daemons.isNetworkReachable {
            if AppPreferences.shared.failureConnections == self.errorInConnectionsUntilPrompt {
                askForConnectionIssuesFeedback()
                AppPreferences.shared.failureConnections = 0
            }
            AppPreferences.shared.failureConnections += 1
        }
    }
    
    private func handleRatingAlertCancel() {
        log.debug("No review but maybe we can try in the future")
        AppPreferences.shared.canAskAgainForReview = true
        if AppPreferences.shared.lastRatingRejection == nil {
            AppPreferences.shared.lastRatingRejection = Date()
        }
    }
    
    private func openRatingViewInAppstore() {
        
        let urlStr = AppConstants.Reviews.appReviewUrl
        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)

    }
    
    private func openFeedbackWebsite() {
        let urlStr = AppConstants.Reviews.feedbackUrl
        guard let url = URL(string: urlStr), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func reviewAppWithoutPrompt() {
        SKStoreReviewController.requestReview()
    }
    
    // MARK: Default Alerts
    
    private func showDefaultAlertForReview() {
        guard let rootView = AppDelegate.getRootViewController() else {
            return
        }
        
        let sheet = Macros.alertController(L10n.Localizable.Rating.Enjoy.question, nil)
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Rating.Alert.Button.notreally, style: .default, handler: { action in
            // Ask for feedback
            let alert = self.createDefaultFeedbackDialog()
            rootView.present(alert, animated: true, completion: nil)
        }))
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Global.yes, style: .default, handler: { action in
            let alert = self.createDefaultReviewAlert()
            rootView.present(alert, animated: true, completion: nil)
        }))
        rootView.present(sheet, animated: true, completion: nil)
    }
    
    private func createDefaultFeedbackDialog() -> UIAlertController {
        let sheet = Macros.alertController(L10n.Localizable.Rating.Problems.question, L10n.Localizable.Rating.Problems.subtitle)
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Global.no, style: .default, handler: { action in
            log.debug("No feedback")
        }))
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Global.yes, style: .default, handler: { action in
            self.openFeedbackWebsite()
        }))
        return sheet
    }
    
    private func createDefaultReviewAlert() -> UIAlertController {
        let sheet = Macros.alertController(L10n.Localizable.Rating.Rate.question, nil)
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Rating.Alert.Button.nothanks, style: .default, handler: { action in
            self.handleRatingAlertCancel()
        }))
        sheet.addAction(UIAlertAction(title: L10n.Localizable.Rating.Alert.Button.oksure, style: .default, handler: { action in
            self.openRatingViewInAppstore()
        }))
        return sheet
    }
    
    // MARK: Custom Alerts
    
    private func showCustomAlertForReview() {
        
        guard let rootView = AppDelegate.getRootViewController() else {
            return
        }
        
        let sheet = Macros.alert(
            L10n.Localizable.Rating.Enjoy.question,
            L10n.Localizable.Rating.Enjoy.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Localizable.Global.no, handler: {
            // Ask for feedback
            let alert = self.createCustomFeedbackDialog()
            rootView.present(alert, animated: true, completion: nil)
        })
        
        sheet.addActionWithTitle(L10n.Localizable.Global.yes) {
            let alert = self.createCustomReviewDialog()
            rootView.present(alert, animated: true, completion: nil)
        }
        
        rootView.present(sheet, animated: true, completion: nil)

    }
    
    private func createCustomFeedbackDialog() -> PopupDialog {
        
        let sheet = Macros.alert(
            L10n.Localizable.Rating.Problems.question,
            L10n.Localizable.Rating.Problems.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Localizable.Global.no, handler: {
            log.debug("No feedback")
        })
        
        sheet.addActionWithTitle(L10n.Localizable.Global.yes) {
            self.openFeedbackWebsite()
        }

        return sheet

    }
    
    private func createCustomReviewDialog() -> PopupDialog {
        
        let sheet = Macros.alert(
            L10n.Localizable.Rating.Review.question,
            L10n.Localizable.Rating.Rate.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Localizable.Global.no, handler: {
            self.handleRatingAlertCancel()
        })
        
        sheet.addActionWithTitle(L10n.Localizable.Global.yes) {
            self.openRatingViewInAppstore()
        }

        return sheet

    }

    private func askForConnectionIssuesFeedback() {
        
        guard let rootView = AppDelegate.getRootViewController() else {
            return
        }
        
        let sheet = Macros.alert(
            L10n.Localizable.Rating.Error.question,
            L10n.Localizable.Rating.Error.subtitle
        )
        sheet.addCancelAction(L10n.Localizable.Global.close)
        
        sheet.addActionWithTitle(L10n.Localizable.Rating.Error.Button.send) {
            self.openFeedbackWebsite()
        }
        
        rootView.present(sheet, animated: true, completion: nil)

    }

}
