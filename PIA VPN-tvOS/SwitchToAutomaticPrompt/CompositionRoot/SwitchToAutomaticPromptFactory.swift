//
//  SwitchToAutomaticPromptFactory.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation

enum SwitchToAutomaticPromptFactory {
    @MainActor
    static var makePromptViewModel: SwitchToAutomaticPromptViewModel = {
        SwitchToAutomaticPromptViewModel(protocolSelection: SettingsFactory.makeProtocolSelectionUseCase())
    }()
}
