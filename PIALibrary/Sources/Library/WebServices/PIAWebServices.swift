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

private let log = SwiftyBeaver.self

class PIAWebServices: WebServices, ConfigurationAccess {
    private static let serversVersion = 1001

    /***
     Generates a new auth token for the specific user
     */
    func token(credentials: Credentials, _ callback: ((String?, Error?) -> Void)?) {
        let endpoint = ClientEndpoint.token
        let status = [200, 401, 429]
        let errors: [Int: ClientError] = [
            401: .unauthorized,
            429: .throttled
        ]
        
        let parameters = credentials.toJSONDictionary()
        req(nil, .post, endpoint, useAuthToken: true, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            guard let token = GlossToken(json: json)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            callback?(token, nil)
        })
    }

    func info(token: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        let endpoint = ClientEndpoint.account
        let status = [200, 401, 429]
        let errors: [Int: ClientError] = [
            401: .unauthorized,
            429: .throttled
        ]
        
        req(nil, .get, endpoint, useAuthToken: true, nil, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            guard let accountInfo = GlossAccountInfo(json: json)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            callback?(accountInfo, nil)
        })
    }
    
    func update(credentials: Credentials, email: String, _ callback: SuccessLibraryCallback?) {
        let endpoint = ClientEndpoint.updateAccount
        let parameters = ["email": email]
        let status = [200]

        req(credentials, .post, endpoint, useAuthToken: false, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let error = error {
                callback?(error)
                return
            }
            callback?(nil)
        })
    }
    
    func logout(_ callback: LibraryCallback<Bool>?) {
        
        let endpoint = ClientEndpoint.logout
        let status = [200]

        req(nil, .post, endpoint, useAuthToken: true, nil, status, JSONRequestExecutor() { (json, status, error) in
            if let error = error {
                callback?(false, error)
                return
            }
            callback?(true, nil)
        })

    }
    
    #if os(iOS)
    func signup(with request: Signup, _ callback: ((Credentials?, Error?) -> Void)?) {
        let endpoint = ClientEndpoint.signup
        let parameters = request.toJSON()
        let status = [200, 400, 409]
        let errors: [Int: ClientError] = [
            400: .badReceipt
        ]
    
        req(nil, .post, endpoint, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            guard let credentials = GlossCredentials(json: json)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            callback?(credentials, nil)
        })
    }
    
    func redeem(with request: Redeem, _ callback: ((Credentials?, Error?) -> Void)?) {
        let endpoint = ClientEndpoint.redeem
        let parameters = request.toJSON()
        let status = [200, 400, 429]
        let errors: [Int: ClientError] = [
            429: .throttled
        ]
        
        req(nil, .post, endpoint, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            guard (status == 200) else {
                var specificError: ClientError = .malformedResponseData
                if let code = json["code"] as? String {
                    switch code {
                    case "not_found", "canceled":
                        specificError = .redeemInvalid
                        
                    case "redeemed":
                        specificError = .redeemClaimed
                        
                    default:
                        break
                    }
                }
                callback?(nil, specificError)
                return
            }
            guard let credentials = GlossCredentials(json: json)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            callback?(credentials, nil)
        })
    }
    
    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?) {
        let endpoint = ClientEndpoint.payment
        let parameters = request.toJSON()
        let status = [200, 400]
        let errors: [Int: ClientError] = [
            400: .badReceipt
        ]
        
        req(credentials, .post, endpoint, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(knownError)
                return
            }
            if let error = error {
                callback?(error)
                return
            }
            callback?(nil)
        })
    }
    #endif
    
    func downloadServers(_ callback: ((ServersBundle?, Error?) -> Void)?) {
        let endpoint = VPNEndpoint.servers
        let status = [200]
        let parameters: JSON = [
            "os": "ios",
            "version": PIAWebServices.serversVersion
        ]
        
        req(nil, .get, endpoint, parameters, status, DataRequestExecutor() { (data, status, error) in
            if let error = error {
                callback?(nil, error)
                return
            }
            guard let data = data else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            guard let response = ServersResponse(data: data) else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            if self.accessedConfiguration.verifiesServersSignature,
                let key = self.accessedConfiguration.publicKey {
                guard response.verifySignature(publicKey: key) else {
                    callback?(nil, ClientError.badServersSignature)
                    return
                }
            }
            guard let bundle = response.bundle() else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            callback?(bundle, nil)
        })
    }
    
    // MARK: Store
    func subscriptionInformation(with receipt: Data?, _ callback: LibraryCallback<AppStoreInformation>?) {
        let endpoint = ClientEndpoint.ios
        let status = [200, 400]
        let errors: [Int: ClientError] = [
            400: .badReceipt
        ]
        
        var parameters: JSON = [
            "type": "subscription"
        ]
        
        if let receipt = receipt {
            parameters["receipt"] = receipt.base64EncodedString()
        }

        req(nil, .post, endpoint, useAuthToken: false, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            
            if let availableJSONProducts =  json["available_products"] as? [JSON] {

                guard let products = [Product].from(jsonArray: availableJSONProducts) else {
                    callback?(nil, error)
                    return
                }

                let eligibleForTrial = json["eligible_for_trial"] as? Bool ?? false
                
                let info = AppStoreInformation(products: products,
                                    eligibleForTrial: eligibleForTrial)
                Client.configuration.eligibleForTrial = info.eligibleForTrial
                
                callback?(info, nil)
            } else {
                callback?(nil, error)
                return
            }
            
        })

    }
    
    // MARK: Friend referral
    
    func invitesInformation(_ callback: LibraryCallback<InvitesInformation>?) {
        
        let endpoint = ClientEndpoint.invites
        let status = [200, 400]
        let errors: [Int: ClientError] = [
            400: .badReceipt
        ]
        
        req(nil, .get, endpoint, useAuthToken: true, nil, status, JSONRequestExecutor() { (json, status, error) in
            
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(nil, knownError)
                return
            }
            guard let json = json else {
                callback?(nil, error)
                return
            }
            guard let invitesInformation = GlossInvitesInformation(json: json)?.parsed else {
                callback?(nil, ClientError.malformedResponseData)
                return
            }
            
            callback?(invitesInformation, nil)
            
        })

    }
    
    func invite(credentials: Credentials, name: String, email: String, _ callback: SuccessLibraryCallback?) {
        let endpoint = ClientEndpoint.invites
        let status = [200, 400, 401]
        let errors: [Int: ClientError] = [
            400: .badReceipt,
            401: .unauthorized
        ]
        
        if email.isEmpty {
            callback?(ClientError.invalidParameter)
            return
        }
        
        let parameters = ["invitee_name": name,
                          "invitee_email": email]
        
        req(credentials, .post, endpoint, parameters, status, DataRequestExecutor() { (json, status, error) in
            if let knownError = self.knownError(endpoint, status, errors) {
                callback?(knownError)
                return
            }
            if let error = error {
                callback?(error)
                return
            }
            callback?(nil)
        })

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
