//
//  FeatureFlagHolder.swift
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

private let log = PIALogger.logger(for: FeatureFlag.self)

/// Data structure that holds current feature flag values.
///
/// Feature flags are boolean values, they are either set (`true`)
/// or not (`false`). Flags are configured via the CSI tool.
/// All flags default to `false`.
///
/// ```swift
/// let flags = FeatureFlagHolder()
/// let isFeatureEnabled: Bool = flags[.feature]
/// ```
public final class FeatureFlagHolder: Sendable {
    private let flags = Mutex<Set<FeatureFlag>>(Set())

    /// Returns `true` if the feature flag is set.
    public subscript(_ flag: FeatureFlag) -> Bool {
        return flags.withLock { flags in
            flags.contains(flag)
        }
    }

    /// Configures the holder with the new flags, discarding the old values.
    public func configure(with strings: any Collection<String>) {
        let parsed = FeatureFlagHolder.parse(strings: strings)
        return configure(with: parsed)
    }

    /// Configures the holder with the new flags, discarding the old values.
    public func configure(with newValues: any Collection<FeatureFlag>) {
        let newFlags = newValues.map(\.rawValue).joined(separator: ", ")
        log.debug("Configure new flags: \(newFlags)")
        flags.withLock { flags in
            flags.removeAll()
            flags.formUnion(newValues)
        }
    }

    private static func parse(strings: any Collection<String>) -> [FeatureFlag] {
        return strings.compactMap { string in
            if let flag = FeatureFlag(rawValue: string) {
                return flag
            }
            log.warning("Unknown feature flag name: \(string)")
            return nil
        }
    }
}
