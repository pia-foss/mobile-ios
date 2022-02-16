//
//  UserSurveyManager.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 11.02.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation

class UserSurveyManager {
    static let shared = UserSurveyManager()
    
    private init() {
        
    }
    
    func handleConnectionSuccess() {
        if shouldShowSurveryMessage() {
            MessagesManager.shared.showInAppSurveyMessage()
        }
    }
    
    // MARK: Survey Settings
    private func shouldShowSurveryMessage() -> Bool {
        return AppPreferences.shared.successConnections == AppConstants.Survey.numberOfConnectionsUntilPrompt
    }
}
