//
//  PIACSISubscriptionInformationProvider.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 20.02.26.
//  Copyright © 2026 Private Internet Access, Inc.
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
import csi

class PIACSISubscriptionInformationProvider: ICSIProvider {

    var filename: String? { return "subscription_information" }

    var isPersistedData: Bool { return false }

    var providerType: ProviderType { return ProviderType.applicationInformation }

    var reportType: ReportType { return ReportType.diagnostic }

    var value: String? { return getSubscriptionInformation() }

    private func getSubscriptionInformation() -> String {
        guard let info = Client.providers.accountProvider.currentUser?.info else {
            return "No account information available"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        var lines: [String] = []
        lines.append("username: \(info.username)")
        lines.append("plan: \(info.plan.rawValue)")
        lines.append("product_id: \(info.productId ?? "none")")
        lines.append("expiration_date: \(formatter.string(from: info.expirationDate))")
        lines.append("is_expired: \(info.isExpired)")
        lines.append("is_renewable: \(info.isRenewable)")
        lines.append("is_recurring: \(info.isRecurring)")
        lines.append("can_invite: \(info.canInvite)")
        lines.append("expire_alert: \(info.shouldPresentExpirationAlert)")
        lines.append("")
        lines.append("=== Payment Receipt ===")
        if let receipt = Client.store.paymentReceipt?.base64EncodedString() {
            lines.append(receipt)
        } else {
            lines.append("none")
        }
        return lines.joined(separator: "\n")
    }
}
