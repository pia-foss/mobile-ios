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
    func shouldShowFeedbackTile() -> Bool
    func handleFeedbackDismiss()
    func handlePositiveRating()
    func handleNegativeRating()
    func handleConnectionStatusChanged()
}

final class RatingManager: RatingManagerProtocol {

    private enum Constants {
      static let baseURL = "xv-client-json-configuration.s3.us-east-1.amazonaws.com"
      static let stagingEnvironment = "staging"
      static let productionEnvironment = "production"
      static let version = "1.0.0"
      static let globalRegion = "global"
    }
    
    static let shared = RatingManager()

    private var inAppRatingConfig: InAppRatingConfig?
    private var successfulActivityAccomplished: Bool = false
    private var errorInConnectionsUntilPrompt: Int
    
    private var targetConnectionsReachedForPrompt: Bool {
        guard let inAppRatingConfig else {
            return false
        }

        return AppPreferences.shared.successConnections >= inAppRatingConfig.showAfterSuccessfulConnections
    }
    
    init() {
        self.errorInConnectionsUntilPrompt = AppConfiguration.Rating.errorInConnectionsUntilPrompt
    }

    func shouldShowFeedbackTile() -> Bool {
        guard let inAppRatingConfig else {
            log.debug("inAppRatingConfig is not loaded yet")
            return false
        }

        guard
            targetConnectionsReachedForPrompt,
            successfulActivityAccomplished
        else {
            return false
        }

        let lastPositive = AppPreferences.shared.lastPositiveRatingSubmitted
        let lastNegative = AppPreferences.shared.lastNegativeRatingSubmitted
        let lastDismiss = AppPreferences.shared.lastRatingRejection

        let allDates = [lastPositive, lastNegative, lastDismiss].compactMap { $0 }

        guard let mostRecentDate = allDates.max() else {
            // User has never interacted with feedback tile
            return true
        }

        if mostRecentDate == lastPositive {
            return mostRecentDate.daysUntilNow() >= inAppRatingConfig.cooldownDaysThumbsUp
        }

        if mostRecentDate == lastNegative {
            return mostRecentDate.daysUntilNow() >= inAppRatingConfig.cooldownDaysThumbsDown
        }

        if mostRecentDate == lastDismiss {
            return mostRecentDate.daysUntilNow() >= inAppRatingConfig.cooldownDaysDismiss
        }

        return false
    }

    func handleFeedbackDismiss() {
        AppPreferences.shared.lastRatingRejection = Date()
        AppPreferences.shared.resetSuccessConnections()

        Macros.postNotification(.PIAUpdateFixedTiles)
    }

    func handlePositiveRating() {
        AppPreferences.shared.lastPositiveRatingSubmitted = Date()
        AppPreferences.shared.resetSuccessConnections()

        openRatingViewInAppstore()

        Macros.postNotification(.PIAUpdateFixedTiles)
    }

    func handleNegativeRating() {
        AppPreferences.shared.lastNegativeRatingSubmitted = Date()
        AppPreferences.shared.resetSuccessConnections()

        openFeedbackWebsite()

        Macros.postNotification(.PIAUpdateFixedTiles)
    }

    func handleConnectionStatusChanged() {
        guard Client.providers.vpnProvider.vpnStatus == .connected else {
            return
        }

        // This enables the feedback tile to show up only after a successful activity
        // In this case it is a connection triggered by the user that succeeds
        successfulActivityAccomplished = true

        if shouldShowFeedbackTile() {
            Macros.postNotification(.PIAUpdateFixedTiles)
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

    // MARK: Configuration fetching

    func loadInAppRatingConfig() {
        let testFlightDetector = TestFlightDetector.shared
        let isStaging = testFlightDetector.isTestFlight

        Task {
            let inAppRatingConfig: InAppRatingConfig? = await loadConfig(
                file: "rating",
                url: generateURL(file: "rating", isStaging: isStaging, localized: Constants.globalRegion),
                fallbackUrl: generateURL(file: "rating", isStaging: isStaging, localized: Constants.globalRegion),
                urlSession: URLSession.shared
            )

            self.inAppRatingConfig = inAppRatingConfig ?? .default
            await MainActor.run {
                Macros.postNotification(.PIAUpdateFixedTiles)
            }
        }
        
    }

    private func generateURL(file: String, isStaging: Bool, localized: String) -> URL {
        let environment = isStaging ? Constants.stagingEnvironment : Constants.productionEnvironment
        let url = URL(string: "https://\(Constants.baseURL)/environment/\(environment)/platform/ios/version/\(Constants.version)/\(file)/\(file)_\(localized).json")!
        return url
    }

    private func loadConfig<T: Codable>(file: String, url: URL, fallbackUrl: URL, urlSession: URLSessionType) async -> T? {
        do {
            let request = URLRequest(url: url)
            let (data, _) = try await urlSession.data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            do {
                let request = URLRequest(url: fallbackUrl)
                let (data, _) = try await urlSession.data(for: request)
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return nil
            }
        }
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

// MARK: - InAppRatingConfig

extension RatingManager {
    struct InAppRatingConfig: Codable {
        static let `default` = InAppRatingConfig(
            showAfterSuccessfulConnections: 3,
            successfulConnectionSeconds: 10,
            cooldownDaysThumbsDown: 14,
            cooldownDaysThumbsUp: 14,
            cooldownDaysDismiss: 14
        )

        let showAfterSuccessfulConnections: Int
        let successfulConnectionSeconds: Int
        let cooldownDaysThumbsDown: Int
        let cooldownDaysThumbsUp: Int
        let cooldownDaysDismiss: Int

        enum CodingKeys: String, CodingKey {
            case showAfterSuccessfulConnections = "show_after_successful_connections"
            case successfulConnectionSeconds = "successful_connection_seconds"
            case cooldownDaysThumbsDown = "cooldown_days_thumbs_down"
            case cooldownDaysThumbsUp = "cooldown_days_thumbs_up"
            case cooldownDaysDismiss = "cooldown_days_dismiss"
        }
    }
}
