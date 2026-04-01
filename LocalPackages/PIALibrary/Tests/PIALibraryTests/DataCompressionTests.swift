//
//  DataCompressionTests.swift
//  PIALibraryTests
//
//  Created by Diego Trevisan on 29/12/25.
//  Copyright © 2025 Private Internet Access, Inc.
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

import Testing
import Foundation
@testable import PIALibrary

@Suite("Data Compression Tests")
struct DataCompressionTests {

    @Test("Compress and decompress simple text")
    func compressAndDecompressSimpleText() throws {
        let original = "This is a test"
        let originalData = original.data(using: .utf8)!
        let compressed = try originalData.deflated()

        let decompressed = try compressed.inflated()
        let decompressedString = String(data: decompressed, encoding: .utf8)
        #expect(decompressedString == original, "Decompressed string should match original")
    }

    @Test("Compress and decompress longer text")
    func compressAndDecompressLongerText() throws {
        let original = String(repeating: "The quick brown fox jumps over the lazy dog.", count: 100)
        let originalData = original.data(using: .utf8)!
        let compressed = try originalData.deflated()
        #expect(compressed.count < originalData.count, "Compressed data should be smaller for repetitive text")

        let decompressed = try compressed.inflated()
        let decompressedString = String(data: decompressed, encoding: .utf8)
        #expect(decompressedString == original, "Decompressed string should match original")
    }

    @Test("Handle empty data")
    func handleEmptyData() throws {
        let emptyData = Data()
        let compressed = try emptyData.deflated()
        #expect(compressed.isEmpty, "Compressed empty data should be empty")

        let decompressed = try emptyData.inflated()
        #expect(decompressed.isEmpty, "Decompressed empty data should be empty")
    }

    @Test("Compress binary data")
    func compressBinaryData() throws {
        let binaryData = Data([0x00, 0x01, 0x02, 0x03, 0xFF, 0xFE, 0xFD, 0xFC])
        let compressed = try binaryData.deflated()

        let decompressed = try compressed.inflated()
        #expect(decompressed == binaryData, "Decompressed binary data should match original")
    }

    @Test("Handle large data")
    func handleLargeData() throws {
        let largeData = Data(repeating: 0x42, count: 1024 * 1024) // (1MB)
        let compressed = try largeData.deflated()
        #expect(compressed.count < largeData.count, "Compressed large data should be much smaller")

        let decompressed = try compressed.inflated()
        #expect(decompressed == largeData, "Decompressed large data should match original")
    }

    @Test("Round-trip compression maintains data integrity")
    func roundTripCompressionIntegrity() throws {
        let testStrings = [
            "Hello, World!",
            "1234567890",
            "Special chars: !@#$%^&*()",
            "Unicode: 你好世界 🌍",
            "Mixed: abc123!@# 你好"
        ]

        for testString in testStrings {
            let originalData = testString.data(using: .utf8)!
            let compressed = try originalData.deflated()

            let decompressed = try compressed.inflated()
            let result = String(data: decompressed, encoding: .utf8)
            #expect(result == testString, "Round-trip should preserve: \(testString)")
        }
    }
}
