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
import Alamofire
import Gloss
import SwiftyBeaver
import PIARegions
import PIAAccount
import PIACSI
import PIARegions

private let log = SwiftyBeaver.self

class PIAWebServices: WebServices, ConfigurationAccess {
    
    private static let serversVersion = 1002
    private static let store = "apple_app_store"

    let regionsAPI: RegionsAPI!
    let accountAPI: IOSAccountAPI!
    let csiAPI: CSIAPI!
    let csiProtocolInformationProvider = PIACSIProtocolInformationProvider()
    
    init() {
        let rsa4096Certificate = Client.configuration.rsa4096Certificate
        self.regionsAPI = RegionsBuilder()
            .setEndpointProvider(endpointsProvider: PIARegionClientStateProvider())
            .setCertificate(certificate: rsa4096Certificate)
            .setUserAgent(userAgent: PIAWebServices.userAgent)
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
        
        var appVersion = "Unknown"
        if let info = Bundle.main.infoDictionary {
            appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        }
        self.csiAPI = CSIBuilder()
            .setPlatform(platform: .ios)
            .setAppVersion(appVersion: appVersion)
            .setCSIClientStateProvider(csiClientStateProvider: PIACSIClientStateProvider())
            .setProtocolInformationProvider(protocolInformationProvider: csiProtocolInformationProvider)
            .setRegionInformationProvider(regionInformationProvider: PIACSIRegionInformationProvider())
            .build()
    }
    
