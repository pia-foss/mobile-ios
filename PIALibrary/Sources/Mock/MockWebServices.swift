//
//  MockWebServices.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

class MockWebServices: WebServices {
    var credentials: (() -> Credentials)?

    var accountInfo: (() -> AccountInfo)?
    
    var serversBundle: (() -> ServersBundle)?
    
    func info(credentials: Credentials, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        let result = accountInfo?()
        let error: ClientError? = (result == nil) ? .unsupported : nil
        callback?(result, error)
    }
    
    func signup(with request: Signup, _ callback: ((Credentials?, Error?) -> Void)?) {
        let result = credentials?()
        let error: ClientError? = (result == nil) ? .unsupported : nil
        callback?(result, error)
    }
    
    func update(credentials: Credentials, email: String, _ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
    
    func downloadServers(_ callback: ((ServersBundle?, Error?) -> Void)?) {
        let result = serversBundle?()
        let error: ClientError? = (result == nil) ? .unsupported : nil
        callback?(result, error)
    }
    
    func flagURL(for country: String) -> URL {
        return URL(fileURLWithPath: "")
    }
    
    func taskForConnectivityCheck(_ callback: ((ConnectivityStatus?, Error?) -> Void)?) -> URLSessionDataTask {
        return URLSessionDataTask()
    }
    
    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?) {
        callback?(nil)
    }
}
