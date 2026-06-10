//
//  Pinger.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 29/12/25.
//  Copyright © 2025 Private Internet Access, Inc.
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
import Network

protocol Pinger {
    func ping(ip: String, port: UInt16, timeout: TimeInterval) async -> Int?
}

final class TCPPinger: Pinger {
    private let queue = DispatchQueue(label: "com.privateinternetaccess.AsyncTCPPinger", qos: .utility)

    private init() {}
    static let shared = TCPPinger()

    /// Measures the TCP connect time to `ip:port` in milliseconds.
    /// Returns nil on failure, timeout or task cancellation. Never blocks a cooperative thread.
    func ping(ip: String, port: UInt16, timeout: TimeInterval) async -> Int? {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            return nil
        }
        let connection = NWConnection(host: NWEndpoint.Host(ip), port: nwPort, using: .tcp)
        let start = Date.timeIntervalSinceReferenceDate

        return await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Int?, Never>) in
                let resumeOnce = ResumeOnce(continuation)

                connection.stateUpdateHandler = { state in
                    switch state {
                    case .setup, .preparing, .waiting:
                        break
                    case .ready:
                        resumeOnce.resume(with: Int((Date.timeIntervalSinceReferenceDate - start) * 1000.0))
                        connection.cancel()
                    case .failed, .cancelled:
                        resumeOnce.resume(with: nil)

                    @unknown default:
                        break
                    }
                }
                connection.start(queue: queue)

                queue.asyncAfter(deadline: .now() + timeout) {
                    resumeOnce.resume(with: nil)
                    if connection.state != .cancelled {
                        connection.cancel()
                    }
                }
            }
        } onCancel: {
            if connection.state != .cancelled {
                connection.cancel()
            }
        }
    }
}

// The state handler, the deadline and cancellation can all fire; only the first resumes.
private final class ResumeOnce: @unchecked Sendable {
    private var continuation: Mutex<CheckedContinuation<Int?, Never>?>

    init(_ continuation: CheckedContinuation<Int?, Never>) {
        self.continuation = .init(continuation)
    }

    func resume(with value: Int?) {
        continuation.withLock { continuation in
            continuation?.resume(returning: value)
            continuation = nil
        }
    }
}
