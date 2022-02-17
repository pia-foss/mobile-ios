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
        if UserSurveyManager.shouldShowSurveyMessage() {
            MessagesManager.shared.showInAppSurveyMessage()
        }
    }
    
    // MARK: Survey Settings
    static func shouldShowSurveyMessage() -> Bool {
        let appPreferences = AppPreferences.shared
        guard let successConnectionUntilSurvey = appPreferences.successConnectionsUntilSurvey else {
            return false
        }
        return !appPreferences.userInteractedWithSurvey && appPreferences.successConnections >= successConnectionUntilSurvey
    }
}
