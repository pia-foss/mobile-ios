//
//  ValidatorTests.swift
//  PIALibraryTests-iOS
//
//  Created by Jose Antonio Blaya Garcia on 20/8/18.
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

import Testing
@testable import PIALibrary

@Suite("Email Validation Tests")
struct ValidatorTests {

    // MARK: - Valid Email Tests

    @Test("Valid email addresses should pass validation")
    func validEmails() throws {
        let validEmails = [
            "user@example.com",
            "test.user@example.com",
            "test+tag@example.co.uk",
            "user123@test-domain.com",
            "first.last@subdomain.example.org",
            "a@example.com",
            "test_user@example.com"
        ]

        for email in validEmails {
            try Validator.validate(email: email)
        }
    }

    // MARK: - Empty Email Tests

    @Test("Nil email should throw emailIsEmpty error")
    func nilEmail() {
        #expect(throws: Validator.EmailValidationError.emailIsEmpty) {
            try Validator.validate(email: nil)
        }
    }

    @Test("Empty string should throw emailIsEmpty error")
    func emptyEmail() {
        #expect(throws: Validator.EmailValidationError.emailIsEmpty) {
            try Validator.validate(email: "")
        }
    }

    @Test("Whitespace-only email should throw emailIsInvalid error")
    func whitespaceOnlyEmail() {
        #expect(throws: Validator.EmailValidationError.emailIsInvalid) {
            try Validator.validate(email: "   ")
        }
    }

    // MARK: - Invalid Email Tests

    @Test("Invalid email formats should throw emailIsInvalid error", arguments: [
        "plaintext",
        "@example.com",
        "user@",
        "user @example.com",
        "user@example .com",
        "user@.com",
        "user@example.",
        "user..name@example.com",
        "user@example..com",
        "user@-example.com",
        "user@example-.com",
        "user@example",
        "user name@example.com",
        "user@exam ple.com",
        ".user@example.com",
        "user.@example.com",
        "user@@example.com",
        "user@example@com",
    ])
    func invalidEmails(email: String) {
        #expect(throws: Validator.EmailValidationError.emailIsInvalid) {
            try Validator.validate(email: email)
        }
    }

    // MARK: - Edge Cases

    @Test("Email with leading/trailing spaces should be handled by caller")
    func emailWithSpaces() {
        // Note: The validator expects trimmed input
        // The UI layer should trim before validation
        #expect(throws: Validator.EmailValidationError.emailIsInvalid) {
            try Validator.validate(email: " user@example.com ")
        }
    }

    @Test("Very long valid email should pass")
    func longValidEmail() throws {
        let longEmail = "very.long.email.address.with.many.parts@very.long.domain.name.example.com"
        try Validator.validate(email: longEmail)
    }
}
