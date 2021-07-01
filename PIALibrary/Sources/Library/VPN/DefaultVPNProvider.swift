//
//  DefaultVPNProvider.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/13/17.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import __PIALibraryNative
import NetworkExtension

class DefaultVPNProvider: VPNProvider, ConfigurationAccess, DatabaseAccess, PreferencesAccess, ProvidersAccess, WebServicesAccess {
    
    private static let forcedStatuses: [VPNStatus] = [
        .connected,
        .connecting
    ]
    
    private static let legacyProtocols: [String] = [
        IPSecProfile.vpnType
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
        return accessedDatabase.plain.publicIP
    }
    
    var vpnIP: String? {
        return accessedDatabase.transient.vpnIP
    }
    
    var vpnLog: String {
        return accessedDatabase.transient.vpnLog
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
        
        var profile = activeProfileRemovingInactive()
        var force = false
        
        let completionBlock = { [weak self] in
            profile?.prepare()

            #if os(iOS)
            if let _ = VPNIPAddressFromInterfaces() {
                self?.accessedDatabase.transient.vpnStatus = .connected
            }
            #endif
            self?.activeProfile = profile
            
        }
        
        if isLegacyProfile() {
            
            profile = IKEv2Profile()
            //Set IKEv2 as default if user was using IKEv1
            let preferences = Client.preferences.editable()
            preferences.vpnType = IKEv2Profile.vpnType
            preferences.commit()

            completionBlock()
            force = accessedDatabase.transient.vpnStatus == .connected

        } else {
            
            // should never happen, IKEv2 is always available
            guard let _ = profile else {
                fatalError("VPN protocol \(accessedPreferences.vpnType) is not available, please set accessedPreferences.vpnType to one of the following: \(availableVPNTypes)")
            }
            
            completionBlock()
            
        }
        
        if self.accessedProviders.accountProvider.isLoggedIn {
            self.install(force: force, nil)
        }


    }
    
    func install(force forceInstall: Bool, _ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        let newVPNType = accessedPreferences.vpnType
        guard let profile = accessedConfiguration.profile(forVPNType: newVPNType) else {
            preconditionFailure()
        }

        var previousProfile: VPNProfile?
        if (newVPNType != activeProfile?.vpnType) {
            previousProfile = activeProfile
        }

        let forcedStatuses = DefaultVPNProvider.forcedStatuses.contains(accessedDatabase.transient.vpnStatus)
        let installBlock: SuccessLibraryCallback = { (error) in
            profile.save(withConfiguration: self.vpnClientConfiguration(for: profile), force: forcedStatuses) { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                self.activeProfile = profile

                if let previousProfile = previousProfile,
                    !((profile.vpnType == IPSecProfile.vpnType || profile.vpnType == IKEv2Profile.vpnType) &&
                    (previousProfile.vpnType == IPSecProfile.vpnType || previousProfile.vpnType == IKEv2Profile.vpnType)) {
                    //only remove the profile if is not Ipsec or IKEv2, if are one of them, override instead
                    previousProfile.remove({ _ in
                        Macros.postNotification(.PIAVPNDidInstall)
                        callback?(nil)
                    })
                } else {
                    if let previousProfile = previousProfile { // dont connect after install
                        self.connect(nil)
                    }
                    Macros.postNotification(.PIAVPNDidInstall)
                    callback?(nil)
                }
            }
        }

        if let previousProfile = previousProfile {
            previousProfile.disconnect(installBlock)
        } else {
            if newVPNType != activeProfile?.vpnType || !forcedStatuses || forceInstall {
                //only install if new and connected
                if Client.providers.vpnProvider.vpnStatus == .connected || forceInstall {
                    installBlock(nil)
                }
            }
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
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.connect(withConfiguration: vpnClientConfiguration(), callback)
    }
    
    func disconnect(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        
        let configuration = vpnClientConfiguration()
        activeProfile.requestLog(withCustomConfiguration: configuration.customConfiguration) { (content, error) in
            var log = self.accessedDatabase.transient.vpnLog + "\n\n" + (content ?? "Unknown Protocol Logs \(error.debugDescription)")
            self.accessedDatabase.transient.vpnLog = log
            activeProfile.disconnect(callback)
        }
        
    }
    
    func updatePreferences(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        activeProfile.updatePreferences(callback)
    }

    func reconnect(after delay: Int?, forceDisconnect: Bool = false,  _ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        let fallbackDelay = delay ?? accessedConfiguration.vpnReconnectionDelay
        
        if activeProfile.vpnType != IKEv2Profile.vpnType {
            activeProfile.disconnect { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                activeProfile.connect(withConfiguration: self.vpnClientConfiguration(), callback)
            }
        } else {
            activeProfile.updatePreferences { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                activeProfile.connect(withConfiguration: self.vpnClientConfiguration(), callback)
            }
        }
    }
    
    func submitDebugReport(_ shouldSendPersistedData: Bool, _ callback: LibraryCallback<String>?) {
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        
        if vpnStatus == .disconnected {
            self.webServices.submitDebugReport(shouldSendPersistedData, vpnLog ?? "Unknown", callback)
        } else {
            let configuration = vpnClientConfiguration()
            activeProfile.requestLog(withCustomConfiguration: configuration.customConfiguration) { (content, error) in
                let rawContent = self.accessedDatabase.transient.vpnLog + "\n\n" + (content ?? "Unknown Protocol Logs \(error.debugDescription)")
                self.webServices.submitDebugReport(shouldSendPersistedData, rawContent, callback)
            }
        }
    }
    
    func dataUsage(_ callback: LibraryCallback<Usage>?) {
        guard let activeProfile = activeProfile else {
            preconditionFailure()
        }
        let configuration = vpnClientConfiguration()
        activeProfile.requestDataUsage(withCustomConfiguration: configuration.customConfiguration) { (usage, error) in
            guard let usage = usage else {
                callback?(nil, error)
                return
            }
            callback?(usage, nil)
        }
    }
    
    private func isLegacyProfile() -> Bool {
        return DefaultVPNProvider.legacyProtocols.contains(accessedPreferences.vpnType)
    }
    
    @discardableResult private func activeProfileRemovingInactive() -> VPNProfile? {
        let activeVPNType = accessedPreferences.vpnType
        let activeProfile: VPNProfile? = accessedConfiguration.profile(forVPNType: activeVPNType)
        
        for vpnType in availableVPNTypes {
            let profile = accessedConfiguration.profile(forVPNType: vpnType)!
            guard (vpnType == activeVPNType) else {
                if let activeProfile = activeProfile {
                    if !((profile.vpnType == IPSecProfile.vpnType || profile.vpnType == IKEv2Profile.vpnType) &&
                        (activeProfile.vpnType == IPSecProfile.vpnType || activeProfile.vpnType == IKEv2Profile.vpnType)) {
                        //only remove the profile if is not Ipsec or IKEv2, if are one of them, override instead
                        profile.disconnect(nil)
                        profile.remove(nil)
                    }
                }
                continue
            }
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
    
    // MARK: Migration
    func needsMigrationToGEN4() -> Bool {
        if isVPNConnected {
            let manager = NEVPNManager.shared()
            if let protocolConfiguration = manager.protocolConfiguration,
               let address = protocolConfiguration.serverAddress,
               address.contains("privateinternetaccess.com") {
                return true
            }
        }
        return false
    }
}
