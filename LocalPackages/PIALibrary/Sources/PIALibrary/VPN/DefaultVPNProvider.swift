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
import NetworkExtension

fileprivate let log = PIALogger.logger(for: DefaultVPNProvider.self)

public final class DefaultVPNProvider: VPNProvider, ConfigurationAccess, DatabaseAccess, PreferencesAccess, ProvidersAccess, WebServicesAccess {

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

    public var availableVPNTypes: [String] {
        return accessedConfiguration.availableVPNTypes()
    }

    public var currentVPNType: String {
        return accessedPreferences.vpnType
    }

    public var vpnStatus: VPNStatus {
        return accessedDatabase.transient.vpnStatus
    }

    public var profileServer: Server? {
        if let address = activeProfile?.serverAddress,
            let server = accessedProviders.serverProvider.find(withAddress: address)
        {
            return server
        }
        return nil
    }

    public var connectionDate: Date? { activeProfile?.connectionDate }

    /// What the PlatformSDK tunnel actually resolved this session (written back by the extension):
    /// protocol, server, and transport. Only meaningful while connected through that tunnel;
    /// otherwise `nil` so callers fall back to the user's selection.
    public var actualConnection: ActualConnection? {
        guard let active = activeConnectionFromTunnel else { return nil }
        let vpnType: String?
        switch active.protocol {
        case .wireGuard: vpnType = KapePlatformSDKVPNType.wireGuard.rawValue
        case .openVPN: vpnType = KapePlatformSDKVPNType.openVPN.rawValue
        case .automatic: vpnType = nil  // never written back resolved; ignore
        }
        let server = accessedProviders.serverProvider.find(withIdentifier: active.serverId)
        return ActualConnection(
            vpnType: vpnType,
            server: server,
            transport: active.resolvedTransport
        )
    }

    /// The tunnel's actual-connection write-back, valid only when running through the PlatformSDK
    /// tunnel and currently connected (so a stale value from a previous session is never shown).
    private var activeConnectionFromTunnel: PIATunnelSharedState.ActiveConnection? {
        guard accessedConfiguration.featureFlags[.usePlatformSDKVPN], isVPNConnected else {
            return nil
        }
        return PIATunnelSharedState.read().activeConnection
    }

    private var vpnLog: String {
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

    public func prepare() throws {

        var profile = activeProfileRemovingInactive()
        var force = false

        log.info("prepare: vpnType=\(accessedPreferences.vpnType), resolvedProfile=\(String(describing: profile?.vpnType))")

        // Adding a [weak self] capture to `completionBlock` breaks the code on Xcode 26.4 / Swift 6.3 (self is captured nil)
        // It does not need the weak reference as the it is only called inside the current function
        let completionBlock = {
            profile?.prepare()

            // On launch the tunnel may already be up (the app was terminated while connected), but
            // no NEVPNStatusDidChange fires for an already-stable connection — so the transient
            // status would stay at its `.disconnected` default and the UI would show "Not Connected".
            // Seed it from the live tunnel interface (utun/ppp/ipsec0) instead.
            #if os(iOS) || os(tvOS)
                if let _ = VPNIPAddressFromInterfaces() {
                    self.accessedDatabase.transient.vpnStatus = .connected
                }
            #endif

            self.activeProfile = profile
        }

        // The legacy IKEv1 → IKEv2 (or WireGuard on Mac) migration instantiates an
        // *old* profile and makes it active. Skip it entirely when the PlatformSDK
        // tunnel is enabled so that an IKEv1 user is not silently routed back onto a
        // legacy profile; the resolved PlatformSDK profile is used instead.
        if !accessedConfiguration.featureFlags[.usePlatformSDKVPN], isLegacyProfile() {
            // Set IKEv2 as default if user was using IKEv1.
            profile = IKEv2Profile()
            let preferences = Client.preferences.editable()
            preferences.vpnType = IKEv2Profile.vpnType
            #if os(iOS) || os(macOS)
                // On macOS we avoid IKEv2.
                if Platform.isRunningOnMac {
                    profile = PIAWGTunnelProfile(
                        bundleIdentifier: AppConstants.Extensions.tunnelWireguardBundleIdentifier
                    )
                    preferences.vpnType = PIAWGTunnelProfile.vpnType
                }
            #endif
            preferences.commit()

            completionBlock()
            force = accessedDatabase.transient.vpnStatus == .connected

        } else {

            // should never happen, IKEv2 is always available
            guard profile != nil else {
                log.error("VPN protocol \(accessedPreferences.vpnType) is not available, please set accessedPreferences.vpnType to one of the following: \(availableVPNTypes)")
                throw ClientError.vpnProfileUnavailable
            }

            completionBlock()

        }

        if self.accessedProviders.accountProvider.isLoggedIn {
            self.install(force: force, nil)
        }

    }

    public func install(force forceInstall: Bool, _ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }

        guard let profile = resolvedActiveProfile() else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }

