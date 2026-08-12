//
//  DataBase64URLTests.swift
//  PIABase
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

@testable import PIABase

struct DataBase64URLTests {

    // MARK: - Encoding

    @Test("Encoding uses the URL-safe alphabet")
    func encodingUsesURLSafeAlphabet() {
        // These encode to sextets 62 and 63, i.e. "+" and "/" in the standard alphabet.
        #expect(Data([0xFB, 0xEF, 0xBE]).base64UrlEncodedString() == "----")
        #expect(Data([0xFF, 0xFF, 0xFF]).base64UrlEncodedString() == "____")
    }

    @Test("Encoding omits the padding")
    func encodingOmitsPadding() {
        #expect(Data("a".utf8).base64UrlEncodedString() == "YQ")
        #expect(Data("ab".utf8).base64UrlEncodedString() == "YWI")
        #expect(Data("abc".utf8).base64UrlEncodedString() == "YWJj")
    }

    @Test("Encoding empty data yields an empty string")
    func encodingEmptyData() {
        #expect(Data().base64UrlEncodedString() == "")
    }

    // MARK: - Decoding

    @Test("Decoding accepts unpadded input of every remainder length")
    func decodingAcceptsUnpaddedInput() {
        #expect(Data(base64UrlEncoded: "YQ") == Data("a".utf8))
        #expect(Data(base64UrlEncoded: "YWI") == Data("ab".utf8))
        #expect(Data(base64UrlEncoded: "YWJj") == Data("abc".utf8))
    }

    @Test("Decoding accepts padded input")
    func decodingAcceptsPaddedInput() {
        #expect(Data(base64UrlEncoded: "YQ==") == Data("a".utf8))
        #expect(Data(base64UrlEncoded: "YWI=") == Data("ab".utf8))
    }

    @Test("Decoding translates the URL-safe alphabet")
    func decodingTranslatesURLSafeAlphabet() {
        #expect(Data(base64UrlEncoded: "----") == Data([0xFB, 0xEF, 0xBE]))
        #expect(Data(base64UrlEncoded: "____") == Data([0xFF, 0xFF, 0xFF]))
    }

    @Test("Decoding an empty string yields empty data")
    func decodingEmptyString() {
        #expect(Data(base64UrlEncoded: "") == Data())
    }

    @Test("Decoding rejects the standard alphabet")
    func decodingRejectsStandardAlphabet() {
        #expect(Data(base64UrlEncoded: "++--") == nil)
        #expect(Data(base64UrlEncoded: "//__") == nil)
    }

    @Test("Decoding rejects a length that cannot encode whole bytes")
    func decodingRejectsImpossibleLength() {
        #expect(Data(base64UrlEncoded: "Y") == nil)
        #expect(Data(base64UrlEncoded: "YWJjY") == nil)
    }

    @Test("Decoding rejects characters outside the alphabet")
    func decodingRejectsInvalidCharacters() {
        #expect(Data(base64UrlEncoded: "!!!!") == nil)
        #expect(Data(base64UrlEncoded: "YQ ==") == nil)
        #expect(Data(base64UrlEncoded: "Y=WI") == nil)
    }

    // MARK: - Round trip

    @Test("Encoding then decoding round-trips arbitrary bytes")
    func roundTrip() {
        for length in 0...64 {
            let data = Data((0..<length).map { UInt8(($0 * 37 + 11) % 256) })
            #expect(
                Data(base64UrlEncoded: data.base64UrlEncodedString()) == data,
                "failed for length \(length)")
        }
    }
}
