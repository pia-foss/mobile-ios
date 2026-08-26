//
//  PIAWebServices.swift
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
import PIAAccount
import PIABase
import PIACSI
import PIARegions

private let log = PIALogger.logger(for: PIAWebServices.self)

final class PIAWebServices: WebServices, ConfigurationAccess {

    private static let serversVersion = 1002
    private static let store = "apple_app_store"

    let regionsAPI: any RegionsAPI
    let csiClient = CSIClient(userAgent: PIAWebServices.userAgent)
    let nativeAccountAPI: PIAAccountAPI

    init() {
        let rsa4096Certificate = Client.configuration.rsa4096Certificate
        let endpointsProvider: any RegionEndpointProvider =
            Client.environment == .staging
            ? PIARegionStagingClientStateProvider()
            : PIARegionClientStateProvider()

        self.regionsAPI = try! RegionsBuilder()
            .setEndpointProvider(endpointsProvider)
            .setCertificate(rsa4096Certificate)
            .setUserAgent(PIAWebServices.userAgent)
            .setMetadataRequestPath("/vpninfo/regions/v2")
            .setVPNRegionsRequestPath("/vpninfo/servers/v6")
            .setShadowsocksRegionsRequestPath("/shadow_socks")
            .build()

        let nativeEndpointProvider: PIAAccountEndpointProvider =
            switch Client.environment {
            case .staging:
                PIANativeAccountStagingEndpointProvider()
            case .production:
                PIANativeAccountEndpointProvider()
            }

        var builder = PIAAccountBuilder()
        builder.setEndpointProvider(nativeEndpointProvider)
        builder.setCertificate(rsa4096Certificate)
        builder.setUserAgent(PIAWebServices.userAgent)
        self.nativeAccountAPI = try! builder.build()
    }

    public static let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable = Client.environment == .staging ? "PIA VPN" : "PIA VPN Staging"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"

            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

