
import XCTest


// MARK: XCUIApplication + Login Screen UI elements

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
  
  
  var willDisplayLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).waitForExistence(timeout: shortTimeout)
  }
  
  var isDisplayingLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).exists
  }
  
  var willDisplayVpnPermissionScreen: Bool {
    view(with: AccessibilityId.VPNPermission.screen).waitForExistence(timeout: defaultTimeout)
  }
}
