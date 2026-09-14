//
//  StringRedactIPsTests.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 31.08.26.
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Testing

@testable import PIALibrary

@Suite("String redactIPs Tests")
struct StringRedactIPsTests {

    @Test(
        "IPv4 addresses of every kind are redacted",
        arguments: [
            ("127.0.0.1", "REDACTED"),
            ("0.0.0.0", "REDACTED"),
            ("255.255.255.255", "REDACTED"),
            ("100.64.0.1", "REDACTED"),
            ("169.254.1.1", "REDACTED"),
            ("224.0.0.251", "REDACTED"),
            ("8.8.8.8", "REDACTED"),
            ("209.222.18.222", "REDACTED"),
            ("010.001.001.001", "REDACTED"),
            ("handshake with 10.0.12.34:1337 completed", "handshake with REDACTED:1337 completed"),
            ("subnet 10.0.0.0/8 added", "subnet REDACTED/8 added"),
            ("gateway 192.168.1.1 and dns 1.1.1.1", "gateway REDACTED and dns REDACTED"),
            ("src 10.0.8.2 dst 10.0.8.1", "src REDACTED dst REDACTED"),
            (
                "route add 10.0.0.0 mask 255.0.0.0 gw 10.0.8.1",
                "route add REDACTED mask REDACTED gw REDACTED"
            )
        ]
    )
    func redactsIPv4(input: String, expected: String) {
        #expect(input.redactIPs() == expected)
    }

    @Test(
        "IPv6 addresses of every kind are redacted",
        arguments: [
            ("connecting to 2001:0db8:85a3::8a2e:0370:7334 now", "connecting to REDACTED now"),
            ("2001:db8:85a3:8d3:1319:8a2e:370:7348", "REDACTED"),
            ("2001:0db8:0000:0000:0000:ff00:0042:8329", "REDACTED"),
            ("2001:DB8:85A3:8D3:1319:8A2E:370:7348", "REDACTED"),
            ("2001:DB8::AbCd", "REDACTED"),
            ("fe80::1", "REDACTED"),
            ("fd00::1", "REDACTED"),
            ("fdc9:281f:04d7:9ee9::1", "REDACTED"),
            ("ff02::1", "REDACTED"),
            ("ff02::fb", "REDACTED"),
            ("2002:c0a8:6301::1", "REDACTED"),
            ("2001:0:4136:e378:8000:63bf:3fff:fdd2", "REDACTED"),
            ("2606:4700:4700::1111", "REDACTED"),
            ("::1", "REDACTED"),
            ("peer ::", "peer REDACTED"),
            ("1::", "REDACTED"),
            ("1::8", "REDACTED"),
            ("1::7:8", "REDACTED"),
            ("1:2:3:4:5:6:7::", "REDACTED"),
            ("::2:3:4:5:6:7:8", "REDACTED"),
            ("::b:c:d:e:f:1:2", "REDACTED"),
            // A colon-separated EUI-64 is also a well-formed IPv6 literal, and a hardware
            // identifier in its own right, so redacting it is the safe reading.
            ("eui aa:bb:cc:dd:ee:ff:11:22", "eui REDACTED"),
            ("a=fe80::1,b=2001:db8::2", "a=REDACTED,b=REDACTED"),
            ("dns 2001:4860:4860::8888, 2001:4860:4860::8844", "dns REDACTED, REDACTED")
        ]
    )
    func redactsIPv6(input: String, expected: String) {
        #expect(input.redactIPs() == expected)
    }

    @Test(
        "IPv6 addresses are redacted together with their surrounding notation",
        arguments: [
            ("fe80::1%en0", "REDACTED"),
            ("fe80::a00:27ff:fe4e:66a1%utun2", "REDACTED"),
            ("endpoint [2001:db8::1]:443 up", "endpoint [REDACTED]:443 up"),
            ("https://[2001:db8::1]:8443/status", "https://[REDACTED]:8443/status"),
            ("route 2001:db8::/32 added", "route REDACTED/32 added"),
            ("inet6 fe80::1/64 scope link", "inet6 REDACTED/64 scope link"),
            ("AllowedIPs = 0.0.0.0/0, ::/0", "AllowedIPs = REDACTED/0, REDACTED/0"),
            (#"{"ip":"2001:db8::1"}"#, #"{"ip":"REDACTED"}"#),
            ("reached 2001:db8::1.", "reached REDACTED."),
            ("(2001:db8::1)", "(REDACTED)"),
            ("<fe80::1>", "<REDACTED>"),
            // Log lines glue an address to a colon on either side; both must still redact.
            ("peer:2001:db8::1 up", "peer:REDACTED up"),
            ("2001:db8::1: connect failed", "REDACTED: connect failed")
        ]
    )
    func redactsIPv6Notation(input: String, expected: String) {
        #expect(input.redactIPs() == expected)
    }

    @Test(
        "IPv6 addresses embedding a dotted quad leave no IPv4 part behind",
        arguments: [
            ("::ffff:192.168.1.1", "REDACTED"),
            ("::FFFF:0:192.168.1.1", "REDACTED"),
            ("::1.2.3.4", "REDACTED"),
            ("1::1.2.3.4", "REDACTED"),
            ("1:2::3:1.2.3.4", "REDACTED"),
            ("1:2:3:4:5::1.2.3.4", "REDACTED"),
            ("1:2:3:4:5:6:1.2.3.4", "REDACTED"),
            ("2001:db8:1:2:3:4:192.0.2.128", "REDACTED"),
            ("64:ff9b::192.0.2.33", "REDACTED")
        ]
    )
    func redactsIPv4MappedIPv6(input: String, expected: String) {
        #expect(input.redactIPs() == expected)
    }

    @Test("Both families are redacted from the same line")
    func redactsBothFamiliesTogether() {
        let log = "tunnel 10.0.8.2 -> 2001:db8::1 via 192.168.1.1 and fe80::1%utun3"
        #expect(log.redactIPs() == "tunnel REDACTED -> REDACTED via REDACTED and REDACTED")
    }

    @Test(
        "Colon-separated text that is not an address is left alone",
        arguments: [
            "2026-03-17 12:34:56.789 starting",
            "Mon Mar 17 23:19:51 2026",
            "ts 2026-08-31T13:37:25.776+0200",
            "offset 00:00:00.000000+02:00",
            "level=info ts=23:19:51 msg=connected",
            "duration 0:00:12",
            "duration 1:2:3:4:5",
            "ratio 16:9",
            "aa:bb:cc:dd:ee:ff",
            "PIALibrary::VPN::Tunnel",
            "Foo::bar called",
            "af::inet",
            "key: value",
            "subsystem:com.privateinternetaccess.ios category:vpn",
            #"{"time":"12:00:00"}"#,
            "no addresses here at all",
            "fingerprint AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD",
            "md5 d4:1d:8c:d9:8f:00:b2:04:e9:80:09:98:ec:f8:42:7e",
            "AA:BB:CC:DD:EE:FF:11:22:33:44",
            "blob deadbeefcafebabe0123456789abcdef",
            "sha256 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "uuid 550E8400-E29B-41D4-A716-446655440000",
            "at /Users/x/File.swift:42:10 in body"
        ]
    )
    func keepsNonAddresses(input: String) {
        #expect(input.redactIPs() == input, "over-redacting makes diagnostic reports unreadable")
    }
}
