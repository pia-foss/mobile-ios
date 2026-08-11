//
//  AppleIDIdentityTokenTests.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import PIABase
import XCTest

@testable import PIA_VPN

class AppleIDIdentityTokenTests: XCTestCase {

    func testDecodesEmailClaim() {
        let token = makeToken(payload: #"{"sub":"001234.abc","email":"user@privaterelay.appleid.com","email_verified":"true","is_private_email":"true"}"#)

        XCTAssertEqual(AppleIDIdentityToken.email(fromIdentityToken: token), "user@privaterelay.appleid.com")
    }

    func testDecodesEmailClaimFromPayloadNeedingBase64URLPadding() {
        // Payloads whose base64url length is not a multiple of 4 must still decode.
        for filler in ["a", "ab", "abc", "abcd"] {
            let token = makeToken(payload: #"{"pad":"\#(filler)","email":"user@example.com"}"#)
            XCTAssertEqual(
                AppleIDIdentityToken.email(fromIdentityToken: token),
                "user@example.com",
                "failed for filler \(filler)")
        }
    }

    func testDecodesEmailClaimFromPayloadUsingBase64URLAlphabet() {
        // "~~~?" base64-encodes to "fn5+Pw==", which contains both + and /
        // once the payload is long enough, so it exercises the URL alphabet.
        let token = makeToken(payload: #"{"nonce":"~~~?????>>>","email":"user@example.com"}"#)

        XCTAssertEqual(AppleIDIdentityToken.email(fromIdentityToken: token), "user@example.com")
    }

    func testReturnsNilWhenEmailClaimIsMissing() {
        let token = makeToken(payload: #"{"sub":"001234.abc","email_verified":"true"}"#)

        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: token))
    }

    func testReturnsNilWhenEmailClaimIsEmpty() {
        let token = makeToken(payload: #"{"email":""}"#)

        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: token))
    }

    func testReturnsNilWhenPayloadIsNotJSON() {
        let token = makeToken(payload: "not json")

        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: token))
    }

    func testReturnsNilWhenTokenIsNotAThreeSegmentJWT() {
        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: Data("header.payload".utf8)))
        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: Data("a.b.c.d".utf8)))
        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: Data()))
    }

    func testReturnsNilWhenPayloadIsNotBase64() {
        XCTAssertNil(AppleIDIdentityToken.email(fromIdentityToken: Data("header.!!!!.signature".utf8)))
    }

    // MARK: Helpers

    /// Builds an unsigned JWT carrying the given payload, encoded the way Apple
    /// encodes identity tokens (base64url, no padding).
    private func makeToken(payload: String) -> Data {
        let header = Data(#"{"alg":"RS256","kid":"test"}"#.utf8).base64UrlEncodedString()
        let claims = Data(payload.utf8).base64UrlEncodedString()
        return Data("\(header).\(claims).signature".utf8)
    }
}
