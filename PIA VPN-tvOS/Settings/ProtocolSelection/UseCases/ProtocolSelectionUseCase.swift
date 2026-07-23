//
//  ProtocolSelectionUseCase.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIADashboard
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: ProtocolSelectionUseCase.self)

@MainActor
protocol ProtocolSelectionUseCaseType {
    var availableProtocols: [KapePlatformSDKVPNType] { get }
    func selectedProtocol() -> KapePlatformSDKVPNType
    func select(_ vpnProtocol: KapePlatformSDKVPNType)
}

@MainActor
final class ProtocolSelectionUseCase: ProtocolSelectionUseCaseType {

    let availableProtocols: [KapePlatformSDKVPNType] = [.automatic, .wireGuard, .openVPN]

    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    private var currentStatus: VPNStatus = .unknown
    private var cancellables = Set<AnyCancellable>()

    init(vpnConnectionUseCase: VpnConnectionUseCaseType, vpnStatusMonitor: VPNStatusMonitorType) {
        self.vpnConnectionUseCase = vpnConnectionUseCase
        vpnStatusMonitor.getStatus()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.currentStatus = $0 }
            .store(in: &cancellables)
    }

    func selectedProtocol() -> KapePlatformSDKVPNType {
        // `KapePlatformSDKVPNType(rawValue:)` also decodes the non-selectable "IKEv2" value, so map
        // anything outside the tvOS-selectable set (including a stored IKEv2 or an unknown value)
        // back to `.automatic` — the PlatformSDK default (this screen is only shown when the
        // PlatformSDK tunnel is enabled), matching the bootstrap default `vpnType`.
        let stored = KapePlatformSDKVPNType(rawValue: Client.preferences.vpnType)
        guard let stored, availableProtocols.contains(stored) else {
            return .automatic
        }
        return stored
    }

    func select(_ vpnProtocol: KapePlatformSDKVPNType) {
        guard vpnProtocol != selectedProtocol() else { return }

        log.info("VPN protocol selected: \(vpnProtocol.rawValue)")
        let editable = Client.preferences.editable()
        editable.vpnType = vpnProtocol.rawValue
        editable.commit()

        // Re-apply the tunnel only when a session is already up, so changing the setting while
        // disconnected does not silently turn the VPN on. The next manual connect picks up the new
        // protocol regardless.
        guard currentStatus == .connected || currentStatus == .connecting else { return }
        Task {
            do {
                try await vpnConnectionUseCase.connect()
            } catch {
                log.error("Reconnection after protocol change failed: \(error)")
            }
        }
    }
}
