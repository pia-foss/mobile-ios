import Foundation

struct KPIHttpRequestConfig: Sendable {
    let logLevel: KPIHttpLogLevel
    let userAgent: String?
    let certificate: String?
    let pinnedEndpoint: (host: String, commonName: String)?
    let requestTimeoutMs: Int64
}

struct KPIHttpResponse: Sendable {
    let statusCode: Int
    let description: String
    let data: Data
}

enum KPIHttpError: Error, CustomStringConvertible {
    case transport(Error)
    case missingResponse

    var description: String {
        switch self {
        case .transport(let error): return (error as NSError).localizedDescription
        case .missingResponse: return "Missing HTTP response"
        }
    }
}

struct KPIHttpClient: Sendable {
    static func post(
        urlString: String,
        body: Data,
        headers: [String: String],
        config: KPIHttpRequestConfig
    ) async -> (KPIHttpResponse?, Error?) {
        guard let url = URL(string: urlString) else {
            return (nil, KPIError(description: "Invalid URL: \(urlString)"))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        if let userAgent = config.userAgent?.trimmingCharacters(in: .whitespacesAndNewlines), !userAgent.isEmpty {
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = TimeInterval(config.requestTimeoutMs) / 1000.0
        sessionConfig.timeoutIntervalForResource = TimeInterval(config.requestTimeoutMs) / 1000.0

        let delegate: KPIURLSessionDelegate?
        if let certificate = config.certificate, let pinnedEndpoint = config.pinnedEndpoint {
            delegate = KPIURLSessionDelegate(
                certificate: certificate,
                hostname: pinnedEndpoint.host,
                commonName: pinnedEndpoint.commonName
            )
        } else {
            delegate = nil
        }

        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        defer { session.invalidateAndCancel() }

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return (nil, KPIHttpError.missingResponse)
            }
            return (
                KPIHttpResponse(
                    statusCode: http.statusCode,
                    description: HTTPURLResponse.localizedString(forStatusCode: http.statusCode),
                    data: data
                ), nil
            )
        } catch {
            return (nil, KPIHttpError.transport(error))
        }
    }
}

// `@unchecked Sendable`: required because URLSessionDelegate forces NSObject
// inheritance and NSObject is not Sendable. All stored properties are immutable
// `let`s of Sendable types, the class is `final`, and the delegate is never
// shared across URLSessions — so the unchecked promise is honest.
final class KPIURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, @unchecked Sendable {
    private let certificateData: Data?
    private let hostname: String
    private let commonName: String

    init(certificate: String, hostname: String, commonName: String) {
        let cleaned =
            certificate
            .replacingOccurrences(of: "-----BEGIN CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "-----END CERTIFICATE-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        self.certificateData = Data(base64Encoded: cleaned, options: [.ignoreUnknownCharacters])
        self.hostname = hostname
        self.commonName = commonName
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        handleChallenge(challenge, completionHandler: completionHandler)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        handleChallenge(challenge, completionHandler: completionHandler)
    }

    private func handleChallenge(
        _ challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            challenge.sender?.cancel(challenge)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let certificateData,
            let pinnedCertificate = SecCertificateCreateWithData(nil, certificateData as CFData),
            let serverCertificate = serverCertificateAtIndex(serverTrust, index: 0)
        else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        var preparationSucceeded = true

        var serverCommonNameCF: CFString?
        SecCertificateCopyCommonName(serverCertificate, &serverCommonNameCF)
        let serverCommonName = serverCommonNameCF as String?
        let commonNameEvaluationSucceeded = (commonName == serverCommonName)
        let hostNameEvaluationSucceeded = (hostname == challenge.protectionSpace.host)

        let policy = SecPolicyCreateSSL(true, nil)
        var trust: SecTrust?
        let trustCreation = SecTrustCreateWithCertificates(serverCertificate, policy, &trust)
        if trustCreation != errSecSuccess {
            preparationSucceeded = false
        }

        if let trust {
            let anchors = [pinnedCertificate] as CFArray
            if SecTrustSetAnchorCertificates(trust, anchors) != errSecSuccess {
                preparationSucceeded = false
            }

            var trustError: CFError?
            let certificateEvaluationSucceeded = SecTrustEvaluateWithError(trust, &trustError)

            if preparationSucceeded
                && hostNameEvaluationSucceeded
                && commonNameEvaluationSucceeded
                && certificateEvaluationSucceeded
            {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func serverCertificateAtIndex(_ trust: SecTrust, index: Int) -> SecCertificate? {
        if #available(iOS 15.0, tvOS 15.0, macOS 12.0, *) {
            guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
                chain.indices.contains(index)
            else {
                return nil
            }
            return chain[index]
        } else {
            return SecTrustGetCertificateAtIndex(trust, index)
        }
    }
}
