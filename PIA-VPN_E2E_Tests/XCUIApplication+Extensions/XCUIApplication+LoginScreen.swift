
import XCTest

// MARK: XCUIApplication + Welcome Screen UI elements

extension XCUIApplication {
  var goToLoginScreenButton: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submitNew)
  }
}

// MARK: XCUIApplication + Login Screen UI elements

extension XCUIApplication {
  var loginButton: XCUIElement {
    button(with: PIALibraryAccessibility.Id.Login.submit)
  }
  
  var willDisplayLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).waitForExistence(timeout: shortTimeout)
  }
  
  var isDisplayingLoginErrorBanner: Bool {
    view(with: PIALibraryAccessibility.Id.Login.Error.banner).exists
  }
  
  var willDisplayVpnPermissionScreen: Bool {
    view(with: AccessibilityId.VPNPermission.screen).waitForExistence(timeout: shortTimeout)
  }
}
