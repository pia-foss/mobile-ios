//
//  PlatformSDKMigrationUseCaseTests.swift
//  PIA VPN-tvOSTests
//
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import XCTest

@testable import PIA_VPN_tvOS

final class PlatformSDKMigrationUseCaseTests: XCTestCase {

    final class Fixture {
        let legacyVPNProfilesMock = LegacyVPNProfilesMock()
        let appPreferencesMock = AppPreferencesMock()
        let accountProviderMock = AccountProviderMock(userResult: nil, errorResult: nil)
        let vpnConnectSpy = VPNConnectSpy()
    }

    var fixture: Fixture!
    var sut: PlatformSDKMigrationUseCase!

    override func setUp() {
        fixture = Fixture()
    }

    override func tearDown() {
        fixture = nil
        sut = nil
    }

    private func instantiateSut(vpnStatusTimeout: DispatchTimeInterval = .seconds(3)) {
        sut = PlatformSDKMigrationUseCase(
            legacyVPNProfiles: fixture.legacyVPNProfilesMock,
            appPreferences: fixture.appPreferencesMock,
            accountProvider: fixture.accountProviderMock,
            connectVPN: fixture.vpnConnectSpy.connect,
            vpnStatusTimeout: vpnStatusTimeout
        )
    }

    // The cleanup uses the VPN reading taken by the consent check, so the real launch sequence has
    // to be replayed: the check first, then bootstrap's cleanup.
    private func runConsentCheckThenCleanup() {
        _ = shouldConfirmMigration()
        sut.cleanupLegacyVPNProfilesIfNeeded()
    }

    private func shouldConfirmMigration() -> Bool {
        var result: Bool?
        sut.shouldConfirmMigration { result = $0 }

        guard let result else {
            XCTFail("The migration check did not answer")
            return false
        }

        return result
    }

    // MARK: - shouldUsePlatformSDKTunnel

    func testShouldUsePlatformSDKTunnel_WhenMigrationWasConfirmed() {
        // GIVEN that the user confirmed the migration
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true

        // WHEN the app is launched
        instantiateSut()

        // THEN the launch runs through the PlatformSDK tunnel
        XCTAssertTrue(sut.shouldUsePlatformSDKTunnel)
    }

    func testShouldUsePlatformSDKTunnel_WhenMigrationWasNotConfirmed() {
        // GIVEN that the user has not confirmed the migration
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = false

        // WHEN the app is launched
        instantiateSut()

        // THEN the launch stays on the legacy profile
        XCTAssertFalse(sut.shouldUsePlatformSDKTunnel)
    }

    // MARK: - shouldConfirmMigration

    func testShouldConfirmMigration_WhenMigrationWasAlreadyConfirmed() {
        // GIVEN a launch whose consent is on record but whose cleanup has still to run
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        instantiateSut()

        // WHEN the migration check runs
        // THEN it does not ask the user again
        XCTAssertFalse(shouldConfirmMigration())

        // AND it still reads the VPN status, because this launch is about to tear the legacy
        // tunnel down and the cleanup has no other way to learn there was one to restore
        XCTAssertEqual(fixture.legacyVPNProfilesMock.isVPNConnectedCalledAttempt, 1)
    }

    func testShouldConfirmMigration_WhenTheLegacyProfilesWereAlreadyRemoved() {
        // GIVEN that the legacy profiles were already removed
        fixture.appPreferencesMock.didCleanupLegacyVPNProfiles = true
        instantiateSut()

        // WHEN the migration check runs
        // THEN it does not ask the user
        XCTAssertFalse(shouldConfirmMigration())

        // AND the consent is recorded silently, so the launch migrates
        XCTAssertTrue(fixture.appPreferencesMock.didConfirmPlatformSDKMigration)

        // AND it does not need to read the VPN status
        XCTAssertEqual(fixture.legacyVPNProfilesMock.isVPNConnectedCalledAttempt, 0)
    }

    func testShouldConfirmMigration_AsksTheNetworkExtensionRatherThanTheOnboardingFlag() {
        // GIVEN a user with a live legacy tunnel who looks un-onboarded, because
        // `VPNConfigurationAvailability` lives in `UserDefaults.standard` (per bundle identifier,
        // cleared on logout) rather than in the app group the migration state uses
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        instantiateSut()

        // WHEN the migration check runs
        // THEN the live tunnel still earns the confirmation notice
        XCTAssertTrue(shouldConfirmMigration())
        XCTAssertEqual(fixture.legacyVPNProfilesMock.isVPNConnectedCalledAttempt, 1)
    }

    func testShouldConfirmMigration_WhenTheLegacyTunnelIsNotConnected() {
        // GIVEN a user with a legacy profile that is not connected
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = false
        instantiateSut()

        // WHEN the migration check runs
        // THEN it does not ask the user — nothing is interrupted
        XCTAssertFalse(shouldConfirmMigration())

        // AND the consent is recorded silently, so the launch migrates
        XCTAssertTrue(fixture.appPreferencesMock.didConfirmPlatformSDKMigration)
    }

    func testShouldConfirmMigration_WhenTheLegacyTunnelIsConnected() {
        // GIVEN a user with a live legacy tunnel
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        instantiateSut()

        // WHEN the migration check runs
        // THEN the user is asked to confirm
        XCTAssertTrue(shouldConfirmMigration())

        // AND the consent is not recorded until they do
        XCTAssertFalse(fixture.appPreferencesMock.didConfirmPlatformSDKMigration)
    }

