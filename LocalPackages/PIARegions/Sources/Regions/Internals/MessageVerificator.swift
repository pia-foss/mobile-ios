/*
 *  Copyright (c) 2020 Private Internet Access, Inc.
 *
 *  This file is part of the Private Internet Access Mobile Client.
 *
 *  The Private Internet Access Mobile Client is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as published by the Free
 *  Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  The Private Internet Access Mobile Client is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along with the Private
 *  Internet Access Mobile Client.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation
import Security

internal enum MessageVerificator {

    static func verifyMessage(_ message: String, key: String) -> Bool {
        // Strip PEM headers and decode the public key
        let strippedKey = Regions.publicKey
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")

        guard let publicKeyData = Data(base64Encoded: strippedKey, options: .ignoreUnknownCharacters) else {
            return false
        }

        // Decode the signature
        guard let signatureData = Data(base64Encoded: key, options: .ignoreUnknownCharacters) else {
            return false
        }

        // Create the SecKey from public key data (RSA, public)
        let keyAttributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: 2048
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(publicKeyData as CFData, keyAttributes as CFDictionary, &error) else {
            return false
        }

        // Verify RSA PKCS1 SHA256 signature over the message
        // SecKeyVerifySignature with rsaSignatureMessagePKCS1v15SHA256 handles the SHA256 hash internally
        guard let messageData = message.data(using: .utf8) else {
            return false
        }

        var verifyError: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(
            secKey,
            .rsaSignatureMessagePKCS1v15SHA256,
            messageData as CFData,
            signatureData as CFData,
            &verifyError
        )
        return result
    }
}
