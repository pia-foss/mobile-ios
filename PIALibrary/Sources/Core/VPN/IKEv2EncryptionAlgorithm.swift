//
//  IKEv2EncryptionAlgorithm.swift
//  PIALibrary
//
//  Created by Jose Antonio Blaya Garcia on 10/09/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import Foundation
import NetworkExtension

public enum IKEv2EncryptionAlgorithm: Int, EnumsBuilder {
    
    public static let defaultAlgorithm: Int = 2

    case algorithmDES = 1
    case algorithm3DES
    case algorithmAES128
    case algorithmAES256
    case algorithmAES128GCM
    case algorithmAES256GCM
    case algorithmChaCha20Poly1305
    
    public func description() -> String {
        switch self {
        case .algorithmDES: return "Data Encryption Standard (DES)"
        case .algorithm3DES: return "Triple Data Encryption Algorithm (aka 3DES)"
        case .algorithmAES128: return "Advanced Encryption Standard 128 bit (AES128)"
        case .algorithmAES256: return "Advanced Encryption Standard 256 bit (AES256)"
        case .algorithmAES128GCM: return "Advanced Encryption Standard 128 bit (AES128GCM)"
        case .algorithmAES256GCM: return "Advanced Encryption Standard 256 bit (AES256GCM)"
        case .algorithmChaCha20Poly1305 : return "CHACHA20-POLY1305"
        }
    }
    
    public func networkExtensionValue() -> NEVPNIKEv2EncryptionAlgorithm {
        return NEVPNIKEv2EncryptionAlgorithm(rawValue: self.rawValue) ?? .algorithm3DES
    }
    
}
