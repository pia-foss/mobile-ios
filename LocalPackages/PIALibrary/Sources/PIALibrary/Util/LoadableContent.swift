//
//  LoadableContent.swift
//  PIALibrary
//
//  Created by Diego Trevisan on 06.01.26.
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

/// Represents the loading state of content that may be asynchronously loaded.
///
/// This enum provides a type-safe way to handle content that can be in one of three states:
/// loading, successfully loaded, or failed with an error.
///
/// - Generic Parameters:
///   - Data: The type of the successfully loaded content
///   - ErrorType: The type of error that can occur (defaults to Error)
///
/// Usage example:
/// ```swift
/// var userState: LoadableContent<User> = .loading
///
/// // After loading succeeds
/// userState = .loaded(user)
///
/// // After loading fails
/// userState = .error(someError)
/// ```
public enum LoadableContent<Data, ErrorType: Error> {
    /// Content is currently being loaded
    case loading

    /// Content has been successfully loaded with associated data
    case loaded(Data)

    /// Content failed to load with associated error
    case error(ErrorType)
}

// MARK: - Convenience Extensions

public extension LoadableContent {
    /// Returns the loaded data if available, nil otherwise
    var data: Data? {
        if case .loaded(let data) = self {
            return data
        }
        return nil
    }

    /// Returns the error if available, nil otherwise
    var error: ErrorType? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }

    /// Returns true if content is currently loading
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    /// Returns true if content has been successfully loaded
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }

    /// Returns true if content failed to load
    var isError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}

// MARK: - Equatable

extension LoadableContent: Equatable where Data: Equatable, ErrorType: Equatable {}

// MARK: - Hashable

extension LoadableContent: Hashable where Data: Hashable, ErrorType: Hashable {}
