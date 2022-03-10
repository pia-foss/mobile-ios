//
//  UserSurveyManager.swift
//  PIA VPN
//
//  Created by Waleed Mahmood on 11.02.22.
//  Copyright © 2022 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class UserSurveyManager {
    static let shared = UserSurveyManager()
    
    private init() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setupConnectionCounters), name: .PIAAccountDidRefresh, object: nil)
        
        setupConnectionCounters()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func setupConnectionCounters() {
        let appPreferences = AppPreferences.shared
        if let _ = appPreferences.successConnectionsUntilSurvey {
            return
        }
        appPreferences.successConnectionsUntilSurvey = appPreferences.successConnections + AppConstants.Survey.numberOfConnectionsUntilPrompt
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
