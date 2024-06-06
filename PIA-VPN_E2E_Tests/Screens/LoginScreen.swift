
import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement {button(with: PIALibraryAccessibility.Id.Login.submit)}
    var loginUsernameTextField: XCUIElement {textField(with: PIALibraryAccessibility.Id.Login.username)}
    var loginPasswordTextField: XCUIElement {secureTextField(with: PIALibraryAccessibility.Id.Login.password)}
    var loginErrorMessage: XCUIElement {otherElement(with: PIALibraryAccessibility.Id.Login.Error.banner)}
    
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
