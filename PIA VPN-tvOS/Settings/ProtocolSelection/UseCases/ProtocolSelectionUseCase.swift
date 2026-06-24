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

private let log = PIALogger.logger(for: ProtocolSelectionUseCase.self)

/// VPN protocols selectable on tvOS. Both run through the PlatformSDK tunnel; the raw value is the
/// `Client.preferences.vpnType` the tunnel reads (`KapePlatformSDKTunnelProfile.desiredTunnelProtocol`)
/// to decide which protocol to run. The literals mirror `PIAWGTunnelProfile`/`PIATunnelProfile`,
/// which are iOS-only and not linkable on tvOS.
enum TvOSVPNProtocol: String, CaseIterable, Identifiable, Hashable {
    case wireGuard = "PIAWG"
    case openVPN = "PIA"

    var id: String { rawValue }

    /// Brand names — intentionally not localized.
    var title: String {
        switch self {
        case .wireGuard: return "WireGuard"
        case .openVPN: return "OpenVPN"
        }
    }
}

protocol ProtocolSelectionUseCaseType {
    var availableProtocols: [TvOSVPNProtocol] { get }
    func selectedProtocol() -> TvOSVPNProtocol
    func select(_ vpnProtocol: TvOSVPNProtocol)
}

final class ProtocolSelectionUseCase: ProtocolSelectionUseCaseType {

    let availableProtocols: [TvOSVPNProtocol] = TvOSVPNProtocol.allCases

    private let vpnConnectionUseCase: VpnConnectionUseCaseType
    private var currentStatus: VPNStatus = .unknown
    private var cancellables = Set<AnyCancellable>()

    init(vpnConnectionUseCase: VpnConnectionUseCaseType, vpnStatusMonitor: VPNStatusMonitorType) {
        self.vpnConnectionUseCase = vpnConnectionUseCase
        vpnStatusMonitor.getStatus()
            .sink { [weak self] in self?.currentStatus = $0 }
            .store(in: &cancellables)
    }

    func selectedProtocol() -> TvOSVPNProtocol {
        TvOSVPNProtocol(rawValue: Client.preferences.vpnType) ?? .wireGuard
    }

    func select(_ vpnProtocol: TvOSVPNProtocol) {
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
