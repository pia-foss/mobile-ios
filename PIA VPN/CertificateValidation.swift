//
//  CertificateValidation.swift
//  PIA VPN
//
//  Created by Laura S on 3/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import CommonCrypto
import CryptoKit

struct PublicKeyHeader {
    /// ASN1 header for our public key to re-create the subject public key info
    static let rsa4096Asn1Header: [UInt8] = [
      0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
      0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00,
    ]
}

enum CertificateValidation {
    case pubKey
    
    /// PIA Public Key Hash
    static let trustedPublicKeyHashes = ["ZAs7C2OqZKde1JddKApDrhFM+V86LVQZ1Et4EfQdPJo="]
}

extension CertificateValidation {
    
    func validate(metadata: sec_protocol_metadata_t, trust: sec_trust_t, complete: @escaping sec_protocol_verify_complete_t) {
        switch self {
        case .pubKey:
            let serverPublicKeys = getPublicKeyHashes(from: trust)
            var evaluatedKeys = [String]()
            for key in serverPublicKeys {
                if CertificateValidation.trustedPublicKeyHashes.contains(key) {
                    evaluatedKeys.append(key)
                }
            }
            
            complete(!evaluatedKeys.isEmpty)
        }
    }
    
    
    private func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    private func hash(data: Data) -> String {
      // Add the missing ASN1 header for public keys to re-create the subject public key info
        var keyWithHeader = Data(PublicKeyHeader.rsa4096Asn1Header)
      keyWithHeader.append(data)

      return Data(SHA256.hash(data: keyWithHeader)).base64EncodedString()
    }

    private func getPublicKeyHashes(from trust: sec_trust_t) -> [String] {
        let trust = sec_trust_copy_ref(trust).takeRetainedValue()
        let count = SecTrustGetCertificateCount(trust)

        var result = [String]()
        for index in 0..<count {
            guard let cert = SecTrustGetCertificateAtIndex(trust, index) else {
                continue
            }
            
            if let publicKey = SecCertificateCopyKey(cert),
               let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) {
                let pubKeyHash = hash(data: (publicKeyData as NSData) as Data)
                result.append(pubKeyHash)
            }
            
        }
        
        return result
    }
    
}


