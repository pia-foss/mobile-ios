// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import SideMenu
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Segues

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardSegue {
  internal enum Main: String, SegueType {
    case aboutSegueIdentifier = "AboutSegueIdentifier"
    case accountSegueIdentifier = "AccountSegueIdentifier"
    case contentBlockerSegueIdentifier = "ContentBlockerSegueIdentifier"
    case customDNSSegueIdentifier = "CustomDNSSegueIdentifier"
    case customServerSegueIdentifier = "CustomServerSegueIdentifier"
    case menuSegueIdentifier = "MenuSegueIdentifier"
    case selectRegionAnimatedSegueIdentifier = "SelectRegionAnimatedSegueIdentifier"
    case selectRegionSegueIdentifier = "SelectRegionSegueIdentifier"
    case settingsSegueIdentifier = "SettingsSegueIdentifier"
    case showAddEmailSegue = "ShowAddEmailSegue"
    case showQuickSettingsViewController = "ShowQuickSettingsViewController"
    case trustedNetworksSegueIdentifier = "TrustedNetworksSegueIdentifier"
    case unwindContentBlockerSegueIdentifier = "UnwindContentBlockerSegueIdentifier"
    case unwindRegionsSegueIdentifier = "UnwindRegionsSegueIdentifier"
    case showReferralInvites = "show-referral-invites"
    case viewFriendReferralSignups = "view-friend-referral-signups"
    case viewFriendReferralStatus = "view-friend-referral-status"
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
