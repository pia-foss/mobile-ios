//
//  SubscriptionManagementUtil.swift
//  PIA VPN
//
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

import UIKit
import StoreKit
import PIALibrary

private let log = PIALogger.logger(for: SubscriptionManagementUtil.self)

/// Utility for managing subscription-related functionality across UIKit and SwiftUI
enum SubscriptionManagementUtil {

    /// Opens the App Store subscription management sheet using StoreKit 2.
    /// This method presents the native iOS subscription management interface within the app.
    ///
    /// - Parameter windowScene: The window scene in which to present the subscription management sheet.
    ///                          For UIKit, get from `view.window?.windowScene`.
    ///                          For SwiftUI, use the `@Environment(\.windowScene)` property wrapper.
    @MainActor
    static func openManageSubscription(in windowScene: UIWindowScene) async {
        do {
            try await AppStore.showManageSubscriptions(in: windowScene)
        } catch {
            log.error("Failed to show manage subscriptions: \(error.localizedDescription)")
        }
    }
}
