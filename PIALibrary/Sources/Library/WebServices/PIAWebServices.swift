//
//  PIAWebServices.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import Alamofire
import Gloss
import SwiftyBeaver

private let log = SwiftyBeaver.self

class PIAWebServices: WebServices, ConfigurationAccess {
    private static let serversVersion = 60

    func info(credentials: Credentials, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        let endpoint = ClientEndpoint.account
        let status = [200, 401, 429]
        let errors: [Int: ClientError] = [
            401: .unauthorized,
            429: .throttled
        ]
        
        req(credentials, .get, endpoint, nil, status, JSONRequestExecutor() { (json, status, error) in
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
        let endpoint = ClientEndpoint.account
        let parameters = ["email": email]
        let status = [200]

        req(credentials, .post, endpoint, parameters, status, JSONRequestExecutor() { (json, status, error) in
            if let error = error {
                callback?(error)
                return
            }
            callback?(nil)
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
            if self.accessedConfiguration.verifiesServersSignature {
                guard response.verifySignature(publicKey: self.accessedConfiguration.publicKey) else {
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
    
    // MARK: Helpers

    private func req(
        _ credentials: Credentials?,
        _ method: HTTPMethod,
        _ endpoint: Endpoint,
        _ parameters: [String: Any]?,
        _ statuses: [Int],
        _ executor: RequestExecutor) {
        
        req(credentials, method, endpoint.url, parameters, statuses, executor)
    }
    
    private func req(
        _ credentials: Credentials?,
        _ method: HTTPMethod,
        _ url: URL,
        _ parameters: [String: Any]?,
        _ statuses: [Int],
        _ executor: RequestExecutor) {
        
        var headers = HTTPHeaders()
//        headers["X-Device"] = "ios-\(Constants.iosVersion)/\(Constants.appVersion)/\(Constants.language)/\(Constants.region)"
        if let credentials = credentials, let authHeader = Request.authorizationHeader(user: credentials.username, password: credentials.password) {
            headers[authHeader.key] = authHeader.value
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
