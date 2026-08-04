//
//  WidgetConnectAuthorizationTests.swift
//  PIALibrary
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import Foundation
import Testing

@testable import PIALibrary

@Suite("Widget Connect Authorization Tests")
struct WidgetConnectAuthorizationTests {

    /// Stands in for the app group container, so the tests need no entitlements.
    private final class InMemorySecretStore: WidgetConnectSecretStore {
        private var secrets: WidgetConnectSecrets?
        private let lock = NSLock()

        init(secrets: WidgetConnectSecrets? = nil) {
            self.secrets = secrets
        }

        func readSecrets() -> WidgetConnectSecrets? {
            lock.lock()
            defer { lock.unlock() }
            return secrets
        }

        func write(_ secrets: WidgetConnectSecrets) {
            lock.lock()
            defer { lock.unlock() }
            self.secrets = secrets
        }
    }

    private final class SpyReloader: WidgetsReloader {
        private(set) var reloadCount = 0

        func reloadWidgets() {
            reloadCount += 1
        }
    }

    private func makeSUT(secrets: WidgetConnectSecrets? = nil) -> (sut: WidgetConnectAuthorization, store: InMemorySecretStore, reloader: SpyReloader) {
        let store = InMemorySecretStore(secrets: secrets)
        let reloader = SpyReloader()
        return (WidgetConnectAuthorization(store: store, reloader: reloader), store, reloader)
    }

    @Test("The widget URL carries a secret and is authorized")
    func widgetURLIsAuthorized() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()

        let url = sut.makeConnectURL()!

        #expect(url.absoluteString.hasPrefix(AppConstants.Widget.connect))
        #expect(url.absoluteString.contains("secret="))
        #expect(sut.isAuthorized(url))
    }

    @Test("Rotating creates the secret when there is none")
    func rotatingCreatesTheFirstSecret() {
        let (sut, store, _) = makeSUT()

        sut.rotateSecret()

        #expect(store.readSecrets()?.previous == nil)
        #expect(sut.makeConnectURL() != nil)
    }

    @Test("The same secret is reused across calls")
    func secretIsStable() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()

        #expect(sut.makeConnectURL() == sut.makeConnectURL())
    }

    @Test("The same secret authorizes the URL more than once")
    func secretIsReusable() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()
        let url = sut.makeConnectURL()!

        #expect(sut.isAuthorized(url))
        #expect(sut.isAuthorized(url))
    }

    @Test("No URL is built before the app created the secret")
    func noURLWithoutStoredSecret() {
        let (sut, _, _) = makeSUT()

        #expect(sut.makeConnectURL() == nil)
    }

    @Test("A URL without a secret is rejected")
    func urlWithoutSecretIsRejected() {
        let (sut, _, _) = makeSUT()
        // Make sure a secret exists, so that the rejection is caused by the missing token.
        sut.rotateSecret()

        #expect(!sut.isAuthorized(URL(string: AppConstants.Widget.connect)!))
    }

    @Test("A URL with a forged secret is rejected")
    func urlWithForgedSecretIsRejected() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()

        let forgedURL = URL(string: "\(AppConstants.Widget.connect)?secret=deadbeef")!

        #expect(!sut.isAuthorized(forgedURL))
    }

    @Test("A URL is rejected while no secret has been created")
    func urlIsRejectedWithoutStoredSecret() {
        let widget = makeSUT(secrets: WidgetConnectSecrets(current: "a-secret-from-a-previous-install")).sut
        let url = widget.makeConnectURL()!

        // A fresh store has no secret, so not even a previously valid URL is accepted.
        let (app, _, _) = makeSUT()

        #expect(!app.isAuthorized(url))
    }

    @Test("A secret stored without a previous one still authorizes its URL")
    func secretWithoutPreviousIsAuthorized() {
        let (sut, _, _) = makeSUT(secrets: WidgetConnectSecrets(current: "a-secret-from-the-shipped-build"))

        #expect(sut.isAuthorized(sut.makeConnectURL()!))
    }

    @Test("Rotating builds a different URL")
    func rotatingChangesTheURL() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()
        let before = sut.makeConnectURL()

        sut.rotateSecret()

        #expect(sut.makeConnectURL() != before)
    }

    @Test("A URL from before the last rotation is still authorized")
    func urlFromThePreviousSecretIsAuthorized() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()
        let staleURL = sut.makeConnectURL()!

        sut.rotateSecret()

        // The widget may not have redrawn yet, so its URL still carries the previous secret.
        #expect(sut.isAuthorized(staleURL))
    }

    @Test("A URL from two rotations ago is rejected")
    func urlFromTwoRotationsAgoIsRejected() {
        let (sut, _, _) = makeSUT()
        sut.rotateSecret()
        let staleURL = sut.makeConnectURL()!

        sut.rotateSecret()
        sut.rotateSecret()

        #expect(!sut.isAuthorized(staleURL))
    }

    @Test("Resetting drops the previous secret")
    func resettingDropsThePreviousSecret() {
        let (sut, store, _) = makeSUT()
        sut.rotateSecret()
        let urlBeforeReset = sut.makeConnectURL()!

        sut.resetSecret()

        #expect(store.readSecrets()?.previous == nil)
        #expect(sut.makeConnectURL() != urlBeforeReset)
        #expect(!sut.isAuthorized(urlBeforeReset))
    }

    @Test("Storing a new secret asks the widgets to redraw")
    func storingASecretReloadsTheWidgets() {
        let (sut, _, reloader) = makeSUT()

        sut.rotateSecret()
        #expect(reloader.reloadCount == 1)

        sut.resetSecret()
        #expect(reloader.reloadCount == 2)
    }

    @Test("The registered reloader is the one asked to redraw")
    func registeredReloaderIsUsed() {
        let (sut, _, initialReloader) = makeSUT()
        let registered = SpyReloader()
        sut.setReloader(registered)

        sut.rotateSecret()

        #expect(registered.reloadCount == 1)
        #expect(initialReloader.reloadCount == 0)
    }
}
