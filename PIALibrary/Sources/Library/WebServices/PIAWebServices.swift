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
        self.regionsAPI = RegionsBuilder()
            .setClientStateProvider(clientStateProvider: PIARegionClientStateProvider())
            .build()
        
        if Client.environment == .staging {
            self.accountAPI = AccountBuilder<IOSAccountAPI>()
                .setPlatform(platform: .ios)
                .setClientStateProvider(clientStateProvider: PIAAccountStagingClientStateProvider())
                .setUserAgentValue(userAgentValue: PIAWebServices.userAgent)
                .build() as? IOSAccountAPI
        } else {
            self.accountAPI = AccountBuilder<IOSAccountAPI>()
                .setPlatform(platform: .ios)
                .setClientStateProvider(clientStateProvider: PIAAccountClientStateProvider())
                .setUserAgentValue(userAgentValue: PIAWebServices.userAgent)
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
     Generates a new auth token for the specific user
     */
    func token(credentials: Credentials, _ callback: ((String?, Error?) -> Void)?) {
        
        self.accountAPI.loginWithCredentials(username: credentials.username,
                                             password: credentials.password) { (response, error) in

                                                if let error = error {
                                                    callback?(nil, ClientError.unauthorized)
                                                    return
                                                }
                                                
                                                guard let loginResponse = response else {
                                                    callback?(nil, ClientError.malformedResponseData)
                                                    return
                                                }
                                                
                                                callback?(loginResponse.token, nil)
                                                
        }
        
    }

    /***
     Generates a new auth token for the specific user
     */
    func token(receipt: Data, _ callback: ((String?, Error?) -> Void)?) {
        
        self.accountAPI.loginWithReceipt(receiptBase64: receipt.base64EncodedString()) { (response, error) in
            
            if let error = error {
                callback?(nil, error.code == 400 ? ClientError.badReceipt : ClientError.unauthorized)
                return
            }

            guard let token = response else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            
            callback?(token, nil)
            
        }
        
    }

    func info(token: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        
        if let token = Client.providers.accountProvider.token {
            
            self.accountAPI.accountDetails(token: token) { (response, error) in
                
                if let error = error {
                    callback?(nil, error.code == 401 ? ClientError.unauthorized : ClientError.invalidParameter)
                    return
                }
                
                if let response = response {
                    let account = AccountInfo(accountInformation: response)
                    callback?(account, nil)
                } else {
                    callback?(nil, ClientError.malformedResponseData)
                }
                
            }

        } else {
            callback?(nil, ClientError.unauthorized)
        }
        
    }
    
    func update(credentials: Credentials, resetPassword reset: Bool, email: String, _ callback: SuccessLibraryCallback?) {
        
        if reset {
            //Reset password, we use the token
            if let token = Client.providers.accountProvider.token {
                self.accountAPI.setEmail(token: token, email: email, resetPassword: reset) { (newPassword, error) in
                    if let error = error {
                        callback?(error.code == 401 ? ClientError.unauthorized : ClientError.unsupported)
                        return
                    }
                    if let newPassword = newPassword {
                        Client.configuration.tempAccountPassword = newPassword
                    }
                    callback?(nil)
                }
            } else {
                callback?(ClientError.unauthorized)
            }
        } else {
            //We use the email and the password returned by the signup endpoint in the previous step, we don't update the password
            self.accountAPI.setEmail(username: credentials.username, password: credentials.password, email: email, resetPassword: reset) { (newPassword, error) in
                if let error = error {
                    callback?(ClientError.unsupported)
                    return
                }
                callback?(nil)
            }
        }
        
    }
    
    func loginLink(email: String, _ callback: SuccessLibraryCallback?) {
        
        self.accountAPI.loginLink(email: email) { (error) in
            if let error = error {
                callback?(ClientError.invalidParameter)
                return
            }
            callback?(nil)
        }
        
    }
    
    func logout(_ callback: LibraryCallback<Bool>?) {
        
        if let token = Client.providers.accountProvider.token {
            self.accountAPI.logout(token: token) { (accountError) in
                if let error = accountError {
                    if error.code == 401 {
                        callback?(true, nil)
                        return
                    }
                    callback?(false, ClientError.invalidParameter)
                    return
                }
                callback?(true, nil)
            }
        } else {
            callback?(false, ClientError.unauthorized)
        }

    }
    
    func handleDIPTokenExpiration(dipToken: String, _ callback: SuccessLibraryCallback?) {

        if let token = Client.providers.accountProvider.token {
            self.accountAPI.renewDedicatedIP(authToken: token, ipToken: dipToken) { (error) in
                if let error = error {
                    callback?(error.code == 401 ? ClientError.unauthorized : ClientError.dipTokenRenewalError)
                    return
                }
                callback?(nil)
            }
        }
        
    }
    
    func activateDIPToken(tokens: [String], _ callback: LibraryCallback<[Server]>?) {
        
        if let token = Client.providers.accountProvider.token {
            self.accountAPI.dedicatedIPs(authToken: token, ipTokens: tokens) { (dedicatedIps, error) in
                if let error = error as? AccountRequestError {
                    callback?([], error.code == 401 ? ClientError.unauthorized : ClientError.invalidParameter)
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
        }else {
            callback?([], ClientError.unauthorized)
        }
    }
    
    
    func featureFlags(_ callback: LibraryCallback<[String]>?) {
        self.accountAPI.featureFlags(stagingEndpoint: nil) { (info, error) in
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
        self.accountAPI.signUp(information: info) { (response, error) in
            
            if let error = error {
                callback?(nil, error.code == 400 ? ClientError.badReceipt : ClientError.invalidParameter)
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

        self.accountAPI.payment(username: credentials.username, password: credentials.password, information: info) { (error) in
            if let error = error {
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
            
            self.regionsAPI.fetchRegions(locale: Locale.current.identifier.replacingOccurrences(of: "_", with: "-")) { (response, error) in
                if let error = error {
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

        self.accountAPI.subscriptions(receipt: nil) { (response, error) in
            
            if let error = error {
                callback?(nil, error.code == 400 ? ClientError.badReceipt : ClientError.invalidParameter)
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

        if let token = Client.providers.accountProvider.token {

            self.accountAPI.message(token: token, appVersion: version, callback: { (message, error) in
                
                if let error = error {
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

        } else {
            callback?(nil, ClientError.unauthorized)
        }
        
    }

        
    // MARK: Helpers

    private func req(
        _ credentials: Credentials?,
        _ method: HTTPMethod,
        _ endpoint: Endpoint,
        useAuthToken useToken: Bool = false,
        _ parameters: [String: Any]?,
        _ statuses: [Int],
        _ executor: RequestExecutor) {
        
        req(credentials, method, endpoint.url, useToken, parameters, statuses, executor)
    }
    
    private func req(
        _ credentials: Credentials?,
        _ method: HTTPMethod,
        _ url: URL,
        _ useToken: Bool,
        _ parameters: [String: Any]?,
        _ statuses: [Int],
        _ executor: RequestExecutor) {
        
        var headers = SessionManager.defaultHTTPHeaders
//        headers["X-Device"] = "ios-\(Constants.iosVersion)/\(Constants.appVersion)/\(Constants.language)/\(Constants.region)"
        if let credentials = credentials, let authHeader = Request.authorizationHeader(user: credentials.username, password: credentials.password) {
            headers[authHeader.key] = authHeader.value
        }
        
        if useToken,
            let token = Client.providers.accountProvider.token {
            headers["Authorization"] = "Token \(token)"
        }

        if let parameters = parameters {
            log.debug("Request: \(method) \"\(url)\", parameters: \(parameters), headers: \(headers)")
        } else {
            log.debug("Request: \(method) \"\(url)\", headers: \(headers)")
        }

        let request = accessedConfiguration.sessionManager.request(url, method: method, parameters: parameters, headers: headers).validate(statusCode: statuses)
        executor.execute(method, url, request)
    }

    private func knownError(_ endpoint: Endpoint, _ status: Int?, _ errors: [Int: ClientError]) -> ClientError? {
        guard let status = status, let error = errors[status] else {
            return nil
        }
        log.error("Request failed: \(endpoint) -> \(error)")
        return error
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
