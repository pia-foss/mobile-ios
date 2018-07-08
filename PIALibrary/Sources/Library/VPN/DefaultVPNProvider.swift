//
//  DefaultVPNProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import Foundation
import __PIALibraryNative

class DefaultVPNProvider: VPNProvider, ConfigurationAccess, DatabaseAccess, PreferencesAccess, ProvidersAccess, WebServicesAccess {
    private static let forcedStatuses: [VPNStatus] = [
        .connected,
        .connecting
    ]
    
    private let customWebServices: WebServices?
    
    init(webServices: WebServices? = nil) {
        if let webServices = webServices {
            customWebServices = webServices
        } else {
            customWebServices = nil
        }
    }
    
    // MARK: VPNProvider
    
    var availableVPNTypes: [String] {
        return accessedConfiguration.availableVPNTypes()
    }
    
    var currentVPNType: String {
        return accessedPreferences.vpnType
    }
    
    var vpnStatus: VPNStatus {
        return accessedDatabase.transient.vpnStatus
    }
    
    var profileServer: Server? {
        guard let identifier = activeProfile?.serverIdentifier else {
            return nil
        }
        return accessedProviders.serverProvider.find(withIdentifier: identifier)
    }
    
    var publicIP: String? {
        return accessedDatabase.transient.publicIP
    }
    
    var vpnIP: String? {
        return accessedDatabase.transient.vpnIP
    }
    
    private var activeProfile: VPNProfile? {
        get {
            return accessedDatabase.transient.activeVPNProfile
        }
        set {
            accessedDatabase.transient.activeVPNProfile = newValue
        }
    }
    
    func prepare() {
        let profile = activeProfileRemovingInactive()
        
        // should never happen, IPSec is always available
        guard let _ = profile else {
            fatalError("VPN protocol \(accessedPreferences.vpnType) is not available, please set accessedPreferences.vpnType to one of the following: \(availableVPNTypes)")
        }
        profile?.prepare()

        #if os(iOS)
        if let _ = VPNIPAddressFromInterfaces() {
            accessedDatabase.transient.vpnStatus = .connected
        }
        #endif
        activeProfile = profile
        if accessedProviders.accountProvider.isLoggedIn {
            install(nil)
        }
    }
    
    func install(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        let newVPNType = accessedPreferences.vpnType
        guard let profile = accessedConfiguration.profile(forVPNType: newVPNType) else {
            preconditionFailure()
        }

        var previousProfile: VPNProfile?
        if (newVPNType != activeProfile?.vpnType) {
            previousProfile = activeProfile
        }

        let force = DefaultVPNProvider.forcedStatuses.contains(accessedDatabase.transient.vpnStatus)
        let installBlock: SuccessLibraryCallback = { (error) in
            profile.save(withConfiguration: self.vpnClientConfiguration(for: profile), force: force) { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                previousProfile?.remove(nil)
                self.activeProfile = profile
                Macros.postNotification(.PIAVPNDidInstall)
                callback?(nil)
            }
        }

        if let previousProfile = previousProfile {
            previousProfile.disconnect(installBlock)
        } else {
            installBlock(nil)
        }
    }
    
    func disable(_ callback: SuccessLibraryCallback?) {
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.disconnect(nil)
        activeProfile.disable(callback)
    }
    
    func uninstall(_ callback: SuccessLibraryCallback?) {
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.disconnect(nil)
        activeProfile.remove { (error) in
            self.activeProfile = nil
            self.accessedDatabase.transient.vpnStatus = .disconnected
            callback?(error)
        }
    }
    
    func uninstallAll() {
        activeProfile = nil
        accessedDatabase.transient.vpnStatus = .disconnected
        for vpnType in availableVPNTypes {
            guard let profile = accessedConfiguration.profile(forVPNType: vpnType) else {
                continue
            }
            profile.disconnect(nil)
            profile.remove(nil)
        }
    }
    
    func connect(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.connect(withConfiguration: vpnClientConfiguration(), callback)
    }
    
    func disconnect(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.disconnect(callback)
    }
    
    func reconnect(after delay: Int?, _ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            preconditionFailure()
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        let fallbackDelay = delay ?? accessedConfiguration.vpnReconnectionDelay
        activeProfile.disconnect { (error) in
            if let _ = error {
                callback?(error)
                return
            }
            Macros.dispatch(after: .milliseconds(fallbackDelay)) {
                activeProfile.connect(withConfiguration: self.vpnClientConfiguration(), callback)
            }
        }
    }
    
    func submitLog(_ callback: ((DebugLog?, Error?) -> Void)?) {
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        let configuration = vpnClientConfiguration()
        activeProfile.requestLog(withCustomConfiguration: configuration.customConfiguration) { (content, error) in
            guard let rawContent = content else {
                callback?(nil, error)
                return
            }
            let vpnLog = PlatformVPNLog(rawContent: rawContent)
            guard !vpnLog.isEmpty else {
                callback?(vpnLog, error)
                return
            }
            self.webServices.submitDebugLog(vpnLog) { (error) in
                if let _ = error {
                    callback?(nil, error)
                    return
                }
                callback?(vpnLog, nil)
            }
        }
    }
    
    @discardableResult private func activeProfileRemovingInactive() -> VPNProfile? {
        let activeVPNType = accessedPreferences.vpnType
        var activeProfile: VPNProfile?
        
        for vpnType in availableVPNTypes {
            let profile = accessedConfiguration.profile(forVPNType: vpnType)!
            guard (vpnType == activeVPNType) else {
                profile.disconnect(nil)
                profile.remove(nil)
                continue
            }
            activeProfile = profile
        }
        return activeProfile
    }

    private func vpnClientConfiguration(for profile: VPNProfile? = nil) -> VPNConfiguration {
        guard let currentUser = accessedProviders.accountProvider.currentUser else {
            preconditionFailure("Not logged in")
        }
        guard let currentPasswordReference = accessedProviders.accountProvider.currentPasswordReference else {
            preconditionFailure("Not logged in")
        }
        guard let profile = profile ?? activeProfile else {
            preconditionFailure("Profile not installed")
        }

        let customConfiguration = accessedPreferences.vpnCustomConfiguration(for: profile.vpnType)

        return VPNConfiguration(
            name: accessedConfiguration.vpnProfileName,
            username: currentUser.credentials.username,
            passwordReference: currentPasswordReference,
            server: accessedProviders.serverProvider.targetServer,
            isOnDemand: accessedPreferences.isPersistentConnection,
            disconnectsOnSleep: accessedPreferences.vpnDisconnectsOnSleep,
            customConfiguration: customConfiguration
        )
    }

    // MARK: WebServicesConsumer
    
    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }
}
