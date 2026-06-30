//
//  ProtocolSelectionViewModel.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

@MainActor
class ProtocolSelectionViewModel: ObservableObject {
    @Published private(set) var selectedProtocol: KapePlatformSDKVPNType

    let availableProtocols: [KapePlatformSDKVPNType]

    private let useCase: ProtocolSelectionUseCaseType

    init(useCase: ProtocolSelectionUseCaseType) {
        self.useCase = useCase
        self.availableProtocols = useCase.availableProtocols
        self.selectedProtocol = useCase.selectedProtocol()
    }

    func select(_ vpnProtocol: KapePlatformSDKVPNType) {
        useCase.select(vpnProtocol)
        selectedProtocol = vpnProtocol
    }

    func isSelected(_ vpnProtocol: KapePlatformSDKVPNType) -> Bool {
        vpnProtocol == selectedProtocol
    }
}
