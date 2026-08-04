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

    /// Stands in for the group keychain, so the tests need no entitlements.
    private final class InMemorySecretStore: WidgetConnectSecretStore {
        private var secret: String?
        private let lock = NSLock()

        init(secret: String? = nil) {
            self.secret = secret
        }

        func readSecret() -> String? {
            lock.lock()
            defer { lock.unlock() }
            return secret
        }

        func write(_ secret: String) {
            lock.lock()
            defer { lock.unlock() }
            self.secret = secret
        }
    }

    private func makeSUT(secret: String? = nil) -> (sut: WidgetConnectAuthorization, store: InMemorySecretStore) {
        let store = InMemorySecretStore(secret: secret)
        return (WidgetConnectAuthorization(store: store), store)
    }

    @Test("The widget URL carries a secret and is authorized")
    func widgetURLIsAuthorized() {
        let (sut, _) = makeSUT()
        sut.createSecretIfNeeded()

        let url = sut.makeConnectURL()!

        #expect(url.absoluteString.hasPrefix(AppConstants.Widget.connect))
        #expect(url.absoluteString.contains("secret="))
        #expect(sut.isAuthorized(url))
    }

    @Test("The secret is created once and then reused")
    func secretIsCreatedOnce() {
        let (sut, store) = makeSUT()

        sut.createSecretIfNeeded()
        let created = store.readSecret()
        sut.createSecretIfNeeded()

        #expect(created != nil)
        #expect(store.readSecret() == created)
    }

    @Test("The same secret is reused across calls")
    func secretIsStable() {
        let (sut, _) = makeSUT()
        sut.createSecretIfNeeded()

        #expect(sut.makeConnectURL() == sut.makeConnectURL())
    }

    @Test("The same secret authorizes the URL more than once")
    func secretIsReusable() {
        let (sut, _) = makeSUT()
        sut.createSecretIfNeeded()
        let url = sut.makeConnectURL()!

        #expect(sut.isAuthorized(url))
        #expect(sut.isAuthorized(url))
    }

    @Test("No URL is built before the app created the secret")
    func noURLWithoutStoredSecret() {
        let (sut, _) = makeSUT()

        #expect(sut.makeConnectURL() == nil)
    }

    @Test("A URL without a secret is rejected")
    func urlWithoutSecretIsRejected() {
        let (sut, _) = makeSUT()
        // Make sure a secret exists, so that the rejection is caused by the missing token.
        sut.createSecretIfNeeded()

        #expect(!sut.isAuthorized(URL(string: AppConstants.Widget.connect)!))
    }

    @Test("A URL with a forged secret is rejected")
    func urlWithForgedSecretIsRejected() {
        let (sut, _) = makeSUT()
        sut.createSecretIfNeeded()

        let forgedURL = URL(string: "\(AppConstants.Widget.connect)?secret=deadbeef")!

        #expect(!sut.isAuthorized(forgedURL))
    }

    @Test("A URL is rejected while no secret has been created")
    func urlIsRejectedWithoutStoredSecret() {
        let widget = makeSUT(secret: "a-secret-from-a-previous-install").sut
        let url = widget.makeConnectURL()!

        // A fresh store has no secret, so not even a previously valid URL is accepted.
        let (app, _) = makeSUT()

        #expect(!app.isAuthorized(url))
    }
}
