//
//  MockWebServices.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
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

@available(tvOS 17.0, *)
class MockWebServices: WebServices {
    
    var messageType: InAppMessageType = .view
    
    var credentials: (() -> Credentials)?

    var accountInfo: (() -> AccountInfo)?
    
    var appstoreInformationEligible: (() -> AppStoreInformation)?

    var appstoreInformationNotEligible: (() -> AppStoreInformation)?

    var appstoreInformationEligibleButDisabledFromBackend: (() -> AppStoreInformation)?

    var serversBundle: (() -> ServersBundle)?

    var vpnToken: String?

    var apiToken: String?

    func migrateToken(token: String) async throws {}

    func token(credentials: Credentials) async throws {}

    func token(receipt: Data) async throws {}

    func info() async throws -> AccountInfo {
        let result = accountInfo?()
        let error: ClientError? = (result == nil) ? .unsupported : nil

        if let result {
            return result
        } else if let error {
            throw error
        } else {
            fatalError()
        }
    }
    
    func update(credentials: Credentials, resetPassword reset: Bool, email: String) async throws {}

    func loginLink(email: String) async throws {}

    func logout() async throws {}

    func deleteAccount() async throws {}

    func signup(with request: Signup) async throws -> Credentials {
        guard let result = credentials?() else {
            throw ClientError.unsupported
        }
        return result
    }
    
    func redeem(with request: Redeem, _ callback: ((Credentials?, Error?) -> Void)?) {
        let result = credentials?()
        let error: ClientError? = (result == nil) ? .unsupported : nil
        callback?(result, error)
    }
    
    func processPayment(credentials: Credentials, request: Payment) async throws {}
    
    func downloadServers(_ callback: ((ServersBundle?, Error?) -> Void)?) {
        let result = serversBundle?()
        let error: ClientError? = (result == nil) ? .unsupported : nil
        callback?(result, error)
    }
    
    func flagURL(for country: String) -> URL {
        return URL(fileURLWithPath: "")
    }
    
    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) {
        callback?(nil, nil)
    }
    
    func submitDebugReport(_ shouldSendPersistedData: Bool, _ protocolLogs: String, _ callback: LibraryCallback<String>?) {
        callback?(nil, nil)
    }

    func subscriptionInformation(with receipt: Data?) async throws -> AppStoreInformation? {
        let result = { () -> AppStoreInformation? in
            if let receipt = receipt {
                if receipt.count == 0 {
                    return self.appstoreInformationNotEligible?()
                } else {
                    return self.appstoreInformationEligibleButDisabledFromBackend?()
                }
            } else {
                return self.appstoreInformationEligible?()
            }
        }
        
        Client.configuration.eligibleForTrial = result()!.eligibleForTrial

        return result()
    }
    
    func featureFlags() async throws -> [String] {
        ["mock-test"]
    }
    
    func validateLoginQR(qrToken: String) async throws -> String {
        ""
    }
}
