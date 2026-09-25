//
//  DedicatedIPTokenHandlerTests.swift
//  PIALibraryTests
//
//  Copyright © 2026 Private Internet Access, Inc.
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

import XCTest

@testable import PIALibrary

final class DedicatedIPTokenHandlerTests: XCTestCase {

    func testWritesToTheStoreCurrentAtCallTimeNotAtInit() {
        let launchStore = SecureStoreSpy()
        let appGroupStore = SecureStoreSpy()
        let currentStore = CurrentStore(launchStore)
        let sut = DedicatedIPTokenHandler(secureStore: { currentStore.value })

        currentStore.value = appGroupStore
        sut(dedicatedIp: makeDedicatedIP(), dipUsername: "dedicated_ip_token_abc")

        XCTAssertEqual(appGroupStore.dipTokensSet, ["token"])
        XCTAssertEqual(appGroupStore.dipPasswords["dedicated_ip_token_abc"], "1.2.3.4")
        XCTAssertTrue(launchStore.dipTokensSet.isEmpty)
        XCTAssertTrue(launchStore.dipPasswords.isEmpty)
    }

    private func makeDedicatedIP() -> DedicatedIPInformation {
        DedicatedIPInformation(
            id: "us-california",
            ip: "1.2.3.4",
            cn: "cn",
            groups: nil,
            dipExpire: Date().addingTimeInterval(30 * 24 * 3600).timeIntervalSince1970,
            dipToken: "token",
            status: .active)
    }
}

private final class CurrentStore: @unchecked Sendable {
    var value: SecureStore

    init(_ value: SecureStore) {
        self.value = value
    }
}

private final class SecureStoreSpy: SecureStore, @unchecked Sendable {
    private(set) var dipTokensSet: [String] = []
    private(set) var dipPasswords: [String: String] = [:]

    func setDIPToken(_ dipToken: String) { dipTokensSet.append(dipToken) }
    func setPassword(_ password: String?, forDipToken dip: String) { dipPasswords[dip] = password }

    func username() -> String? { nil }
    func setUsername(_ username: String?) {}
    func publicUsername() -> String? { nil }
    func setPublicUsername(_ username: String?) {}
    func password(for username: String) -> String? { nil }
    func setPassword(_ password: String?, for username: String) {}
    func passwordReference(for username: String) -> Data? { nil }
    func token(for username: String) -> String? { nil }
    func setTokenData(_ tokenData: Data, for tokenKey: String) {}
    func clearToken(for username: String) {}
    func tokenKey(for username: String) -> String { username }
    func dipTokens() -> [String]? { dipTokensSet }
    func remove(_ dipToken: String) {}
    func removeDIPTokens() {}
    func passwordReference(forDipToken dip: String) -> Data? { nil }
    func clear(for username: String) {}
}
