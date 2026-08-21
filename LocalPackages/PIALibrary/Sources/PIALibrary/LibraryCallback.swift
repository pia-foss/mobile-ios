//
//  LibraryCallback.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 10/1/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

/// The standard generic callback type used across the library. Returns a generic object and an optional `Error`. Normally a `nil` object implies a non-`nil` error and viceversa.
public typealias LibraryCallback<T> = (T?, Error?) -> Void

/// A simple callback returning `nil` on success and `Error` on failure.
public typealias SuccessLibraryCallback = (Error?) -> Void

// MARK: ClientError

/// Result that contains either value `T` or error ``ClientError``.
public typealias ClientResult<T> = Result<T, ClientError>

/// Callback that returns either a value or a ``ClientError``.
public typealias ClientCallback<T> = (ClientResult<T>) -> Void

/// Simple callback that doesn't return a value, but can return a ``ClientError``.
public typealias SuccessClientCallback = ClientCallback<Void>
