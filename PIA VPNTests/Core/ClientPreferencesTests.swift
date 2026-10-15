//
//  ClientPreferencesTests.swift
//  PIA VPNTests
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

import Testing

/// Parent of every suite that writes `Client.preferences`.
///
/// The preferences are process-wide, and committing an editable copy writes back every field, so two
/// suites touching them at the same time overwrite each other's setup. `.serialized` here runs the
/// nested suites one after another, not just the tests inside each one.
@Suite(.serialized)
enum ClientPreferencesTests {}
