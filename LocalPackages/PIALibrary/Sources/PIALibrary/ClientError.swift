//
//  ClientError.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
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

/// All the errors raised by the client.
public enum ClientError: Error, Equatable {

    /// The Internet is unreachable.
    case internetUnreachable

    /// The service has been denied authorization.
    case unauthorized
    
    /// The service has been throttled for exceeded rate limits.
    case throttled(retryAfter: UInt)
    
    /// The service has been expired.
    case expired
    
    /// The operation is not supported.
    case unsupported
    
    /// A web service has returned malformed data.
    case malformedResponseData

    /// A web service has returned an unexpected reply.
    case unexpectedReply
    
    /// The server list doesn't match provided signature.
    case badServersSignature
    
    /// The specified VPN profile protocol is unavailable.
    case vpnProfileUnavailable

    /// Error while checking the dip token renewal.
    case dipTokenRenewalError

    /// The Wireguard Token is missing.
    case missingWireguardToken

    #if os(iOS) || os(tvOS)
    /// No in-app history receipt is available.
    case noReceipt
    
    /// The in-app history receipt is not eligible for a plan or is corrupt.
    case badReceipt
    
    /// The selected in-app product is not available.
    case productUnavailable
    
    /// The redeem code is invalid.
    case redeemInvalid
    
    /// The redeem code was claimed already.
    case redeemClaimed

    /// Trial accounts are not renewable.
    case renewingTrial

    /// The account is not renewable.
    case renewingNonRenewable
    
    /// Invalid parameter
    case invalidParameter
    
    /// The selected sandbox subscription is not available in production.
    case sandboxPurchase
    
    /// Cant retrieve regions
    case noRegions
    #endif
}
