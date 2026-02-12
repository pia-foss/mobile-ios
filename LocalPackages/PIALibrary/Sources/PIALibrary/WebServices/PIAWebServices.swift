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
import regions
import account
import PIACSI

private let log = PIALogger.logger(for: PIAWebServices.self)

final class PIAWebServices: WebServices, ConfigurationAccess {
    
    private static let serversVersion = 1002
    private static let store = "apple_app_store"

    let regionsAPI: RegionsAPI!
    let accountAPI: IOSAccountAPI!
    let csiClient = CSIClient(userAgent: PIAWebServices.userAgent)

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
        return self.accountAPI.vpnToken()
    }

    /***
     The token to use for api authentication.
     */
    var apiToken: String? {
        return self.accountAPI.apiToken()
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
    func token(credentials: Credentials, _ callback: ((Error?) -> Void)?) {
        self.accountAPI.loginWithCredentials(username: credentials.username,
                                             password: credentials.password) { errors in
            Self.handleLoginResponse(errors: errors, mapper: \.loginError, callback: callback)
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
        self.accountAPI.loginWithReceipt(receiptBase64: receipt.base64EncodedString()) { errors in
            Self.handleLoginResponse(errors: errors, mapper: \.loginFromReceiptError, callback: callback)
        }
    }

    private static func handleLoginResponse(
        errors: [AccountRequestError],
        mapper path: KeyPath<AccountRequestError, ClientError>,
        callback: ((ClientError?) -> Void)?,
    ) {
        if let error = errors.last {
            callback?(error[keyPath: path])
        } else {
            callback?(nil)
        }
    }

    func info(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        self.accountAPI.accountDetails() { response, errors in
            if !errors.isEmpty {
                callback?(nil, errors.last?.accountDetailsError)
                return
            }

            if let response = response {
                let account = AccountInfo(accountInformation: response)
                callback?(account, nil)
            } else {
                callback?(nil, ClientError.malformedResponseData)
            }
        }
    }
    
    func update(credentials: Credentials, resetPassword reset: Bool, email: String, _ callback: SuccessLibraryCallback?) {
        if reset {
            //Reset password, we use the token within accounts
            self.accountAPI.setEmail(email: email, resetPassword: reset) { (newPassword, errors) in
                if !errors.isEmpty {
                    callback?(errors.last?.loginError)
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
        self.accountAPI.loginLink(email: email) { errors in
            Self.handleLoginResponse(errors: errors, mapper: \.loginLinkError, callback: callback)
        }
    }
    
    func logout(_ callback: LibraryCallback<Bool>?) {
        self.accountAPI.logout() { (errors) in
            if !errors.isEmpty {
                if errors.last?.code == 401 {
                    callback?(true, nil)
                    return
                }
                callback?(false, ClientError.invalidParameter)
                return
            }
            callback?(true, nil)
        }
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
        if let marketing = request.marketing {
            marketingJSON = stringify(json: marketing)
        }

        var debugJSON = ""
        if let debug = request.debug {
            debugJSON = stringify(json: debug)
        }

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
        if let marketing = request.marketing {
            marketingJSON = stringify(json: marketing)
        }

        var debugJSON = ""
        if let debug = request.debug {
            debugJSON = stringify(json: debug)
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
            
            guard let bundle = ServersBundle.parse(from: jsonData) else {
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
                
                guard let bundle = ServersBundle.parse(from: RegionsUtils().stringify(regionsResponse: response)) else {
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

// MARK: - AccountRequestError -> ClientError

extension AccountRequestError {
    public static let internalErrorCode: Int32 = 600

    fileprivate var loginError: ClientError {
        switch code {
        case 401:
            return .unauthorized
        case 402:
            return .expired
        case 429:
            return .throttled(retryAfter: UInt(retryAfterSeconds))
        case AccountRequestError.internalErrorCode:
            return .libraryError(message: message)
        default:
            return .unknown(code: Int(code), message: message)
        }
    }

    fileprivate var loginFromReceiptError: ClientError {
        switch code {
        // Errors that indicate the receipt is either invalid or expired
        case 400, 401:
            return .badReceipt
        default:
            return loginError
        }
    }

    fileprivate var loginLinkError: ClientError {
        switch loginError {
        case .unknown:
            return .invalidParameter
        case let error:
            return error
        }
    }

    fileprivate var accountDetailsError: ClientError { loginLinkError }
}
