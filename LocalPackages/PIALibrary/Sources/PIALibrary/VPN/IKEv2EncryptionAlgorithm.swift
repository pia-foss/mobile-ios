//
//  IKEv2EncryptionAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
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
import NetworkExtension

public enum IKEv2EncryptionAlgorithm: String, CaseIterable {

    public static let `default`: IKEv2EncryptionAlgorithm = {
        #if os(iOS)
            if #unavailable(iOS 17.0) {
                return .AES128
            }
        #endif
        return .AES256GCM
    }()

    @available(iOS, deprecated: 17.0) case AES128 = "AES-128-CBC"
    @available(iOS, deprecated: 17.0) case AES128GCM = "AES-128-GCM"
    case AES256 = "AES-256-CBC"
    case AES256GCM = "AES-256-GCM"

    public static var allCases: [IKEv2EncryptionAlgorithm] {
        #if os(iOS)
            if #unavailable(iOS 17.0) {
                return [.AES128, .AES128GCM, .AES256]
            }
        #endif
        return [.AES256, .AES256GCM]
    }

    @inlinable
    public var description: String { rawValue }

    public func networkExtensionValue() -> NEVPNIKEv2EncryptionAlgorithm {
        return switch self {
        case .AES128: NEVPNIKEv2EncryptionAlgorithm.algorithmAES128
        case .AES128GCM: NEVPNIKEv2EncryptionAlgorithm.algorithmAES128GCM
        case .AES256: NEVPNIKEv2EncryptionAlgorithm.algorithmAES256
        case .AES256GCM: NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
        }
    }

    public func integrityAlgorithms() -> [IKEv2IntegrityAlgorithm] {
        #if os(iOS)
            if #unavailable(iOS 17.0) {
                return switch self {
                case .AES128: [.SHA384, .SHA512]
                case .AES128GCM: [.SHA160, .SHA256]
                case .AES256: [.SHA96]
                case .AES256GCM: []
                }
            }
        #endif
        return switch self {
        case .AES128, .AES256: [.SHA256, .SHA384, .SHA512]
        case .AES128GCM, .AES256GCM: [.SHA256]
        }
    }
}