        let newVPNType = profile.vpnType
        var previousProfile: VPNProfile?
        if (newVPNType != activeProfile?.vpnType) {
            previousProfile = activeProfile
        }

        let forcedStatuses = DefaultVPNProvider.forcedStatuses.contains(accessedDatabase.transient.vpnStatus)
        let installBlock: SuccessLibraryCallback = { (error) in
            guard let configuration = self.vpnClientConfiguration(for: profile) else {
                callback?(ClientError.vpnProfileUnavailable)
                return
            }
            profile.save(withConfiguration: configuration, force: forcedStatuses) { (error) in
                if let error = error {
                    callback?(error)
                    return
                }
                self.activeProfile = profile

                if let previousProfile = previousProfile,
                    !((profile.vpnType == IPSecProfile.vpnType || profile.vpnType == IKEv2Profile.vpnType) && (previousProfile.vpnType == IPSecProfile.vpnType || previousProfile.vpnType == IKEv2Profile.vpnType))
                {
                    //only remove the profile if is not Ipsec or IKEv2, if are one of them, override instead
                    previousProfile.remove({ _ in
                        Macros.postNotification(.PIAVPNDidInstall)
                        callback?(nil)
                    })
                } else {
                    if previousProfile != nil {  // dont connect after install
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

    public func disable(_ callback: SuccessLibraryCallback?) {
        guard let activeProfile else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }
        activeProfile.disconnect(nil)
        activeProfile.disable(callback)
    }

    public func uninstall(_ callback: SuccessLibraryCallback?) {
        guard let activeProfile else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }
        activeProfile.disconnect(nil)
        activeProfile.remove { (error) in
            self.activeProfile = nil
            self.accessedDatabase.transient.vpnStatus = .disconnected
            callback?(error)
        }
    }

    public func uninstallAll() {
        log.info("uninstallAll: clearing activeProfile")
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

    public func connect(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile else {
            log.error("connect: No active profile — vpnType=\(accessedPreferences.vpnType), availableTypes=\(availableVPNTypes)")
            callback?(ClientError.vpnProfileUnavailable)
            return
        }
        guard let configuration = vpnClientConfiguration() else {
            log.error("connect: vpnClientConfiguration returned nil — activeProfile=\(activeProfile.vpnType)")
            callback?(ClientError.vpnClientConfigurationUnavailable)
            return
        }

        // A new connection attempt supersedes any prior manual-disconnect
        // intent; clear the flag so the daemon's retry logic is not suppressed.
        accessedConfiguration.disconnectedManually = false

        activeProfile.connect(withConfiguration: configuration, callback)
    }

    public func disconnect(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }

        guard let activeProfile else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }

        // Capture the tunnel log best-effort, in parallel: the provider message
        // never gets a reply when the tunnel process is wedged (e.g. after a
        // network change), so the disconnect below must not wait on it.
        if let configuration = vpnClientConfiguration() {
            activeProfile.requestLog(withCustomConfiguration: configuration.customConfiguration) { (content, error) in
                guard let content, !content.isEmpty else {
                    return
                }
                self.accessedDatabase.transient.vpnLog += "\n\n" + content
            }
        }

        activeProfile.disconnect(callback)
    }

    public func updatePreferences(_ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }
        guard let activeProfile else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }
        activeProfile.updatePreferences(callback)
    }

    public func reconnect(after delay: Int?, forceDisconnect: Bool = false, _ callback: SuccessLibraryCallback?) {
        guard accessedProviders.accountProvider.isLoggedIn else {
            callback?(ClientError.unauthorized)
            return
        }

        guard let activeProfile else {
            callback?(ClientError.vpnProfileUnavailable)
            return
        }

        let shouldDisconnectFirst = (activeProfile.vpnType != IKEv2Profile.vpnType || forceDisconnect)

        if shouldDisconnectFirst {
            activeProfile.disconnect { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                // The user may have manually disconnected while this reconnect
                // cycle was in flight — never override that intent.
                guard !self.accessedConfiguration.disconnectedManually else {
                    log.debug("reconnect aborted — the user disconnected manually")
                    callback?(nil)
                    return
                }
                guard let configuration = self.vpnClientConfiguration() else {
                    callback?(ClientError.vpnProfileUnavailable)
                    return
                }
                activeProfile.connect(withConfiguration: configuration, callback)
            }
        } else {
            activeProfile.updatePreferences { (error) in
                if let _ = error {
                    callback?(error)
                    return
                }
                // The user may have manually disconnected while this reconnect
                // cycle was in flight — never override that intent.
                guard !self.accessedConfiguration.disconnectedManually else {
                    log.debug("reconnect aborted — the user disconnected manually")
                    callback?(nil)
                    return
                }
                guard let configuration = self.vpnClientConfiguration() else {
                    callback?(ClientError.vpnProfileUnavailable)
                    return
                }
                activeProfile.connect(withConfiguration: configuration, callback)
            }
        }
    }

    public func submitDebugReport() async throws -> String {
        guard activeProfile != nil else {
            throw ClientError.vpnProfileUnavailable
        }
        return try await webServices.submitDebugReport()
    }

    public func dataUsage(_ callback: LibraryCallback<Usage>?) {
        guard let activeProfile else {
            callback?(nil, ClientError.vpnProfileUnavailable)
            return
        }
        guard let configuration = vpnClientConfiguration() else {
            callback?(nil, ClientError.vpnProfileUnavailable)
            return
        }
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

    /// The profile that should handle the current connection.
    ///
    /// When the PlatformSDK feature flag is enabled, every connection is routed
    /// through the single `KapePlatformSDKTunnelProfile` regardless of the
    /// user-selected protocol. Otherwise the profile matching the selected
    /// protocol (`preferences.vpnType`) is used.
    private func resolvedActiveProfile() -> VPNProfile? {
        if accessedConfiguration.featureFlags[.usePlatformSDKVPN] {
            return accessedConfiguration.profile(forVPNType: KapePlatformSDKTunnelProfile.vpnType)
        }
        return accessedConfiguration.profile(forVPNType: accessedPreferences.vpnType)
    }

    @discardableResult private func activeProfileRemovingInactive() -> VPNProfile? {
        let activeProfile = resolvedActiveProfile()

        for vpnType in availableVPNTypes {
            let profile = accessedConfiguration.profile(forVPNType: vpnType)!
            guard (vpnType == activeProfile?.vpnType) else {
                if let activeProfile {
                    if !((profile.vpnType == IPSecProfile.vpnType || profile.vpnType == IKEv2Profile.vpnType) && (activeProfile.vpnType == IPSecProfile.vpnType || activeProfile.vpnType == IKEv2Profile.vpnType)) {
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

    private func vpnClientConfiguration(for profile: VPNProfile? = nil) -> VPNConfiguration? {
        log.info("vpnClientConfiguration: currentUser=\(accessedProviders.accountProvider.currentUser != nil), currentPasswordReference=\(accessedProviders.accountProvider.currentPasswordReference != nil), activeProfile=\(String(describing: (profile ?? activeProfile)?.vpnType))")

        guard let currentUser = accessedProviders.accountProvider.currentUser else {
            log.error("vpnClientConfiguration: No current user available")
            return nil
        }

        guard let currentPasswordReference = accessedProviders.accountProvider.currentPasswordReference else {
            log.error("vpnClientConfiguration: No current password reference available")
            return nil
        }

        guard let profile = profile ?? activeProfile else {
            log.error("vpnClientConfiguration: No VPN profile available")
            return nil
        }

        guard let targetServer = try? accessedProviders.serverProvider.targetServer else {
            log.error("vpnClientConfiguration: No target server available")
            return nil
        }

        let customConfiguration = accessedPreferences.vpnCustomConfiguration(for: profile.vpnType)

        return VPNConfiguration(
            name: accessedConfiguration.vpnProfileName,
            username: currentUser.credentials.username,
            passwordReference: currentPasswordReference,
            server: targetServer,
            isOnDemand: accessedPreferences.isPersistentConnection,
            disconnectsOnSleep: accessedPreferences.vpnDisconnectsOnSleep,
            customConfiguration: customConfiguration,
            leakProtection: accessedPreferences.leakProtection,
            allowLocalDeviceAccess: accessedPreferences.allowLocalDeviceAccess
        )
    }

    // MARK: WebServicesConsumer

    var webServices: WebServices {
        return customWebServices ?? accessedWebServices
    }

    // MARK: Migration
    public func needsMigrationToGEN4() -> Bool {
        if isVPNConnected {
            let manager = NEVPNManager.shared()
            if let protocolConfiguration = manager.protocolConfiguration,
                let address = protocolConfiguration.serverAddress,
                address.contains("privateinternetaccess.com")
            {
                return true
            }
        }
        return false
    }
}
