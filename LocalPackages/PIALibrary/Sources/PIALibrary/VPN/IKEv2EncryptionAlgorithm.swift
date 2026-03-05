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

public enum IKEv2EncryptionAlgorithm: String, EnumsBuilder {

    public static let defaultAlgorithm: IKEv2EncryptionAlgorithm = .algorithmAES256GCM
    
    case algorithmAES128 = "AES-128-CBC"
    case algorithmAES256 = "AES-256-CBC"
    case algorithmAES128GCM = "AES-128-GCM"
    case algorithmAES256GCM = "AES-256-GCM"
    
    public func description() -> String {
        return self.rawValue
    }
    
    public func value() -> String {
        return self.rawValue
    }
    
    public func networkExtensionValue() -> NEVPNIKEv2EncryptionAlgorithm {
        switch self {
            case .algorithmAES128: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES128
            case .algorithmAES128GCM: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES128GCM
            case .algorithmAES256: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES256
            case .algorithmAES256GCM: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
        }
    }
    
    public func integrityAlgorithms() -> [IKEv2IntegrityAlgorithm] {
            switch self {
            #if os(iOS)
            case .algorithmAES128: return [.SHA96, .SHA256, .SHA384, .SHA512]
            case .algorithmAES256: return [.SHA96, .SHA256, .SHA384, .SHA512]
            case .algorithmAES128GCM: return [.SHA96, .SHA160, .SHA256]
            case .algorithmAES256GCM: return [.SHA96, .SHA160, .SHA256]
            #elseif os(tvOS)
            case .algorithmAES128: return [.SHA256, .SHA384, .SHA512]
            case .algorithmAES256: return [.SHA256, .SHA384, .SHA512]
            case .algorithmAES128GCM: return [.SHA256]
            case .algorithmAES256GCM: return [.SHA256]
            #endif
        }
    }
    
    public static func allValues() -> [IKEv2EncryptionAlgorithm] {
        return [.algorithmAES128,
            .algorithmAES256,
            .algorithmAES128GCM,
            .algorithmAES256GCM
        ]
    }
}