    func testShouldConfirmMigration_WhenTheVPNStatusReadStalls() {
        // GIVEN a VPN status read that never answers
        fixture.legacyVPNProfilesMock.withholdsIsVPNConnectedAnswer = true
        instantiateSut(vpnStatusTimeout: .milliseconds(10))

        // WHEN the migration check runs
        let expectation = expectation(description: "The migration check times out")
        var result: Bool?
        sut.shouldConfirmMigration {
            result = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // THEN the timeout answers 'no', so this launch stays on the legacy profile
        XCTAssertEqual(result, false)

        // AND the consent is not recorded, so the next launch asks again
        XCTAssertFalse(fixture.appPreferencesMock.didConfirmPlatformSDKMigration)
    }

    func testShouldConfirmMigration_WhenTheVPNStatusArrivesAfterTheTimeout() {
        // GIVEN a launch that already has consent but has still to clean up, whose VPN status read
        // does not answer in time
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.withholdsIsVPNConnectedAnswer = true
        fixture.accountProviderMock.isLoggedIn = true
        instantiateSut(vpnStatusTimeout: .milliseconds(10))

        let expectation = expectation(description: "The migration check times out")
        sut.shouldConfirmMigration { _ in expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        // WHEN the reading lands late, reporting a live tunnel
        fixture.legacyVPNProfilesMock.pendingIsVPNConnectedAnswer?(true)

        // THEN the cleanup still restores the connection: this launch migrates regardless of the
        // timeout, so a discarded reading would tear the tunnel down for good
        sut.cleanupLegacyVPNProfilesIfNeeded()
        XCTAssertEqual(fixture.vpnConnectSpy.callAttempt, 1)
    }

    // MARK: - confirmMigration

    func testConfirmMigration_RecordsTheConsent() {
        // GIVEN a user who has not confirmed the migration
        instantiateSut()
        XCTAssertFalse(sut.shouldUsePlatformSDKTunnel)

        // WHEN they confirm it
        sut.confirmMigration()

        // THEN the consent is recorded and the launch migrates
        XCTAssertTrue(fixture.appPreferencesMock.didConfirmPlatformSDKMigration)
        XCTAssertTrue(sut.shouldUsePlatformSDKTunnel)
    }

    // MARK: - cleanupLegacyVPNProfilesIfNeeded

    func testCleanupLegacyVPNProfiles_WhenTheMigrationWasNotConfirmed() {
        // GIVEN a launch that has not migrated
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = false
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        instantiateSut()

        // WHEN the cleanup runs without the user having confirmed
        sut.cleanupLegacyVPNProfilesIfNeeded()

        // THEN nothing is removed
        XCTAssertEqual(fixture.legacyVPNProfilesMock.removeAllCalledAttempt, 0)
    }

    func testCleanupLegacyVPNProfiles_WhenTheProfilesWereAlreadyRemoved() {
        // GIVEN a migrated launch whose legacy profiles are already gone
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.appPreferencesMock.didCleanupLegacyVPNProfiles = true
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN it does not run again
        XCTAssertEqual(fixture.legacyVPNProfilesMock.removeAllCalledAttempt, 0)
    }

    func testCleanupLegacyVPNProfiles_WhenTheRemovalSucceeds() {
        // GIVEN a migrated launch with a legacy profile still installed
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.removeAllResult = true
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN the profile is removed and the cleanup is latched
        XCTAssertEqual(fixture.legacyVPNProfilesMock.removeAllCalledAttempt, 1)
        XCTAssertTrue(fixture.appPreferencesMock.didCleanupLegacyVPNProfiles)
    }

    func testCleanupLegacyVPNProfiles_WhenTheRemovalFails() {
        // GIVEN a migrated launch where the removal cannot be verified
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.removeAllResult = false
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN the cleanup is not latched, so the next launch retries
        XCTAssertFalse(fixture.appPreferencesMock.didCleanupLegacyVPNProfiles)
    }

    func testCleanupLegacyVPNProfiles_WhenTheTunnelWasLive() {
        // GIVEN a migrated launch with a live legacy tunnel and a logged in user
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        fixture.accountProviderMock.isLoggedIn = true
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN removing the configuration is followed by a reconnect
        XCTAssertEqual(fixture.vpnConnectSpy.callAttempt, 1)
    }

    func testCleanupLegacyVPNProfiles_WhenTheTunnelWentDownBeforeTheCleanupRan() {
        // GIVEN a user who confirmed the migration with a live tunnel
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        fixture.accountProviderMock.isLoggedIn = true
        instantiateSut()
        XCTAssertTrue(shouldConfirmMigration())
        sut.confirmMigration()

        // AND GIVEN the tunnel is already gone by the time the cleanup runs, because registering
        // the PlatformSDK profile took the legacy configuration with it
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = false

        // WHEN the cleanup runs
        sut.cleanupLegacyVPNProfilesIfNeeded()

        // THEN the reconnect still happens: the reading taken before bootstrap is what counts
        XCTAssertEqual(fixture.vpnConnectSpy.callAttempt, 1)
    }

    func testCleanupLegacyVPNProfiles_WhenTheTunnelWasNotLive() {
        // GIVEN a migrated launch with no live tunnel
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = false
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN the VPN is not turned on behind the user's back
        XCTAssertFalse(fixture.vpnConnectSpy.wasCalled)
    }

    func testCleanupLegacyVPNProfiles_WhenTheUserIsLoggedOut() {
        // GIVEN a migrated launch with a live tunnel but no logged in user
        fixture.appPreferencesMock.didConfirmPlatformSDKMigration = true
        fixture.legacyVPNProfilesMock.isVPNConnectedResult = true
        fixture.accountProviderMock.isLoggedIn = false
        instantiateSut()

        // WHEN the cleanup runs
        runConsentCheckThenCleanup()

        // THEN no reconnection is attempted
        XCTAssertFalse(fixture.vpnConnectSpy.wasCalled)
    }
}
