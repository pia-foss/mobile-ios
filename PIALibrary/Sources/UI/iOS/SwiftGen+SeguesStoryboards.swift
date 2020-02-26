// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum Signup: String, SegueType {
    case failureSegueIdentifier = "FailureSegueIdentifier"
    case internetUnreachableSegueIdentifier = "InternetUnreachableSegueIdentifier"
    case successSegueIdentifier = "SuccessSegueIdentifier"
    case unwindFailureSegueIdentifier = "UnwindFailureSegueIdentifier"
    case unwindInternetUnreachableSegueIdentifier = "UnwindInternetUnreachableSegueIdentifier"
  }
  internal enum Welcome: String, SegueType {
    case confirmPurchaseVPNPlanSegue = "ConfirmPurchaseVPNPlanSegue"
    case loginAccountSegue = "LoginAccountSegue"
    case presentGDPRTermsSegue = "PresentGDPRTermsSegue"
    case purchaseVPNPlanSegue = "PurchaseVPNPlanSegue"
    case restoreLoginPurchaseSegue = "RestoreLoginPurchaseSegue"
    case restorePurchaseSegue = "RestorePurchaseSegue"
    case showTermsAndConditionsSegue = "ShowTermsAndConditionsSegue"
    case signupViaPurchaseSegue = "SignupViaPurchaseSegue"
    case signupViaRecoverSegue = "SignupViaRecoverSegue"
    case signupViaRestoreSegue = "SignupViaRestoreSegue"
    case subscribeNowVPNPlanSegue = "SubscribeNowVPNPlanSegue"
    case viewMoreVPNPlansSegue = "ViewMoreVPNPlansSegue"
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol SegueType: RawRepresentable {}

internal extension UIViewController {
  func perform<S: SegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    let identifier = segue.rawValue
    performSegue(withIdentifier: identifier, sender: sender)
  }
}

internal extension SegueType where RawValue == String {
  init?(_ segue: UIStoryboardSegue) {
    guard let identifier = segue.identifier else { return nil }
    self.init(rawValue: identifier)
  }
}

private final class BundleToken {}
