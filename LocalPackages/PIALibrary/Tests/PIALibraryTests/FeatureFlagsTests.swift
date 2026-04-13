//
//  FeatureFlagsTests.swift
//  PIALibrary
//
//  Created by Mario on 23/03/2026.
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

@Suite("FeatureFlagHolder Tests")
struct FeatureFlagHolderTests {
    @Test("Default to false", arguments: FeatureFlag.allCases)
    func defaultToFalse(flag: FeatureFlag) {
        let holder = FeatureFlagHolder()
        #expect(holder[flag] == false, "flags should default to false")
    }

    @Test("Set after configure", arguments: FeatureFlag.allCases)
    func configureHolder(flag: FeatureFlag) {
        let holder = FeatureFlagHolder()
        holder.configure(with: CollectionOfOne(flag))
        #expect(holder[flag] == true, "flags should be set after configure")
    }

    @Test("Raw values can be used", arguments: CollectionOfOne(FeatureFlag.allCases))
    func configureRawValues(flags: [FeatureFlag]) {
        let holder = FeatureFlagHolder()
        holder.configure(with: flags.map(\.rawValue))
        for flag in flags {
            #expect(holder[flag] == true, "flags should be set after configuring raw strings")
        }
    }
}
