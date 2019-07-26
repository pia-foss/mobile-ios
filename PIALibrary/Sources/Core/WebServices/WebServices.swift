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

    func token(credentials: Credentials, _ callback: LibraryCallback<String>?)

    func info(token: String, _ callback: LibraryCallback<AccountInfo>?)

    func update(credentials: Credentials, email: String, _ callback: SuccessLibraryCallback?)

    #if os(iOS)
    func signup(with request: Signup, _ callback: LibraryCallback<Credentials>?)

    func redeem(with request: Redeem, _ callback: LibraryCallback<Credentials>?)

    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?)
    #endif

    // MARK: Store
    
    func planProductIdentifiers(_ callback: LibraryCallback<[Product]>?)

    // MARK: Ephemeral

    func downloadServers(_ callback: LibraryCallback<ServersBundle>?)

    func flagURL(for country: String) -> URL

    func taskForConnectivityCheck(_ callback: LibraryCallback<ConnectivityStatus>?) -> URLSessionDataTask

    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?)
    
    // MARK: Friend Referral
    
    func invitesInformation(_ callback: LibraryCallback<InvitesInformation>?)
    
    func invite(name: String, email: String, _ callback: SuccessLibraryCallback?)
}
