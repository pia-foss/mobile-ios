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

    let availableProtocols: [KapePlatformSDKVPNType] = SelectableVPNProtocol.all

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
        SelectableVPNProtocol.resolved(fromStored: Client.preferences.vpnType)
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
