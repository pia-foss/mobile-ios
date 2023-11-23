
import XCTest

extension XCUIApplication {
    var loginButton: XCUIElement {
        button(with: PIALibraryAccessibility.Id.Login.submit)
    }
  
    var loginUsernameTextField: XCUIElement {
        textField(with: PIALibraryAccessibility.Id.Login.username)
    }
    
    var loginPasswordTextField: XCUIElement {
        secureTextField(with: PIALibraryAccessibility.Id.Login.password)
    }
    
    var loginErrorMessage: XCUIElement {
        otherElement(with: PIALibraryAccessibility.Id.Login.Error.banner)
    }
    
    func logIn(with credentials: Credentials) {
        loginUsernameTextField.waitForExistence(timeout: defaultTimeout) && loginPasswordTextField.waitForExistence(timeout: defaultTimeout)
        loginUsernameTextField.tap()
        loginUsernameTextField.typeText(credentials.username)
        loginPasswordTextField.tap()
        loginPasswordTextField.typeText(credentials.password)
        loginButton.tap()
    }
    
    /// This method authenticates the user and installs the VPN profile
    /// Use this method when we are testing flows where the app has to be logged in already.
    /// In such cases, it is recommended to call this method from the `setUp` of each `XCTestCase` class
    /// NOTE: the app must be already in the Login Screen for this method to work
    /// So before calling this method, make sure to navigate to the login screen
    func loginAndInstallVPNProfile(from test: XCTestCase) {
        // Listens to any interruption due to a system alert permission
        // and presses the 'Allow' button
        // (like the VPN Permission system alert)
        dismissAnyPermissionSystemAlert(from: test)
        
        // Log out if needed
        logOut()
        
        navigateToLoginScreen()
        logIn(with: CredentialsUtil.credentials(type: .valid))
        
        guard vpnPermissionScreen.waitForExistence(timeout: defaultTimeout) else { return }
        guard vpnPermissionButton.exists else { return }
        vpnPermissionButton.tap()
        
        swipeUp()
        
        WaitHelper.waitForElementToBeVisible(connectionButton, timeout: defaultTimeout,
                                             onSuccess:{print("successful login")}, onFailure:{error in print("connectionButton is not visible")})

    }
}
