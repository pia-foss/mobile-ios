import PIAAccessibility
import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement { button(with: AccessibilityID.Login.submit) }
    var loginUsernameTextField: XCUIElement { textField(with: AccessibilityID.Login.username) }
    var loginPasswordTextField: XCUIElement { secureTextField(with: AccessibilityID.Login.password) }
    var loginErrorMessage: XCUIElement { otherElement(with: AccessibilityID.Login.errorBanner) }

    func logIn(with credentials: Credentials) {
        XCTAssertTrue(loginUsernameTextField.waitForElementToAppear(), "Login username text field not found")
        XCTAssertTrue(loginPasswordTextField.waitForElementToAppear(), "Login password text field not found")
        loginUsernameTextField.tap()
        loginUsernameTextField.typeText(credentials.username)
        // Move between fields and submit with Return (LoginView's onSubmit) rather than tapping: when the device has a
        // saved password for the typed username, iOS Password AutoFill draws a suggestion over the password field and,
        // once that field has focus, over the submit button. A tap there fills in the saved password or dismisses the
        // suggestion instead.
        loginUsernameTextField.typeText("\n")
        loginPasswordTextField.typeText(credentials.password)

        // Fail here, with a clear reason, rather than later on a screen that never appears.
        XCTAssertEqual(
            loginUsernameTextField.value as? String,
            credentials.username,
            "Username field doesn't hold the typed username"
        )
        XCTAssertEqual(
            (loginPasswordTextField.value as? String)?.count,
            credentials.password.count,
            "Password field doesn't hold just the typed password; iOS Password AutoFill may have inserted text"
        )
        loginPasswordTextField.typeText("\n")
    }
}
