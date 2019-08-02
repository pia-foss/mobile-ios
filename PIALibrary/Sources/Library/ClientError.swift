//
//  ClientError.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation

/// All the errors raised by the client.
public enum ClientError: String, Error {

    /// The Internet is unreachable.
    case internetUnreachable

    /// The service has been denied authorization.
    case unauthorized
    
    /// The service has been throttled for exceeded rate limits.
    case throttled
    
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

    #if os(iOS)
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
    #endif
}
