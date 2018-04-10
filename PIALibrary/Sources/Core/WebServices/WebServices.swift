//
//  WebServices.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/2/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

protocol WebServicesConsumer {
    var webServices: WebServices { get }
}

protocol WebServices: class {
    
    // MARK: Account
    
    func info(credentials: Credentials, _ callback: LibraryCallback<AccountInfo>?)

    func update(credentials: Credentials, email: String, _ callback: SuccessLibraryCallback?)

    #if os(iOS)
    func signup(with request: Signup, _ callback: LibraryCallback<Credentials>?)
    
    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?)
    #endif
    
    // MARK: Ephemeral

    func downloadServers(_ callback: LibraryCallback<ServersBundle>?)

    func flagURL(for country: String) -> URL

    func taskForConnectivityCheck(_ callback: LibraryCallback<ConnectivityStatus>?) -> URLSessionDataTask

    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?)
}