                let osName: String = {
                    #if os(iOS)
                        return "iOS"
                    #elseif os(watchOS)
                        return "watchOS"
                    #elseif os(tvOS)
                        return "tvOS"
                    #elseif os(macOS)
                        return "OS X"
                    #elseif os(Linux)
                        return "Linux"
                    #else
                        return "Unknown"
                    #endif
                }()
                return "\(osName) \(versionString)"
            }()
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
        }
        return "PIA"
    }()

    /***
     The token to use for protocol authentication.
     */
    var vpnToken: String? {
        return self.nativeAccountAPI.syncVpnToken
    }

    /***
     The token to use for api authentication.
     */
    var apiToken: String? {
        return self.nativeAccountAPI.syncApiToken
    }

    /// Generates a new auth expiring token based on a previous non-expiry one.
    func migrateToken(token: String) async throws(ClientError) {
        do {
            try await nativeAccountAPI.migrateApiToken(apiToken: token)
        } catch {
            throw mapNativeLoginError(error)
        }
    }

    /// Generates a new auth token for the specific user
    func token(credentials: Credentials) async throws(ClientError) {
        do {
            try await nativeAccountAPI.loginWithCredentials(
                username: credentials.username,
                password: credentials.password
            )
        } catch {
            throw mapNativeLoginError(error)
        }
    }

    /***
     Validates the QR Token and generates a new auth token for the specific user
     */
    func validateLoginQR(qrToken: String) async throws -> String {
        do {
            return try await nativeAccountAPI.validateLoginQR(qrToken: qrToken)
        } catch {
            throw ClientError.unauthorized
        }
    }

    /// Generates a new auth token for the specific user
    func token(receipt: JWS) async throws(ClientError) {
        do {
            try await nativeAccountAPI.loginWithReceipt(receipt: receipt)
        } catch {
            throw mapNativeLoginFromReceiptError(error)
        }
    }

    // MARK: - Error mapping

    private func mapNativeLoginError(_ error: Error) -> ClientError {
        guard let error = error as? PIAError else {
            return .unknown(code: 0, message: error.localizedDescription)
        }

        log.debug("\(#function) code: \(error.type) error: \(error)")

        switch error.type {
        case .http(400):
            return .invalidParameter
        case .http(401), .http(403):
            return .unauthorized
        case .http(402):
            return .expired
        case .http(429):
            let retryAfter = (error as? PIAAccountError)?.retryAfterSeconds ?? 0
            return .throttled(retryAfter: UInt(retryAfter))
        case .http(500..<600):
            return .backendUnavailable
        case .http(let status):
            return .unknown(code: status, message: error.localizedDescription)
        case .network:
            return .backendUnavailable
        case let type:
            return .libraryError(code: type.code, message: error.localizedDescription)
        }
    }

    private func mapNativeLoginFromReceiptError(_ error: Error) -> ClientError {
        let type = (error as? PIAError)?.type
        switch type {
        // Errors that indicate the receipt is either invalid or expired
        case .http(400), .http(401):
            return .badReceipt
        default:
            return mapNativeLoginError(error)
        }
    }

    func info() async throws(ClientError) -> AccountInfo {
        do {
            let account = try await nativeAccountAPI.accountDetails()
            return AccountInfo(accountInformation: account)
        } catch {
            throw mapNativeLoginError(error)
        }
    }

    func update(credentials: Credentials, resetPassword reset: Bool, email: String) async throws {
        do {
            let newPassword = try await nativeAccountAPI.setEmail(email: email, resetPassword: reset)
            if reset, let newPassword {
                Client.configuration.tempAccountPassword = newPassword
            }
        } catch {
            throw mapNativeLoginError(error)
        }
    }

    func loginLink(email: String) async throws(ClientError) {
        do {
            try await nativeAccountAPI.loginLink(email: email)
        } catch {
            throw mapNativeLoginError(error)
        }
    }

    func logout() async throws {
        try await nativeAccountAPI.logout()
    }

    func deleteAccount() async throws {
        try await nativeAccountAPI.deleteAccount()
    }

    func featureFlags() async throws -> [String] {
        try await nativeAccountAPI.featureFlags().flags
    }

    func promoOffersEligibility(receipt: JWS, country: String?) async throws -> [String] {
        try await nativeAccountAPI.promoOffersEligibility(receipt: receipt, country: country).offerIdentifiers
    }

    #if os(iOS) || os(tvOS)
        func signup(with request: Signup) async throws -> SignupResponse {
            var marketingJSON = ""
            if let marketing = request.marketing {
                marketingJSON = stringify(json: marketing)
            }

            var debugJSON = ""
            if let debug = request.debug {
                debugJSON = stringify(json: debug)
            }

            let info = IOSSignupInformation(
                receipt: request.receipt,
                email: request.email,
                marketing: marketingJSON.isEmpty ? nil : marketingJSON,
                debug: debugJSON.isEmpty ? nil : debugJSON
            )

            do {
                let response = try await nativeAccountAPI.signUp(information: info)
                if let password = response.password {
                    return .credentials(Credentials(username: response.username, password: password))
                } else {
                    return .username(response.username)
                }
            } catch {
                log.error("Failed to signup: \(error)")
                let type = (error as? PIAError)?.type
                throw type == .http(status: 400) ? ClientError.badReceipt : ClientError.invalidParameter
            }
        }

        private func stringify(json: Any, prettyPrinted: Bool = false) -> String {
            var options: JSONSerialization.WritingOptions = []
            if prettyPrinted {
                options = JSONSerialization.WritingOptions.prettyPrinted
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: json, options: options)
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                log.error("JSON stringification error: \(error)")
            }

            return ""
        }

        func processPayment(credentials: Credentials, request: Payment) async throws {
            var marketingJSON = ""
            if let marketing = request.marketing {
                marketingJSON = stringify(json: marketing)
            }

            var debugJSON = ""
            if let debug = request.debug {
                debugJSON = stringify(json: debug)
            }

            let info = IOSPaymentInformation(
                receipt: request.receipt,
                marketing: marketingJSON,
                debug: debugJSON
            )

            do {
                try await nativeAccountAPI.payment(
                    username: credentials.username,
                    password: credentials.password,
                    information: info
                )
            } catch {
                throw ClientError.badReceipt
            }
        }
    #endif

    func downloadServers(_ callback: ((ServersBundle?, Error?) -> Void)?) {
        if Client.environment == .staging {
            guard let url = Bundle(for: Self.self).url(forResource: "staging", withExtension: "json"),
                let jsonData = try? Data(contentsOf: url)
            else {
                callback?(nil, ClientError.noRegions)
                return
            }

            guard let bundle = ServersBundle.parse(from: jsonData) else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }

            callback?(bundle, nil)

        } else {
            Task {
                let (response, _) = await self.regionsAPI.fetchVPNRegions(
                    locale: Locale.current.identifier.replacingOccurrences(of: "_", with: "-")
                )

                guard let response else {
                    callback?(nil, ClientError.noRegions)
                    return
                }

                guard
                    let bundleString = try? RegionsUtils.stringify(response),
                    let bundle = ServersBundle.parse(from: bundleString)
                else {
                    callback?(nil, ClientError.malformedResponseData)
                    return
                }

                callback?(bundle, nil)
            }
        }
    }

    // MARK: Store
    func subscriptionInformation(with receipt: JWS?) async throws -> AppStoreInformation? {
        do {
            let response = try await nativeAccountAPI.subscriptions(receipt: receipt)

            let products = response.availableProducts.map { product in
                PIAProduct(
                    identifier: product.id,
                    plan: Plan(rawValue: product.plan) ?? .other,
                    price: product.price,
                    legacy: product.legacy
                )
            }

            let info = AppStoreInformation(products: products)

            return info
        } catch {
            log.warning("Failed to fetch subscription information: \(error)")
            throw mapNativeLoginError(error)
        }
    }
}
