import PIAAccessibility
import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement { button(with: AccessibilityID.Login.submit) }
    var loginUsernameTextField: XCUIElement { textField(with: AccessibilityID.Login.username) }
    var loginPasswordTextField: XCUIElement { secureTextField(with: AccessibilityID.Login.password) }
    var loginErrorMessage: XCUIElement { otherElement(with: AccessibilityID.Login.errorBanner) }

    func logIn(with credentials: Credentials) {
        loginUsernameTextField.waitForElementToAppear()
        loginPasswordTextField.waitForElementToAppear()
        loginUsernameTextField.tap()
        loginUsernameTextField.typeText(credentials.username)
        loginPasswordTextField.tap()
        loginPasswordTextField.typeText(credentials.password)
        loginButton.tap()
    }
}
