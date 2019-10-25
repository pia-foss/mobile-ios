//
//  IKEv2EncryptionAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension

public enum IKEv2EncryptionAlgorithm: String, EnumsBuilder {

    public static let defaultAlgorithm: IKEv2EncryptionAlgorithm = .algorithmAES256GCM
    
    case algorithm3DES = "3DES"
    case algorithmAES128 = "AES-128"
    case algorithmAES256 = "AES-256"
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
            case .algorithm3DES: return NEVPNIKEv2EncryptionAlgorithm.algorithm3DES
            case .algorithmAES128: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES128
            case .algorithmAES256: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES256
            case .algorithmAES128GCM: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES128GCM
            case .algorithmAES256GCM: return NEVPNIKEv2EncryptionAlgorithm.algorithmAES256GCM
        }
    }
    
    public func integrityAlgorithms() -> [IKEv2IntegrityAlgorithm] {
            switch self {
            case .algorithm3DES: return [.SHA96]
            case .algorithmAES128: return [.SHA96, .SHA256, .SHA384, .SHA512]
            case .algorithmAES256: return [.SHA96, .SHA256, .SHA384, .SHA512]
            case .algorithmAES128GCM: return [.SHA96, .SHA160, .SHA256]
            case .algorithmAES256GCM: return [.SHA96, .SHA160, .SHA256]
        }
    }
    
    public static func allValues() -> [IKEv2EncryptionAlgorithm] {
        return [.algorithm3DES,
            .algorithmAES128,
            .algorithmAES256,
            .algorithmAES128GCM,
            .algorithmAES256GCM
        ]
    }
}

