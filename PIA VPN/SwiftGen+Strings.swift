// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {

  enum About {
    /// VPN by Private Internet Access
    static let app = L10n.tr("Localizable", "about.app")
    /// This program uses the following components:
    static let intro = L10n.tr("Localizable", "about.intro")

    enum Accessibility {

      enum Component {
        /// Tap to read full license
        static let expand = L10n.tr("Localizable", "about.accessibility.component.expand")
      }
    }
  }

  enum Account {

    enum Accessibility {
      /// Eye icon
      static let eye = L10n.tr("Localizable", "account.accessibility.eye")

      enum Eye {

        enum Hint {
          /// Tap to conceal password
          static let conceal = L10n.tr("Localizable", "account.accessibility.eye.hint.conceal")
          /// Tap to reveal password
          static let reveal = L10n.tr("Localizable", "account.accessibility.eye.hint.reveal")
        }
      }
    }

    enum Email {
      /// Email
      static let caption = L10n.tr("Localizable", "account.email.caption")
      /// Email address
      static let placeholder = L10n.tr("Localizable", "account.email.placeholder")
    }

    enum Eye {
      /// Tap the eye icon to reveal or conceal your password.
      static let footer = L10n.tr("Localizable", "account.eye.footer")
    }

    enum Other {
      /// Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.
      static let footer = L10n.tr("Localizable", "account.other.footer")
    }

    enum Password {
      /// Password
      static let caption = L10n.tr("Localizable", "account.password.caption")
    }

    enum Restore {
      /// RESTORE PURCHASE
      static let button = L10n.tr("Localizable", "account.restore.button")
      /// If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.
      static let description = L10n.tr("Localizable", "account.restore.description")
      /// Restore uncredited purchase
      static let title = L10n.tr("Localizable", "account.restore.title")

      enum Failure {
        /// No redeemable purchase was found for renewal.
        static let message = L10n.tr("Localizable", "account.restore.failure.message")
        /// Restore purchase
        static let title = L10n.tr("Localizable", "account.restore.failure.title")
      }
    }

    enum Reveal {
      /// Authenticate to reveal
      static let prompt = L10n.tr("Localizable", "account.reveal.prompt")
    }

    enum Save {
      /// Update
      static let item = L10n.tr("Localizable", "account.save.item")
      /// Authenticate to save changes
      static let prompt = L10n.tr("Localizable", "account.save.prompt")
      /// Your email address has been saved.
      static let success = L10n.tr("Localizable", "account.save.success")
    }

    enum Username {
      /// Username
      static let caption = L10n.tr("Localizable", "account.username.caption")
    }
  }

  enum ContentBlocker {
    /// Content Blocker
    static let title = L10n.tr("Localizable", "content_blocker.title")

    enum Body {
      /// Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.
      static let footer = L10n.tr("Localizable", "content_blocker.body.footer")
      /// To enable our Content Blocker for use with Safari please go to Settings > Safari, and under General touch Content Blockers toggle on PIA VPN.
      static let subtitle = L10n.tr("Localizable", "content_blocker.body.subtitle")
    }
  }

  enum Dashboard {
    /// Status
    static let status = L10n.tr("Localizable", "dashboard.status")

    enum Connection {

      enum Ip {
        /// PUBLIC IP
        static let caption = L10n.tr("Localizable", "dashboard.connection.ip.caption")
        /// Internet unreachable
        static let unreachable = L10n.tr("Localizable", "dashboard.connection.ip.unreachable")
      }

      enum Region {
        /// CURRENT REGION
        static let caption = L10n.tr("Localizable", "dashboard.connection.region.caption")
        /// CHANGE REGION
        static let change = L10n.tr("Localizable", "dashboard.connection.region.change")
      }
    }

    enum ContentBlocker {

      enum Intro {
        /// This version replaces MACE with our Safari Content Blocker.\n\nCheck it out in the 'Settings' section.
        static let message = L10n.tr("Localizable", "dashboard.content_blocker.intro.message")
      }
    }

    enum Vpn {
      /// Changing region...
      static let changingRegion = L10n.tr("Localizable", "dashboard.vpn.changing_region")
      /// Connected to VPN
      static let connected = L10n.tr("Localizable", "dashboard.vpn.connected")
      /// Connecting...
      static let connecting = L10n.tr("Localizable", "dashboard.vpn.connecting")
      /// Disconnected
      static let disconnected = L10n.tr("Localizable", "dashboard.vpn.disconnected")
      /// Disconnecting...
      static let disconnecting = L10n.tr("Localizable", "dashboard.vpn.disconnecting")
    }
  }

  enum Expiration {
    /// Your subscription expires soon. Renew to stay protected.
    static let message = L10n.tr("Localizable", "expiration.message")
    /// Renewal
    static let title = L10n.tr("Localizable", "expiration.title")
  }

  enum Global {
    /// Automatic
    static let automatic = L10n.tr("Localizable", "global.automatic")
    /// Cancel
    static let cancel = L10n.tr("Localizable", "global.cancel")
    /// Close
    static let close = L10n.tr("Localizable", "global.close")
    /// Error
    static let error = L10n.tr("Localizable", "global.error")
    /// OK
    static let ok = L10n.tr("Localizable", "global.ok")
  }

  enum Menu {

    enum Accessibility {
      /// Menu
      static let item = L10n.tr("Localizable", "menu.accessibility.item")
      /// Logged in as %@
      static func loggedAs(_ p1: String) -> String {
        return L10n.tr("Localizable", "menu.accessibility.logged_as", p1)
      }
    }

    enum Expiration {
      /// %d days
      static func days(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.days", p1)
      }
      /// Subscription expires in
      static let expiresIn = L10n.tr("Localizable", "menu.expiration.expires_in")
      /// %d hours
      static func hours(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.hours", p1)
      }
      /// one hour
      static let oneHour = L10n.tr("Localizable", "menu.expiration.one_hour")
      /// UPGRADE ACCOUNT
      static let upgrade = L10n.tr("Localizable", "menu.expiration.upgrade")
    }

    enum Item {
      /// About
      static let about = L10n.tr("Localizable", "menu.item.about")
      /// Account
      static let account = L10n.tr("Localizable", "menu.item.account")
      /// Log out
      static let logout = L10n.tr("Localizable", "menu.item.logout")
      /// Region selection
      static let region = L10n.tr("Localizable", "menu.item.region")
      /// Settings
      static let settings = L10n.tr("Localizable", "menu.item.settings")

      enum Web {
        /// Home page
        static let home = L10n.tr("Localizable", "menu.item.web.home")
        /// Privacy policy
        static let privacy = L10n.tr("Localizable", "menu.item.web.privacy")
        /// Support
        static let support = L10n.tr("Localizable", "menu.item.web.support")
      }
    }

    enum Logout {
      /// Log out
      static let confirm = L10n.tr("Localizable", "menu.logout.confirm")
      /// Logging out will disable the VPN and leave you unprotected.
      static let message = L10n.tr("Localizable", "menu.logout.message")
      /// Log out
      static let title = L10n.tr("Localizable", "menu.logout.title")
    }

    enum Renewal {
      /// Purchase
      static let purchase = L10n.tr("Localizable", "menu.renewal.purchase")
      /// Renew
      static let renew = L10n.tr("Localizable", "menu.renewal.renew")
      /// Renewal
      static let title = L10n.tr("Localizable", "menu.renewal.title")

      enum Message {
        /// Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.
        static let trial = L10n.tr("Localizable", "menu.renewal.message.trial")
        /// Apple servers currently unavailable. Please try again later.
        static let unavailable = L10n.tr("Localizable", "menu.renewal.message.unavailable")
        /// Please use our website to renew your subscription.
        static let website = L10n.tr("Localizable", "menu.renewal.message.website")
      }
    }
  }

  enum Notifications {

    enum Disabled {
      /// Enable notifications to get a reminder to renew your subscription before it expires.
      static let message = L10n.tr("Localizable", "notifications.disabled.message")
      /// Settings
      static let settings = L10n.tr("Localizable", "notifications.disabled.settings")
      /// Notifications disabled
      static let title = L10n.tr("Localizable", "notifications.disabled.title")
    }
  }

  enum Renewal {

    enum Failure {
      /// Your purchase receipt couldn't be submitted, please retry at a later time.
      static let message = L10n.tr("Localizable", "renewal.failure.message")
    }

    enum Success {
      /// Your account was successfully renewed.
      static let message = L10n.tr("Localizable", "renewal.success.message")
      /// Thank you
      static let title = L10n.tr("Localizable", "renewal.success.title")
    }
  }

  enum Settings {

    enum ApplicationInformation {
      /// APPLICATION INFORMATION
      static let title = L10n.tr("Localizable", "settings.application_information.title")

      enum Debug {
        /// Send debug to support
        static let title = L10n.tr("Localizable", "settings.application_information.debug.title")

        enum Empty {
          /// Debug information is empty, please attempt a connection before retrying submission.
          static let message = L10n.tr("Localizable", "settings.application_information.debug.empty.message")
          /// Empty debug information
          static let title = L10n.tr("Localizable", "settings.application_information.debug.empty.title")
        }

        enum Failure {
          /// Debug information could not be submitted. Please disconnect from the VPN and retry.
          static let message = L10n.tr("Localizable", "settings.application_information.debug.failure.message")
          /// Error during submission
          static let title = L10n.tr("Localizable", "settings.application_information.debug.failure.title")
        }

        enum Success {
          /// Debug information successfully submitted.\nID: %@\nPlease note this ID, as our support team will require this to locate your submission.
          static func message(_ p1: String) -> String {
            return L10n.tr("Localizable", "settings.application_information.debug.success.message", p1)
          }
          /// Debug information submitted
          static let title = L10n.tr("Localizable", "settings.application_information.debug.success.title")
        }
      }
    }

    enum ApplicationSettings {
      /// APPLICATION SETTINGS
      static let title = L10n.tr("Localizable", "settings.application_settings.title")

      enum DarkTheme {
        /// Dark theme
        static let title = L10n.tr("Localizable", "settings.application_settings.dark_theme.title")
      }

      enum Mace {
        /// PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.
        static let footer = L10n.tr("Localizable", "settings.application_settings.mace.footer")
        /// PIA MACE™
        static let title = L10n.tr("Localizable", "settings.application_settings.mace.title")
      }

      enum Persistent {
        /// Automatically reconnect
        static let title = L10n.tr("Localizable", "settings.application_settings.persistent.title")

        enum Footer {
          /// Disabling automatic reconnection may put your privacy at risk when your device does not have access to a stable network.
          static let disabled = L10n.tr("Localizable", "settings.application_settings.persistent.footer.disabled")
        }
      }
    }

    enum Commit {

      enum Buttons {
        /// Later
        static let later = L10n.tr("Localizable", "settings.commit.buttons.later")
        /// Reconnect
        static let reconnect = L10n.tr("Localizable", "settings.commit.buttons.reconnect")
      }

      enum Messages {
        /// The VPN must reconnect for some changes to take effect.
        static let mustDisconnect = L10n.tr("Localizable", "settings.commit.messages.must_disconnect")
        /// Reconnect the VPN to apply changes.
        static let shouldReconnect = L10n.tr("Localizable", "settings.commit.messages.should_reconnect")
      }
    }

    enum Connection {
      /// CONNECTION
      static let title = L10n.tr("Localizable", "settings.connection.title")

      enum RemotePort {
        /// Remote port
        static let title = L10n.tr("Localizable", "settings.connection.remote_port.title")
      }

      enum SocketProtocol {
        /// Socket
        static let title = L10n.tr("Localizable", "settings.connection.socket_protocol.title")
      }

      enum VpnProtocol {
        /// Protocol
        static let title = L10n.tr("Localizable", "settings.connection.vpn_protocol.title")
      }
    }

    enum ContentBlocker {
      /// To enable or disable Content Blocker go to Settings > Safari > Content Blockers and toggle PIA VPN.
      static let footer = L10n.tr("Localizable", "settings.content_blocker.footer")
      /// Safari Content Blocker
      static let title = L10n.tr("Localizable", "settings.content_blocker.title")

      enum Refresh {
        /// Refresh block list
        static let title = L10n.tr("Localizable", "settings.content_blocker.refresh.title")
      }

      enum State {
        /// Current state
        static let title = L10n.tr("Localizable", "settings.content_blocker.state.title")
      }
    }

    enum Encryption {
      /// ENCRYPTION
      static let title = L10n.tr("Localizable", "settings.encryption.title")

      enum Cipher {
        /// Data encryption
        static let title = L10n.tr("Localizable", "settings.encryption.cipher.title")
      }

      enum Digest {
        /// Data authentication
        static let title = L10n.tr("Localizable", "settings.encryption.digest.title")
      }

      enum Handshake {
        /// Handshake
        static let title = L10n.tr("Localizable", "settings.encryption.handshake.title")
      }
    }

    enum Reset {
      /// This will reset all of the above settings to default.
      static let footer = L10n.tr("Localizable", "settings.reset.footer")
      /// RESET
      static let title = L10n.tr("Localizable", "settings.reset.title")

      enum Defaults {
        /// Reset to default settings
        static let title = L10n.tr("Localizable", "settings.reset.defaults.title")

        enum Confirm {
          /// Reset
          static let button = L10n.tr("Localizable", "settings.reset.defaults.confirm.button")
          /// This will bring the app back to default. You will lose all changes you have made.
          static let message = L10n.tr("Localizable", "settings.reset.defaults.confirm.message")
          /// Reset settings
          static let title = L10n.tr("Localizable", "settings.reset.defaults.confirm.title")
        }
      }
    }
  }

  enum Shortcuts {
    /// Connect
    static let connect = L10n.tr("Localizable", "shortcuts.connect")
    /// Disconnect
    static let disconnect = L10n.tr("Localizable", "shortcuts.disconnect")
    /// Select a region
    static let selectRegion = L10n.tr("Localizable", "shortcuts.select_region")
  }

  enum VpnPermission {
    /// PIA
    static let title = L10n.tr("Localizable", "vpn_permission.title")

    enum Body {
      /// We don’t monitor, filter or log any network activity.
      static let footer = L10n.tr("Localizable", "vpn_permission.body.footer")
      /// To proceed tap “%@”.
      static func subtitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "vpn_permission.body.subtitle", p1)
      }
      /// PIA needs access to your VPN profiles to secure your traffic
      static let title = L10n.tr("Localizable", "vpn_permission.body.title")
    }

    enum Disallow {
      /// Contact
      static let contact = L10n.tr("Localizable", "vpn_permission.disallow.contact")

      enum Message {
        /// We need this permission for the application to function.
        static let basic = L10n.tr("Localizable", "vpn_permission.disallow.message.basic")
        /// You can also get in touch with customer support if you need assistance.
        static let support = L10n.tr("Localizable", "vpn_permission.disallow.message.support")
      }
    }
  }

  enum Walkthrough {

    enum Action {
      /// DONE
      static let done = L10n.tr("Localizable", "walkthrough.action.done")
      /// NEXT
      static let next = L10n.tr("Localizable", "walkthrough.action.next")
      /// SKIP
      static let skip = L10n.tr("Localizable", "walkthrough.action.skip")
    }

    enum Page {

      enum _1 {
        /// Protect yourself on up to 5 devices at a time.
        static let description = L10n.tr("Localizable", "walkthrough.page.1.description")
        /// Support 5 devices at once
        static let title = L10n.tr("Localizable", "walkthrough.page.1.title")
      }

      enum _2 {
        /// With servers around the globe, you are always under protection.
        static let description = L10n.tr("Localizable", "walkthrough.page.2.description")
        /// Connect to any region easily
        static let title = L10n.tr("Localizable", "walkthrough.page.2.title")
      }

      enum _3 {
        /// Enabling our Content Blocker prevents ads from showing in Safari.
        static let description = L10n.tr("Localizable", "walkthrough.page.3.description")
        /// Protect yourself from ads
        static let title = L10n.tr("Localizable", "walkthrough.page.3.title")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