    public static let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
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
                                             password: credentials.password) { [weak self] (errors) in
            self?.handleLoginResponse(errors: errors, callback: callback, mapError: self?.mapLoginError)
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
        case 429:
            return .throttled(retryAfter: UInt(error.retryAfterSeconds))
        default:
            return .unauthorized
        }
    }


    private func mapLoginFromReceiptError(_ error:AccountRequestError) -> ClientError {
        switch error.code {
        case 400:
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

    func info(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        self.accountAPI.accountDetails() { [weak self] (response, errors) in
            if !errors.isEmpty {
                callback?(nil, self?.mapAccountDetailsError(errors.last!))
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
    
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {
        self.accountAPI.renewDedicatedIP(ipToken: dipToken) { (errors) in
            if !errors.isEmpty {
                callback?(errors.last?.code == 401 ? ClientError.unauthorized : ClientError.dipTokenRenewalError)
                return
            }
            callback?(nil)
        }
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
    
    func activateDIPToken(tokens: [String], _ callback: LibraryCallback<[Server]>?) {
        self.accountAPI.dedicatedIPs(ipTokens: tokens) { (dedicatedIps, errors) in
            if !errors.isEmpty {
                callback?([], self.mapDIPError(errors.last))
                return
            }

            var dipRegions = [Server]()
            for dipServer in dedicatedIps {

                let status = DedicatedIPStatus(fromAPIStatus: dipServer.status)

                switch status {
                case .active:

                    guard let firstServer = Client.providers.serverProvider.currentServers.first(where: {$0.regionIdentifier == dipServer.id}) else {
                        callback?([], ClientError.malformedResponseData)
                        return
                    }

                    guard let ip = dipServer.ip, let cn = dipServer.cn, let expirationTime = dipServer.dip_expire else {
                        callback?([], ClientError.malformedResponseData)
                        return
                    }

                    let dipToken = dipServer.dipToken

                    let expiringDate = Date(timeIntervalSince1970: TimeInterval(expirationTime))
                    let server = Server.ServerAddressIP(ip: ip, cn: cn, van: false)

                    if let nextDays = Calendar.current.date(byAdding: .day, value: 5, to: Date()), nextDays >= expiringDate  {
                        //Expiring in 5 days or less
                        Macros.postNotification(.PIADIPRegionExpiring, [.token : dipToken])
                    }

                    Macros.postNotification(.PIADIPCheckIP, [.token : dipToken, .ip : ip])

                    let dipUsername = "dedicated_ip_"+dipServer.dipToken+"_"+String.random(length: 8)

                    let dipRegion = Server(serial: firstServer.serial, name: firstServer.name, country: firstServer.country, hostname: firstServer.hostname, openVPNAddressesForTCP: [server], openVPNAddressesForUDP: [server], wireGuardAddressesForUDP: [server], iKEv2AddressesForUDP: [server], pingAddress: firstServer.pingAddress, geo: false, meta: nil, dipExpire: expiringDate, dipToken: dipServer.dipToken, dipStatus: status, dipUsername: dipUsername, regionIdentifier: firstServer.regionIdentifier)

                    dipRegions.append(dipRegion)

                    Client.database.secure.setDIPToken(dipServer.dipToken)
                    Client.database.secure.setPassword(ip, forDipToken: dipUsername)

                default:

                    let dipRegion = Server(serial: "", name: "", country: "", hostname: "", openVPNAddressesForTCP: [], openVPNAddressesForUDP: [], wireGuardAddressesForUDP: [], iKEv2AddressesForUDP: [], pingAddress: nil, geo: false, meta: nil, dipExpire: nil, dipToken: nil, dipStatus: status, dipUsername: nil, regionIdentifier: "")
                    dipRegions.append(dipRegion)

                }

            }
            callback?(dipRegions, nil)
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
    
    #if os(iOS)
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
            print(error)
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
            self.regionsAPI.fetchRegions(locale: Locale.current.identifier.replacingOccurrences(of: "_", with: "-")) { (response, errors) in
                if !errors.isEmpty {
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
    
    // MARK: Messages
    func messages(forAppVersion version: String, _ callback: LibraryCallback<InAppMessage>?) {
        self.accountAPI.message(appVersion: version, callback: { (message, errors) in
            if !errors.isEmpty {
                callback?(nil, ClientError.malformedResponseData)
                return
            }

            if let message = message {
                let inAppMessage = InAppMessage(withMessage: message, andLevel: .api)
                callback?(inAppMessage, nil)
            } else {
                callback?(nil, nil)
            }
        })
    }
}

typealias HandlerType<T> = (T?, Int?, Error?) -> Void

private protocol RequestExecutor {
    func execute(_ method: HTTPMethod, _ url: URL, _ request: DataRequest)
}

private class DataRequestExecutor: RequestExecutor {
    let completionHandler: HandlerType<Data>
    
    init(_ completionHandler: @escaping HandlerType<Data>) {
        self.completionHandler = completionHandler
    }
    
    func execute(_ method: HTTPMethod, _ url: URL, _ request: DataRequest) {
        request.responseData { (response) in
            let status = response.response?.statusCode
            if let error = response.error {
                log.error("Request failed: \(method) \"\(url)\" -> \(error)")
                self.completionHandler(nil, status, error)
                return
            }
            guard let data = response.value else {
                self.completionHandler(nil, status, ClientError.malformedResponseData)
                return
            }
            log.debug("Response: \(data)")
            self.completionHandler(data, status, nil)
        }
    }
}

private class JSONRequestExecutor: RequestExecutor {
    let completionHandler: HandlerType<JSON>
    
    init(_ completionHandler: @escaping HandlerType<JSON>) {
        self.completionHandler = completionHandler
    }
    
    func execute(_ method: HTTPMethod, _ url: URL, _ request: DataRequest) {
        request.validate(contentType: ["application/json"]).responseJSON { (response) in
            let status = response.response?.statusCode
            if let error = response.error {
                log.error("Request failed: \(method) \"\(url)\" -> \(error)")
                self.completionHandler(nil, status, error)
                return
            }
            guard let json = response.value as? [String: Any] else {
                self.completionHandler(nil, status, ClientError.malformedResponseData)
                return
            }
            log.debug("Response: \(json)")
            self.completionHandler(json, status, nil)
        }
    }
}
