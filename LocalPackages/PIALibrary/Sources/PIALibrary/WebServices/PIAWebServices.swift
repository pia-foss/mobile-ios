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
import Gloss
import regions
import PIAAccount
import csi

private let log = PIALogger.logger(for: PIAWebServices.self)

class PIAWebServices: WebServices, ConfigurationAccess {
    
    private static let serversVersion = 1002
    private static let store = "apple_app_store"

    let regionsAPI: RegionsAPI!
    let nativeAccountAPI: PIAAccountAPI
    let csiAPI: CSIAPI!
    let csiProtocolInformationProvider = PIACSIProtocolInformationProvider()

    init() {
        let rsa4096Certificate = Client.configuration.rsa4096Certificate
        let endpointsProvider: IRegionEndpointProvider = Client.environment == .staging ? PIARegionStagingClientStateProvider()
        : PIARegionClientStateProvider()

        self.regionsAPI = RegionsBuilder()
            .setEndpointProvider(endpointsProvider: endpointsProvider)
            .setCertificate(certificate: rsa4096Certificate)
            .setUserAgent(userAgent: PIAWebServices.userAgent)
            .setMetadataRequestPath(metadataRequestPath: "/vpninfo/regions/v2")
            .setVpnRegionsRequestPath(vpnRegionsRequestPath: "/vpninfo/servers/v6")
            .setShadowsocksRegionsRequestPath(shadowsocksRegionsRequestPath: "/shadow_socks")
            .build()

        let nativeEndpointProvider: PIAAccountEndpointProvider = switch Client.environment {
        case .staging:
            PIANativeAccountStagingEndpointProvider()
        case .production:
            PIANativeAccountEndpointProvider()
        }

        self.nativeAccountAPI = try! PIAAccountBuilder()
            .setEndpointProvider(nativeEndpointProvider)
            .setCertificate(rsa4096Certificate)
            .setUserAgent(PIAWebServices.userAgent)
            .build()

        var appVersion = "Unknown"
        if let info = Bundle.main.infoDictionary {
            appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
        self.csiAPI = CSIBuilder()
            .setTeamIdentifier(teamIdentifier: Client.Configuration.teamIdentifierCSI)
            .setAppVersion(appVersion: appVersion)
            .setCertificate(certificate: rsa4096Certificate)
            .setUserAgent(userAgent: PIAWebServices.userAgent)
            .setEndPointProvider(endpointsProvider: PIACSIClientStateProvider())
            .addLogProviders(providers_: [
                PIACSIProtocolInformationProvider(),
                PIACSIRegionInformationProvider(),
                PIACSIUserInformationProvider(),
                PIACSIDeviceInformationProvider(),
                PIACSILastKnownExceptionProvider(),
                PIACSILogInformationProvider(),
                PIACSISubscriptionInformationProvider()
            ])
            .build()
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
        return self.nativeAccountAPI.vpnToken
    }

    /***
     The token to use for api authentication.
     */
    var apiToken: String? {
        return self.nativeAccountAPI.apiToken
    }

    /***
     Generates a new auth expiring token based on a previous non-expiry one.
     */
    func migrateToken(token: String) async throws {
        do {
            try await nativeAccountAPI.migrateApiToken(apiToken: token)
        } catch {
            throw ClientError.unauthorized
        }
    }

    /***
     Generates a new auth token for the specific user
     */
    func token(credentials: Credentials) async throws {
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

    /***
     Generates a new auth token for the specific user
     */
    func token(receipt: Data) async throws {
        do {
            try await nativeAccountAPI.loginWithReceipt(receiptBase64: receipt.base64EncodedString())
            try handleLoginResponse(error: nil, mapError: mapNativeLoginFromReceiptError)
        } catch {
            try handleLoginResponse(error: error, mapError: mapNativeLoginFromReceiptError)
        }
    }

    private func handleLoginResponse(
        error: Error?,
        mapError: ((Error) -> (ClientError))
    ) throws {
        if let error {
            throw mapError(error)
        }
    }

    // MARK: - Error mapping

    private func mapNativeLoginError(_ error: Error) -> ClientError {
        let code = (error as? PIAAccountError)?.code ?? (error as? PIAMultipleErrors)?.code
        switch code {
        case 402:
            return .expired
        case 429:
            let retryAfter = (error as? PIAAccountError)?.retryAfterSeconds ?? 0
            return .throttled(retryAfter: UInt(retryAfter))
        case 600:
            return .internetUnreachable
        default:
            return .unauthorized
        }
    }

    private func mapNativeLoginFromReceiptError(_ error: Error) -> ClientError {
        let code = (error as? PIAAccountError)?.code ?? (error as? PIAMultipleErrors)?.code
        switch code {
        // Errors that indicate the receipt is either invalid or expired
        case 400, 401:
            return .badReceipt
        default:
            return mapNativeLoginError(error)
        }
    }

    private func mapNativeLoginLinkError(_ error: Error) -> ClientError {
        let code = (error as? PIAAccountError)?.code ?? (error as? PIAMultipleErrors)?.code
        switch code {
        case 401, 402, 429:
            return mapNativeLoginError(error)
        default:
            return .invalidParameter
        }
    }

    func info() async throws -> AccountInfo {
        do {
            let account = try await nativeAccountAPI.accountDetails()
            return AccountInfo(accountInformation: account)
        } catch {
            throw mapNativeLoginError(error)
        }
    }
    
    func update(credentials: Credentials, resetPassword reset: Bool, email: String) async throws {
        do {
            if reset {
                let newPassword = try await nativeAccountAPI.setEmail(email: email, resetPassword: reset)
                if let newPassword = newPassword {
                    Client.configuration.tempAccountPassword = newPassword
                }
            } else {
                try await nativeAccountAPI.setEmail(username: credentials.username, password: credentials.password, email: email, resetPassword: reset)
            }
        } catch {
            throw mapNativeLoginError(error)
        }
    }
    
    func loginLink(email: String) async throws {
        do {
            try await nativeAccountAPI.loginLink(email: email)
        } catch {
            throw mapNativeLoginLinkError(error)
        }
    }

    func logout() async throws {
        try await nativeAccountAPI.logout()
    }
    
    func deleteAccount() async throws {
        try await nativeAccountAPI.deleteAccount()
    }

    func featureFlags() async throws -> [String] {
        let flags = try? await nativeAccountAPI.featureFlags().flags
        return flags ?? []
    }
    
    #if os(iOS) || os(tvOS)
    func signup(with request: Signup) async throws -> Credentials {
        var marketingJSON = ""
        if let json = request.marketing as? JSON {
            marketingJSON = stringify(json: json)
        }

        var debugJSON = ""
        if let json = request.debug as? JSON {
            debugJSON = stringify(json: json)
        }

        request.toJSON()

        let info = IOSSignupInformation(
            receipt: request.receipt.base64EncodedString(),
            email: request.email,
            marketing: marketingJSON.isEmpty ? nil : marketingJSON,
            debug: debugJSON.isEmpty ? nil : debugJSON
        )

        do {
            let response = try await nativeAccountAPI.signUp(information: info)
            return Credentials(username: response.username, password: response.password)
        } catch {
            let code = (error as? PIAAccountError)?.code ?? (error as? PIAMultipleErrors)?.code
            throw code == 400 ? ClientError.badReceipt : ClientError.invalidParameter
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
        if let json = request.marketing as? JSON {
            marketingJSON = stringify(json: json)
        }

        var debugJSON = ""
        if let json = request.debug as? JSON {
            debugJSON = stringify(json: json)
        }

        let info = IOSPaymentInformation(
            receipt: request.receipt.base64EncodedString(),
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
                  let jsonData = try? Data(contentsOf: url) else {
                callback?(nil, ClientError.noRegions)
                return
            }
            
            guard let bundle = GlossServersBundle(data: jsonData)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }

            callback?(bundle, nil)
            
        } else {
            self.regionsAPI.fetchVpnRegions(locale: Locale.current.identifier.replacingOccurrences(of: "_", with: "-")) { (response, error) in
                if let _ = error {
                    callback?(nil, ClientError.noRegions)
                    return
                }

                guard let response = response else {
                    callback?(nil, ClientError.noRegions)
                    return
                }
                
                guard let bundle = GlossServersBundle(jsonString: RegionsUtils().stringify(regionsResponse: response))?.parsed else {
                    callback?(nil, ClientError.malformedResponseData)
                    return
                }

                callback?(bundle, nil)
            }
        }
    }
    
    // MARK: Store
    func subscriptionInformation(with receipt: Data?) async throws -> AppStoreInformation? {
        do {
            let response = try await nativeAccountAPI.subscriptions(receipt: receipt)

            let products = response.availableProducts.map { product in
                Product(
                    identifier: product.id,
                    plan: Plan(rawValue: product.plan) ?? .other,
                    price: product.price,
                    legacy: product.legacy
                )
            }

            let info = AppStoreInformation(
                products: products,
                eligibleForTrial: response.eligibleForTrial
            )
            Client.configuration.eligibleForTrial = info.eligibleForTrial

            return info
        } catch {
            let code = (error as? PIAAccountError)?.code ?? (error as? PIAMultipleErrors)?.code
            if code == 400 {
                throw ClientError.badReceipt
            } else {
                throw ClientError.invalidParameter
            }
        }
    }
}
