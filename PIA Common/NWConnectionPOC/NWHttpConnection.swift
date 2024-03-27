//
//  NWHttpConnection.swift
//  PIA VPN
//
//  Created by Laura S on 3/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Network
import CommonCrypto

protocol NWHttpConnectionType {
    func connect(requestHandler: NWHttpConnection.RequestHandler?, completion: NWHttpConnection.Completion?) throws
}

struct NWHttpConnection: NWHttpConnectionType {
    typealias RequestHandler = (NWHttpConnectionError?, Data?) -> Void
    typealias Completion = () -> Void
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    let url: URL
    let method: HTTPMethod
    let certificateValidation: CertificateValidation
    let timeout: TimeInterval
    let queue: DispatchQueue
    
    private static let defaultQueue = DispatchQueue(label: "com.pia.nwhttpconnection", qos: .userInitiated)
    private static let deadlineTimerQueue = DispatchQueue(label: "com.pia.deadline", qos: .background)
    private let requiredHeaders = [
        "User-Agent": "generic/1.0",
        "Accept": "*/*",
        "Connection": "close"
    ]
    private let httpsPort: UInt16 = 443
    
    init(url: URL, method: HTTPMethod, certificateValidation: CertificateValidation, timeout: TimeInterval = 30, queue: DispatchQueue? = nil) {
        self.url = url
        self.method = method
        self.certificateValidation = certificateValidation
        self.timeout = timeout
        self.queue = queue ?? Self.defaultQueue
    }
    
    
    func connect(requestHandler: RequestHandler? = nil, completion: Completion? = nil) throws {
        let (validatedHost, scheme) = try validate(url: url)
        let host = NWEndpoint.Host(validatedHost)
        let port = NWEndpoint.Port(integerLiteral: httpsPort)

        let tcp = NWProtocolTCP.Options()
        tcp.connectionTimeout = try validate(timeout: timeout)

        let tls = NWProtocolTLS.Options()
        sec_protocol_options_set_verify_block(
            tls.securityProtocolOptions, { (metadata, trust, complete) in
                certificateValidation.validate(metadata: metadata,
                                               trust: trust,
                                               complete: complete)
            },
            queue
        )

        let params = NWParameters(tls: tls, tcp: tcp)
        

        let connection = NWConnection(host: host, port: port, using: params)
        let timer = deadline(connection: connection, complete: completion)

        receive(connection: connection,
                timer: timer,
                handle: requestHandler)

        connection.stateUpdateHandler = { (state) in
            self.updated(connection: connection,
                         state: state,
                         timer: timer,
                         handle: requestHandler,
                         complete: completion)
        }
        connection.start(queue: queue)
    }
    
    
}


// MARK: - Private

private extension NWHttpConnection {
    
    func normalize(headers: [String: String]?) -> [String: String] {
        var normalized = requiredHeaders
        if let headers = headers {
            normalized = normalized.merging(headers) { _, value in value }
        }
        return normalized
    }
    
    private func validate(url: URL) throws -> (host: String, scheme: String) {
        guard let scheme = url.scheme,
              let host = url.host else {
            throw NWHttpConnectionError.badURL(url)
        }
        return (host, scheme)
    }
    
    func validate(timeout: TimeInterval) throws -> Int {
        guard timeout >= 0 else { throw NWHttpConnectionError.negitiveTimeout}
        if timeout >= Double(Int.max) { throw NWHttpConnectionError.timeoutOutOfBounds }
        return Int(timeout)
    }
    
    func send(connection: NWConnectionType,
              timer: DispatchSourceTimer,
              handle: RequestHandler?) {
        guard let validated = try? validate(url: url) else { return }
        let path = url.path.isEmpty ? "/" : url.path
        let query = url.query?.isEmpty ?? true ? "" : "?\(url.query!)"
        let headers = normalize(headers: nil)
        let content =
        "\(method.rawValue) \(path)\(query) HTTP/1.1\r\n" +
        "Host: \(validated.host)\r\n" +
            headers.map { "\($0.key): \($0.value)\r\n" }.joined() +
            "\r\n"
        
        connection.send(
            content: content.data(using: .ascii),
            contentContext: .defaultMessage,
            isComplete: true,
            completion: NWConnection.SendCompletion.contentProcessed(
                { (error) in
                    if let error = error {
                        handle?(.send(error), nil)
                        connection.cancel()
                    }
                }
            )
        )
    }

    func receive(connection: NWConnectionType,
                 timer: DispatchSourceTimer,
                 handle: RequestHandler?) {
        connection.receive(
            minimumIncompleteLength: 1,
            maximumLength: Int(UInt16.max),
            completion: { (data, _, isComplete, error) in
                if let data = data {
                    handle?(nil, data)
                }
                if isComplete {
                    connection.cancel()
                } else if let error = error {
                    handle?(.receive(error), nil)
                } else {
                    self.receive(connection: connection,
                                 timer: timer,
                                 handle: handle)
                }
            }
        )
    }

    func updated(connection: NWConnectionType,
                 state: NWConnection.State,
                 timer: DispatchSourceTimer,
                 handle: RequestHandler?,
                 complete: Completion?) {
        switch state {
        case .cancelled:
            timer.cancel()
            complete?()
        case .failed(let error):
            handle?(.connection(error), nil)
            connection.cancel()
        case .preparing:
            break
        case .ready:
            send(connection: connection, timer: timer, handle: handle)
        case .setup:
            break
        case .waiting(let error):
            handle?(.wait(error), nil)
            connection.cancel()
        default:
            break
        }
    }

    func deadline(connection: NWConnectionType,
                  complete: Completion?) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: Self.deadlineTimerQueue)
        timer.schedule(deadline: .now() + timeout)
        timer.setEventHandler {
            connection.cancel()
        }
        timer.resume()
        return timer
    }
        
}


protocol NWConnectionType {
    var stateUpdateHandler: ((NWConnection.State) -> Void)? { get set }
    func start(queue: DispatchQueue)
    func send(content: Data?,
              contentContext: NWConnection.ContentContext,
              isComplete: Bool,
              completion: NWConnection.SendCompletion)
    func receive(
        minimumIncompleteLength: Int,
        maximumLength: Int,
        completion: @escaping (
            Data?,
            NWConnection.ContentContext?,
            Bool,
            NWError?
        ) -> Void
    )
    func cancel()
    init(host: NWEndpoint.Host, port: NWEndpoint.Port, using: NWParameters)
}

extension NWConnection: NWConnectionType { }

enum NWHttpConnectionError: Error {
    case badURL(URL)
    case connection(NWError)
    case negitiveTimeout
    case timeoutOutOfBounds
    case receive(NWError?)
    case send(NWError)
    case wait(NWError)
    case unknown(Error)
}



