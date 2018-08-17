// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

protocol StoryboardType {
  static var storyboardName: String { get }
}

extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

struct SceneType<T: Any> {
  let storyboard: StoryboardType.Type
  let identifier: String

  func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

struct InitialSceneType<T: Any> {
  let storyboard: StoryboardType.Type

  func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

protocol SegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
enum StoryboardScene {
  enum Signup: StoryboardType {
    static let storyboardName = "Signup"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: Signup.self)
  }
  enum Welcome: StoryboardType {
    static let storyboardName = "Welcome"

    static let initialScene = InitialSceneType<UINavigationController>(storyboard: Welcome.self)

    static let loginViewController = SceneType<PIALibrary.LoginViewController>(storyboard: Welcome.self, identifier: "LoginViewController")

    static let purchaseViewController = SceneType<PIALibrary.PurchaseViewController>(storyboard: Welcome.self, identifier: "PurchaseViewController")

    static let redeemViewController = SceneType<PIALibrary.RedeemViewController>(storyboard: Welcome.self, identifier: "RedeemViewController")
  }
}

enum StoryboardSegue {
  enum Signup: String, SegueType {
    case failureSegueIdentifier = "FailureSegueIdentifier"
    case internetUnreachableSegueIdentifier = "InternetUnreachableSegueIdentifier"
    case successSegueIdentifier = "SuccessSegueIdentifier"
    case unwindFailureSegueIdentifier = "UnwindFailureSegueIdentifier"
    case unwindInternetUnreachableSegueIdentifier = "UnwindInternetUnreachableSegueIdentifier"
  }
  enum Welcome: String, SegueType {
    case signupViaPurchaseSegue = "SignupViaPurchaseSegue"
    case signupViaRecoverSegue = "SignupViaRecoverSegue"
    case signupViaRedeemSegue = "SignupViaRedeemSegue"
    case signupViaRestoreSegue = "SignupViaRestoreSegue"
    case signupQRCameraScannerSegue = "SignupQRCameraScannerSegue"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

private final class BundleToken {}
