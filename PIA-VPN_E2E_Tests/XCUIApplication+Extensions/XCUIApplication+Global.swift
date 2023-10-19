
import XCTest

extension XCUIApplication {
    var defaultTimeout: TimeInterval { 10.0 }
    var shortTimeout: TimeInterval { 5.0 }
    
    func view(with id: String) -> XCUIElement {
        return otherElements[id]
    }
    
    func button(with id: String) -> XCUIElement {
        return buttons[id]
    }
    
    func textField(with id: String) -> XCUIElement {
        return textFields[id]
    }
    
    func cell(with id: String) -> XCUIElement {
        return cells[id]
    }
    
    func secureTextField(with id: String) -> XCUIElement {
        return secureTextFields[id]
    }
}


extension XCUIApplication {
    // This method navigates to the login screen from the Welcome screen
    func navigateToLoginScreenIfNeeded() {
        if goToLoginScreenButton.waitForExistence(timeout: shortTimeout) {
            goToLoginScreenButton.tap()
        } else {
            if goToLoginScreenButtonOldVersion.waitForExistence(timeout: shortTimeout) {
                goToLoginScreenButtonOldVersion.tap()
            }
        }
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
        
        // Logs Out if needed
        logOutIfNeeded()
        
        // Goes To the Login Screen
        navigateToLoginScreenIfNeeded()
        
        // Fills in valid credentials in the login screen
        // The credentials are set in Environment Variables
        let credentials = CredentialsUtil.credentials(type: .valid)
        
        let usernameTextField = textField(with: PIALibraryAccessibility.Id.Login.username)
        
        let passwordTextField = secureTextField(with: PIALibraryAccessibility.Id.Login.password)
        
        guard usernameTextField.exists, passwordTextField.exists else {
            XCTFail("XCUIApplication: failed to find username and password fields in screen to authenticate user")
            return
        }
        
        guard loginButton.exists else {
            XCTFail("XCUIApplication: failed to find LOGIN button in screen to authenticate user")
            return
        }
        
        // Type username
        usernameTextField.tap()
        usernameTextField.typeText(credentials.username)
        
        // Type password
        passwordTextField.tap()
        passwordTextField.typeText(credentials.password)
        
        loginButton.tap()
        
        guard vpnPermissionScreen.waitForExistence(timeout: app.defaultTimeout) else {
            XCTFail("XCUIApplication: login failed")
            return
        }
        
        let vpnPermissionButton = button(with: AccessibilityId.VPNPermission.submit)
        
        guard vpnPermissionButton.exists else {
            XCTFail("XCUIApplication: can't find the VPN permission submit button")
            return
        }
        
        vpnPermissionButton.tap()
        
        swipeUp()
        
        let connectionButtonExists = connectionButton.waitForExistence(timeout: defaultTimeout)
        XCTAssertTrue(connectionButtonExists)
        XCTAssertTrue(connectionButton.isHittable)
    }
    
    
    /// Sometimes a system alert to request permissions about Notifications or VPN profile installation can appear
    /// at any time when the app is running
    /// This makes not possible to contitnue with the test unless the alert is dismissed
    /// This method dismisses any system alert by pressing 'Allow' button
    /// It is adviced that we call this method from all the `setUp` method of the tests from the authentication flow
    /// For tests where we require the app to be authenticated,
    /// use the method `loginAndInstallVPNProfile(from test: XCTestCase)` from the `setUp` method of the `XCTestCase`
    func dismissAnyPermissionSystemAlert(from test: XCTestCase) {
        test.addUIInterruptionMonitor(withDescription: "Any system permission alert") { element in
           
            let allowButton = element.buttons["Allow"].firstMatch
            if element.elementType == .alert && allowButton.exists {
                allowButton.tap()
                return true
            } else {
                return false
            }
        }
    }
    
    // Logs out from the Dashboard screen (Home screen)
    // If the app is showing other view, then this flow does not work
    func logOutIfNeeded() {
        guard dashboardMenuButton.exists else { return }
        
        dashboardMenuButton.tap()
        
        let logOutButton = cell(with: PIALibraryAccessibility.Id.Menu.logout).firstMatch
        
        if logOutButton.waitForExistence(timeout: defaultTimeout) {
            logOutButton.tap()
            
            let confirmationDialogButton = button(with: PIALibraryAccessibility.Id.Dialog.destructive)
            
            if confirmationDialogButton.waitForExistence(timeout: shortTimeout) {
                confirmationDialogButton.tap()
            }
            
            let welcomeScreen = goToLoginScreenButton
            
            welcomeScreen.waitForExistence(timeout: defaultTimeout)
            
        }
    }
    
    // This method asumes that the app is already in the login screen
    func fillLoginScreen(with credentials: Credentials) {
        if loginUsernameTextField.exists && loginPasswordTextField.exists {
            // Type username
            loginUsernameTextField.tap()
            loginUsernameTextField.typeText(credentials.username)
            
            // Type password
            loginPasswordTextField.tap()
            loginPasswordTextField.typeText(credentials.password)
        } else {
            XCTFail("PIASigninE2ETests: Username and Password text fields on LoginViewController are either not identifiable or are moved")
        }
    }
}
