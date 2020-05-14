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

    private var successConnectionsUntilPrompt: Int
    private var successConnectionsUntilPromptAgain: Int
    private var timeIntervalUntilPromptAgain: Double
    private var errorInConnectionsUntilPrompt: Int

    init() {
        self.successConnectionsUntilPrompt = AppConfiguration.Rating.successConnectionsUntilPrompt
        self.successConnectionsUntilPromptAgain = AppConfiguration.Rating.successConnectionsUntilPromptAgain
        self.errorInConnectionsUntilPrompt = AppConfiguration.Rating.errorInConnectionsUntilPrompt
        self.timeIntervalUntilPromptAgain = AppConfiguration.Rating.timeIntervalUntilPromptAgain
    }
    
    func logSuccessConnection() {

        AppPreferences.shared.successConnections += 1
        if AppPreferences.shared.successConnections == self.successConnectionsUntilPrompt {
            log.debug("Show rating")
            reviewApp()
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
    
    func logError() {
        //TODO
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
    
    private func reviewApp() {
        
        guard let rootView = AppDelegate.delegate().topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController) else {
            return
        }
        
        let sheet = Macros.alert(
            L10n.Rating.Enjoy.question,
            L10n.Rating.Enjoy.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Global.no, handler: {
            // Ask for feedback
            let alert = self.feedback()
            rootView.present(alert, animated: true, completion: nil)
        })
        
        sheet.addActionWithTitle(L10n.Global.yes) {
            let alert = self.askForReview()
            rootView.present(alert, animated: true, completion: nil)
        }
        
        rootView.present(sheet, animated: true, completion: nil)

    }
    
    private func feedback() -> PopupDialog {
        
        let sheet = Macros.alert(
            L10n.Rating.Problems.question,
            L10n.Rating.Problems.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Global.no, handler: {
            log.debug("No feedback")
        })
        
        sheet.addActionWithTitle(L10n.Global.yes) {
            self.openFeedbackWebsite()
        }

        return sheet

    }
    
    private func askForReview() -> PopupDialog {
        
        let sheet = Macros.alert(
            L10n.Rating.Rate.question,
            L10n.Rating.Rate.subtitle
        )
        sheet.addCancelActionWithTitle(L10n.Global.no, handler: {
            log.debug("No review but maybe we can try in the future")
            AppPreferences.shared.canAskAgainForReview = true
            if AppPreferences.shared.lastRatingRejection == nil {
                AppPreferences.shared.lastRatingRejection = Date()
            }
        })
        
        sheet.addActionWithTitle(L10n.Global.yes) {
            self.openRatingViewInAppstore()
        }

        return sheet

    }

}
