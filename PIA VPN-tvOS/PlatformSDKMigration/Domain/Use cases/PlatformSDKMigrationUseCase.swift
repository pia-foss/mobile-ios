//
//  PlatformSDKMigrationUseCase.swift
//  PIA VPN-tvOS
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

private let log = PIALogger.logger(for: PlatformSDKMigrationUseCase.self)

protocol PlatformSDKMigrationUseCaseType: Sendable {
    var shouldUsePlatformSDKTunnel: Bool { get }

    func shouldConfirmMigration(_ completion: @escaping (Bool) -> Void)
    func confirmMigration()
    func cleanupLegacyVPNProfilesIfNeeded()
}

final class PlatformSDKMigrationUseCase: PlatformSDKMigrationUseCaseType, @unchecked Sendable {

    private let legacyVPNProfiles: LegacyVPNProfilesType
    private let appPreferences: AppPreferencesType
    private let accountProvider: AccountProvider
    private let connectVPN: (@escaping (Error?) -> Void) -> Void
    private let vpnStatusTimeout: DispatchTimeInterval
    private var wasConnectedBeforeMigration = false

    init(
        legacyVPNProfiles: LegacyVPNProfilesType,
        appPreferences: AppPreferencesType,
        accountProvider: AccountProvider,
        connectVPN: @escaping (@escaping (Error?) -> Void) -> Void,
        vpnStatusTimeout: DispatchTimeInterval = .seconds(3)
    ) {
        self.legacyVPNProfiles = legacyVPNProfiles
        self.appPreferences = appPreferences
        self.accountProvider = accountProvider
        self.connectVPN = connectVPN
        self.vpnStatusTimeout = vpnStatusTimeout
    }

    // MARK: - Consent

    var shouldUsePlatformSDKTunnel: Bool {
        appPreferences.didConfirmPlatformSDKMigration
    }

    func shouldConfirmMigration(_ completion: @escaping (Bool) -> Void) {
        guard !appPreferences.didCleanupLegacyVPNProfiles else {
            appPreferences.didConfirmPlatformSDKMigration = true
            completion(false)
            return
        }

        let didAlreadyConfirm = appPreferences.didConfirmPlatformSDKMigration
        var didAnswer = false

        let answer: (Bool) -> Void = { shouldConfirm in
            didAnswer = true
            completion(shouldConfirm)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + vpnStatusTimeout) {
            guard !didAnswer else { return }

            log.error("shouldConfirmMigration: timed out, staying on the legacy profile")
            answer(false)
        }

        legacyVPNProfiles.isVPNConnected { [weak self] isConnected in
            self?.wasConnectedBeforeMigration = isConnected

            guard !didAnswer else {
                return
            }

            guard !didAlreadyConfirm else {
                answer(false)
                return
            }

            guard isConnected else {
                log.info("shouldConfirmMigration: no live tunnel, migrating without asking")
                self?.appPreferences.didConfirmPlatformSDKMigration = true
                answer(false)
                return
            }

            answer(true)
        }
    }

    func confirmMigration() {
        log.info("confirmMigration: user confirmed the migration to the PlatformSDK tunnel")
        appPreferences.didConfirmPlatformSDKMigration = true
    }

    // MARK: - Migrating to the PlatformSDK tunnel

    /// One-time removal of the legacy IKEv2 VPN configuration, so the PlatformSDK tunnel starts
    /// from a clean slate.
    func cleanupLegacyVPNProfilesIfNeeded() {
        guard shouldUsePlatformSDKTunnel, !appPreferences.didCleanupLegacyVPNProfiles else {
            return
        }

        let supportedTypes: [KapePlatformSDKVPNType] = [
            .automatic,
            .wireGuard,
            .openVPN
        ]

        if !supportedTypes.map(\.rawValue).contains(Client.preferences.vpnType) {
            let editable = Client.preferences.editable()
            editable.vpnType = KapePlatformSDKVPNType.automatic.rawValue
            editable.commit()
        }

        let wasConnected = wasConnectedBeforeMigration

        legacyVPNProfiles.removeAll { [weak self] didRemove in
            guard let self else { return }

            log.info("cleanupLegacyVPNProfiles: removed: \(didRemove), connected: \(wasConnected)")
            self.appPreferences.didCleanupLegacyVPNProfiles = didRemove

            // Migrating disconnects a user who had a live tunnel, so put it back up.
            guard wasConnected, self.accountProvider.isLoggedIn else {
                return
            }

            self.connectVPN { error in
                if let error {
                    log.error("cleanupLegacyVPNProfiles: could not reconnect (\(error.localizedDescription))")
                }
            }
        }
    }
}
