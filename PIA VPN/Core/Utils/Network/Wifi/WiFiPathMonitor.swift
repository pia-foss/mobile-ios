//
//  WiFiPathMonitor.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Network
import PIALibrary

/// Tracks whether the current network path goes over Wi-Fi, without needing the SSID.
/// Used by `TrustedNetworkUtils` where the SSID is unreadable, like on Mac Catalyst.
final class WiFiPathMonitor: Sendable {

    static let shared = WiFiPathMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "WiFiPathMonitor")
    private let onWiFi = Mutex(false)

    /// `false` until the first path update arrives after `start()`.
    var isOnWiFi: Bool {
        onWiFi.withLock { $0 }
    }

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.onWiFi.withLock {
                $0 = path.status == .satisfied && path.usesInterfaceType(.wifi)
            }
        }
        monitor.start(queue: queue)
    }
}
