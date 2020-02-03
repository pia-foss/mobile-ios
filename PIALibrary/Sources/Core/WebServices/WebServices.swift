//
//  WebServices.swift
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

protocol WebServicesConsumer {
    var webServices: WebServices { get }
}

protocol WebServices: class {
    
    // MARK: Account

    func token(credentials: Credentials, _ callback: LibraryCallback<String>?)

    func info(token: String, _ callback: LibraryCallback<AccountInfo>?)

    func update(credentials: Credentials, email: String, _ callback: SuccessLibraryCallback?)

    /**
         Invalidates the access token.
         - Parameter callback: Returns an `Bool` if the token was expired.
     */
    func logout(_ callback: LibraryCallback<Bool>?)

    #if os(iOS)
    func signup(with request: Signup, _ callback: LibraryCallback<Credentials>?)

    func redeem(with request: Redeem, _ callback: LibraryCallback<Credentials>?)

    func processPayment(credentials: Credentials, request: Payment, _ callback: SuccessLibraryCallback?)
    #endif

    // MARK: Store
    
    func subscriptionInformation(with receipt: Data?, _ callback: LibraryCallback<AppStoreInformation>?)

    // MARK: Ephemeral

    func downloadServers(_ callback: LibraryCallback<ServersBundle>?)

    func flagURL(for country: String) -> URL

    func taskForConnectivityCheck(_ callback: LibraryCallback<ConnectivityStatus>?) -> URLSessionDataTask

    func submitDebugLog(_ log: DebugLog, _ callback: SuccessLibraryCallback?)
    
    // MARK: Friend Referral
    
    func invitesInformation(_ callback: LibraryCallback<InvitesInformation>?)
    
    func invite(credentials: Credentials, name: String, email: String, _ callback: SuccessLibraryCallback?)
}
