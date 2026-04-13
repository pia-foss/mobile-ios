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

internal enum RegionHttpClient {

    static let requestTimeoutSeconds: TimeInterval = 6.0

    static func client(
        certificate: String? = nil,
        pinnedEndpoint: (hostname: String, commonName: String)? = nil
    ) -> (URLSession?, Error?) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = requestTimeoutSeconds

        if let cert = certificate, let pinned = pinnedEndpoint {
            let pinner = RegionCertificatePinner(
                certificate: cert,
                hostname: pinned.hostname,
                commonName: pinned.commonName
            )
            let session = URLSession(configuration: config, delegate: pinner, delegateQueue: nil)
            return (session, nil)
        }

        return (URLSession(configuration: config), nil)
    }
}

private final class RegionCertificatePinner: NSObject, URLSessionDelegate, Sendable {

    private let certificateData: Data?
    private let hostname: String
    private let commonName: String

    init(certificate: String, hostname: String, commonName: String) {
        self.hostname = hostname
        self.commonName = commonName

        let stripped =
            certificate
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        self.certificateData = Data(base64Encoded: stripped, options: .ignoreUnknownCharacters)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust,
            let certificateData
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Validate hostname
        let hostNameEvaluationSucceeded = (hostname == challenge.protectionSpace.host)

        // Get server certificate and validate CN
        guard let certChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
            let serverCertificate = certChain.first
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var serverCommonName: CFString?
        SecCertificateCopyCommonName(serverCertificate, &serverCommonName)
        let commonNameEvaluationSucceeded = (commonName == (serverCommonName as String?))

        // Create pinned certificate reference
        guard let pinnedCertificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Create trust for evaluation using the server certificate
        let policy = SecPolicyCreateSSL(true, nil)
        var trust: SecTrust?
        let trustCreation = SecTrustCreateWithCertificates(serverCertificate, policy, &trust)
        guard trustCreation == errSecSuccess, let trust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Set anchor to our pinned certificate
        let anchorCertificates = [pinnedCertificate] as CFArray
        let trustAnchor = SecTrustSetAnchorCertificates(trust, anchorCertificates)
        guard trustAnchor == errSecSuccess else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluate trust
        var cfError: CFError?
        let certificateEvaluationSucceeded = SecTrustEvaluateWithError(trust, &cfError)

        let credential = URLCredential(trust: serverTrust)
        if hostNameEvaluationSucceeded && commonNameEvaluationSucceeded && certificateEvaluationSucceeded {
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
