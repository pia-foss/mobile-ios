//
//  HelpOptionsViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/26/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation

class HelpOptionsViewModel: ObservableObject {
    enum Sections: Equatable, Identifiable {
        case appInfo
        case about
        case helpImprove
        
        var id: Self {
            return self
        }
        
        var title: String {
            switch self {
            case .appInfo:
                L10n.Localizable.HelpMenu.AppVersionSection.title
            case .about:
                L10n.Localizable.Menu.Item.about
            case .helpImprove:
                L10n.Localizable.Settings.Service.Quality.Share.title
            }
        }
    }
    
    private var infoDictionary: [String: Any]?
    private let connectionStatsPermission: ConnectionStatsPermissonType
    private let aboutOptionNavigationAction: AppRouter.Actions
    @Published private(set) var helpImproveValue: Bool = false
    
    init(connectionStatsPermission: ConnectionStatsPermissonType,
         aboutOptionNavigationAction: AppRouter.Actions,
         infoDictionary: [String : Any]?) {
        self.connectionStatsPermission = connectionStatsPermission
        self.aboutOptionNavigationAction = aboutOptionNavigationAction
        self.infoDictionary = infoDictionary
        self.helpImproveValue = connectionStatsPermission.get() ?? false
    }
    
    var appInfoContent: (title: String, value: String) {
        let title = Sections.appInfo.title
        let value = appInfoValue
        return (title: title, value: value)
        
    }
    
    private var appInfoValue: String {
        guard let infoDictionary,
              let versionNumber = infoDictionary[.cfBundleShortVersionString] as? String,
              let buildNumber = infoDictionary[kCFBundleVersionKey as String] as? String else {
            return ""
        }
        return "\(versionNumber) (\(buildNumber))"
    }
    
    var aboutSectionTitle: String {
        Sections.about.title
    }
    
    var helpImproveSectionContent: (title: String, subtitle: String, value: String) {
        let title = Sections.helpImprove.title
        let subtitle = L10n.Localizable.Settings.Service.Quality.Share.description
        let value = helpImproveValue ? L10n.Localizable.HelpMenu.HelpImprove.Enabled.title : L10n.Localizable.HelpMenu.HelpImprove.Disabled.title
        
        return (title: title, subtitle: subtitle, value: value)
    }
    
    var contactSupportTitle: String {
        L10n.Localizable.HelpMenu.ContactSupport.QrCode.title
    }
    
    var contactSupportDescription: String {
        L10n.Localizable.HelpMenu.ContactSupport.QrCode.message
    }
    
    var contactSupportURL: URL {
        URL(string: "https://helpdesk.privateinternetaccess.com")!
    }
    
    func toggleHelpImprove() {
        helpImproveValue.toggle()
        connectionStatsPermission.set(value: helpImproveValue)
    }
    
    func aboutOptionsButtonWasTapped() {
        aboutOptionNavigationAction()
    }
    
}

fileprivate extension String {
    static let cfBundleShortVersionString = "CFBundleShortVersionString"
}
