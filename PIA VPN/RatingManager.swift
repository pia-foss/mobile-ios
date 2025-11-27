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

protocol RatingManagerProtocol {
    func shouldShowFeedbackCard() -> Bool
    func dismissFeedbackCard()
    func handlePositiveRating()
    func handleNegativeRating()
    func handleConnectionStatusChanged()
}

final class RatingManager: RatingManagerProtocol {
    
    static let shared = RatingManager()

    private var successDisconnectionsUntilPrompt: Int
    private var successConnectionsUntilPrompt: Int
    private var successConnectionsUntilPromptAgain: Int
    private var timeIntervalUntilPromptAgain: Double
    private var errorInConnectionsUntilPrompt: Int
    
    private var targetConnectionsReachedForPrompt: Bool {
        AppPreferences.shared.successConnections >= self.successConnectionsUntilPrompt
    }
    
    init() {
        self.successDisconnectionsUntilPrompt = AppConfiguration.Rating.successDisconnectionsUntilPrompt
        self.successConnectionsUntilPrompt = AppConfiguration.Rating.successConnectionsUntilPrompt
        self.successConnectionsUntilPromptAgain = AppConfiguration.Rating.successConnectionsUntilPromptAgain
        self.errorInConnectionsUntilPrompt = AppConfiguration.Rating.errorInConnectionsUntilPrompt
        self.timeIntervalUntilPromptAgain = AppConfiguration.Rating.timeIntervalUntilPromptAgain
    }

    func shouldShowFeedbackCard() -> Bool {
        guard
            #available(iOS 15.0, *),
            AppPreferences.shared.lastRatingSubmitted == nil,
            AppPreferences.shared.lastRatingRejection == nil,
            targetConnectionsReachedForPrompt
        else {
            return false
        }

        return true
    }

    func dismissFeedbackCard() {
        log.debug("Feedback card dismissed")

        AppPreferences.shared.canAskAgainForReview = true
        if AppPreferences.shared.lastRatingRejection == nil {
            AppPreferences.shared.lastRatingRejection = Date()
            Macros.postNotification(.PIAUpdateFixedTiles)
        }
    }

    func handlePositiveRating() {
        AppPreferences.shared.lastRatingSubmitted = Date()
        openRatingViewInAppstore()

        Macros.postNotification(.PIAUpdateFixedTiles)
    }

    func handleNegativeRating() {
        AppPreferences.shared.lastRatingSubmitted = Date()
        openFeedbackWebsite()

        Macros.postNotification(.PIAUpdateFixedTiles)
    }

    func handleConnectionStatusChanged() {
        guard
            Client.providers.vpnProvider.vpnStatus == .disconnected,
            shouldShowFeedbackCard()
        else {
            return
        }

        Macros.postNotification(.PIAUpdateFixedTiles)
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
    
    // MARK: Custom Alerts

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
