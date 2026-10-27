//
//  WidgetConnectTokenTests.swift
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

import Foundation
import Testing

@testable import PIALibrary

struct WidgetConnectTokenTests {
    private let sut = WidgetConnectToken(defaults: UserDefaults(suiteName: UUID().uuidString))

    @Test func ensureExistsCreatesTokenOnlyOnce() throws {
        #expect(sut.current == nil)

        #expect(sut.ensureExists())
        let token = try #require(sut.current)
        #expect(!token.isEmpty)

        #expect(!sut.ensureExists())
        #expect(sut.current == token)
    }

    @Test func connectURLCreatesAndCarriesToken() throws {
        let url = try #require(sut.connectURL)
        let token = try #require(sut.current)

        #expect(url.absoluteString == "piavpn:connect?token=\(token)")
        #expect(sut.connectURL == url)
    }

    @Test func validTokenIsConsumedAndRotated() throws {
        sut.ensureExists()
        let url = try #require(sut.connectURL)
        let token = sut.current

        #expect(sut.consume(from: url))
        #expect(sut.current != nil)
        #expect(sut.current != token)
    }

    @Test func consumedTokenCannotBeReplayed() throws {
        sut.ensureExists()
        let url = try #require(sut.connectURL)

        #expect(sut.consume(from: url))
        #expect(!sut.consume(from: url))
    }

    @Test(arguments: [
        "piavpn:connect",
        "piavpn:connect?token=",
        "piavpn:connect?token=wrong",
        "piavpn:connect?other=value"
    ])
    func invalidTokenIsRejectedWithoutRotation(urlString: String) throws {
        sut.ensureExists()
        let token = sut.current
        let url = try #require(URL(string: urlString))

        #expect(!sut.consume(from: url))
        #expect(sut.current == token)
    }

    @Test func nothingIsAcceptedBeforeTokenExists() throws {
        let url = try #require(URL(string: "piavpn:connect?token="))

        #expect(!sut.consume(from: url))
    }
}
