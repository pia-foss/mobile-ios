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
import account
import PIAAccountSwift
import csi

private let log = PIALogger.logger(for: PIAWebServices.self)

@available(tvOS 17.0, *)
class PIAWebServices: WebServices, ConfigurationAccess {
    
    private static let serversVersion = 1002
    private static let store = "apple_app_store"

    let regionsAPI: RegionsAPI!
    let accountAPI: IOSAccountAPI!
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

        if Client.environment == .staging {
            self.accountAPI = AccountBuilder<IOSAccountAPI>()
                .setPlatform(platform: .ios)
                .setEndpointProvider(endpointsProvider: PIAAccountStagingClientStateProvider())
                .setUserAgentValue(userAgentValue: PIAWebServices.userAgent)
                .setCertificate(certificate: rsa4096Certificate)
                .build() as? IOSAccountAPI
        } else {
            self.accountAPI = AccountBuilder<IOSAccountAPI>()
                .setPlatform(platform: .ios)
                .setEndpointProvider(endpointsProvider: PIAAccountClientStateProvider())
                .setUserAgentValue(userAgentValue: PIAWebServices.userAgent)
                .setCertificate(certificate: rsa4096Certificate)
                .build() as? IOSAccountAPI
        }

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
                PIACSILogInformationProvider()
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
    func migrateToken(token: String, _ callback: ((Error?) -> Void)?) {
        self.accountAPI.migrateApiToken(apiToken: token) { (errors) in
            if !errors.isEmpty {
                callback?(ClientError.unauthorized)
                return
            }

            callback?(nil)
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
    func validateLoginQR(qrToken: String, _ callback: ((String?, Error?) -> Void)?) {
        self.accountAPI.validateLoginQR(qrToken: qrToken) { apiToken, errors in
            if !errors.isEmpty {
                callback?(nil, ClientError.unauthorized)
                return
            }

            callback?(apiToken, nil)
        }
    }

    /***
     Generates a new auth token for the specific user
     */
    func token(receipt: Data, _ callback: ((Error?) -> Void)?) {
        self.accountAPI.loginWithReceipt(receiptBase64: receipt.base64EncodedString()) { [weak self] (errors) in
            self?.handleLoginResponse(errors: errors, callback: callback, mapError: self?.mapLoginFromReceiptError)
        }
    }

    private func handleLoginResponse(errors: [AccountRequestError],  callback: ((Error?) -> Void)?, mapError: ((AccountRequestError) -> (ClientError))? = nil) {
        if !errors.isEmpty {
            callback?(mapError?(errors.last!))
            return
        }

        callback?(nil)
    }

    private func mapLoginError(_ error: AccountRequestError) -> ClientError {
        switch error.code {
        case 402:
            return .expired
        case 429:
            return .throttled(retryAfter: UInt(error.retryAfterSeconds))
        case 600:
            return .internetUnreachable
        default:
            return .unauthorized
        }
    }

    // MARK: - Native (PIAAccountSwift) error mapping

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

    private func mapLoginFromReceiptError(_ error:AccountRequestError) -> ClientError {
        switch error.code {
        // Errors that indicate the receipt is either invalid or expired
        case 400, 401:
            return .badReceipt
        default:
            return mapLoginError(error)
        }
    }

    private func mapLoginLinkError(_ error:AccountRequestError) -> ClientError {
        switch error.code {
        case 401,402,429:
            return mapLoginError(error)
        default:
            return .invalidParameter
        }
    }

    private func mapAccountDetailsError(_ error:AccountRequestError) -> ClientError {
        return mapLoginLinkError(error)
    }

    func info() async throws -> AccountInfo {
        do {
            let account = try await nativeAccountAPI.accountDetails()
            return AccountInfo(accountInformation: account)
        } catch {
            throw mapNativeLoginError(error)
        }
    }
    
    func update(credentials: Credentials, resetPassword reset: Bool, email: String, _ callback: SuccessLibraryCallback?) {
        if reset {
            //Reset password, we use the token within accounts
            self.accountAPI.setEmail(email: email, resetPassword: reset) { [weak self] (newPassword, errors) in
                if !errors.isEmpty {
                    callback?(self?.mapLoginError(errors.last!))
                    return
                }
                if let newPassword = newPassword {
                    Client.configuration.tempAccountPassword = newPassword
                }
                callback?(nil)
            }
        } else {
            //We use the email and the password returned by the signup endpoint in the previous step, we don't update the password
            self.accountAPI.setEmail(username: credentials.username, password: credentials.password, email: email, resetPassword: reset) { (newPassword, errors) in
                if !errors.isEmpty {
                    callback?(ClientError.unsupported)
                    return
                }
                callback?(nil)
            }
        }
    }
    
    func loginLink(email: String, _ callback: SuccessLibraryCallback?) {
        
        self.accountAPI.loginLink(email: email) { [weak self] (errors) in
            if !errors.isEmpty {
                callback?(self?.mapLoginLinkError(errors.last!))
                return
            }

            callback?(nil)
        }
    }

    func logout() async throws {
        try await nativeAccountAPI.logout()
    }
    
    func deleteAccount(_ callback: LibraryCallback<Bool>?) {
        self.accountAPI.deleteAccount(callback: { errors in
            if !errors.isEmpty {
                callback?(false, ClientError.invalidParameter)
            } else {
                callback?(true, nil)
            }
        })
    }
    
    
    fileprivate func mapDIPError(_ error: AccountRequestError?) -> ClientError {
        guard let error = error else {
            return ClientError.invalidParameter
        }
        switch error.code {
        case 401:
            return ClientError.unauthorized
        case 429:
            return ClientError.throttled(retryAfter: UInt(error.retryAfterSeconds))
        default:
            return ClientError.invalidParameter
        }
    }
    

    
    func featureFlags(_ callback: LibraryCallback<[String]>?) {
        self.accountAPI.featureFlags { (info, errors) in
            if let flags = info?.flags {
                callback?(flags, nil)
            } else {
                callback?([], ClientError.malformedResponseData)
            }
        }
    }
    
    #if os(iOS) || os(tvOS)
    func signup(with request: Signup, _ callback: ((Credentials?, Error?) -> Void)?) {
        var marketingJSON = ""
        if let json = request.marketing as? JSON {
            marketingJSON = stringify(json: json)
        }
        
        var debugJSON = ""
        if let json = request.debug as? JSON {
            debugJSON = stringify(json: json)
        }
        
        request.toJSON()
        
        let info = IOSSignupInformation(store: Self.store, receipt: request.receipt.base64EncodedString(), email: request.email, marketing: marketingJSON.isEmpty ? nil : marketingJSON, debug: debugJSON.isEmpty ? nil : debugJSON)
        self.accountAPI.signUp(information: info) { (response, errors) in
            if !errors.isEmpty {
                callback?(nil, errors.last?.code == 400 ? ClientError.badReceipt : ClientError.invalidParameter)
                return
            }

            guard let response = response else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }

            callback?(Credentials(username: response.username, password: response.password), nil)
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

    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?) {
        var marketingJSON = ""
        if let json = request.marketing as? JSON {
            marketingJSON = stringify(json: json)
        }
        
        var debugJSON = ""
        if let json = request.debug as? JSON {
            debugJSON = stringify(json: json)
        }
        
        let info = IOSPaymentInformation(store: Self.store, receipt: request.receipt.base64EncodedString(), marketing: marketingJSON, debug: debugJSON)

        self.accountAPI.payment(username: credentials.username, password: credentials.password, information: info) { (errors) in
            if !errors.isEmpty {
                callback?(ClientError.badReceipt)
                return
            }
            callback?(nil)
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
    func subscriptionInformation(with receipt: Data?, _ callback: LibraryCallback<AppStoreInformation>?) {
        self.accountAPI.subscriptions(receipt: nil) { (response, errors) in
            if !errors.isEmpty {
                callback?(nil, errors.last?.code == 400 ? ClientError.badReceipt : ClientError.invalidParameter)
                return
            }

            if let response = response {
                
                var products = [Product]()
                for prod in response.availableProducts {
                    let product = Product(identifier: prod.id,
                                          plan: Plan(rawValue: prod.plan) ?? .other,
                                          price: prod.price,
                                          legacy: prod.legacy)
                    products.append(product)
                }

                let eligibleForTrial = response.eligibleForTrial
                
                let info = AppStoreInformation(products: products,
                                    eligibleForTrial: eligibleForTrial)
                Client.configuration.eligibleForTrial = info.eligibleForTrial
                
                callback?(info, nil)

            } else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
        }
    }
}
