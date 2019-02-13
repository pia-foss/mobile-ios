// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum About {
    /// VPN by Private Internet Access
    internal static let app = L10n.tr("Localizable", "about.app")
    /// This program uses the following components:
    internal static let intro = L10n.tr("Localizable", "about.intro")
    internal enum Accessibility {
      internal enum Component {
        /// Tap to read full license
        internal static let expand = L10n.tr("Localizable", "about.accessibility.component.expand")
      }
    }
  }

  internal enum Account {
    internal enum Accessibility {
      /// Eye icon
      internal static let eye = L10n.tr("Localizable", "account.accessibility.eye")
      internal enum Eye {
        internal enum Hint {
          /// Tap to conceal password
          internal static let conceal = L10n.tr("Localizable", "account.accessibility.eye.hint.conceal")
          /// Tap to reveal password
          internal static let reveal = L10n.tr("Localizable", "account.accessibility.eye.hint.reveal")
        }
      }
    }
    internal enum Email {
      /// Email
      internal static let caption = L10n.tr("Localizable", "account.email.caption")
      /// Email address
      internal static let placeholder = L10n.tr("Localizable", "account.email.placeholder")
    }
    internal enum Error {
      /// Your username or password is incorrect.
      internal static let unauthorized = L10n.tr("Localizable", "account.error.unauthorized")
    }
    internal enum ExpiryDate {
      /// Your plan has expired.
      internal static let expired = L10n.tr("Localizable", "account.expiry_date.expired")
      /// Your plan will expire on %@.
      internal static func information(_ p1: String) -> String {
        return L10n.tr("Localizable", "account.expiry_date.information", p1)
      }
    }
    internal enum Eye {
      /// Tap the eye icon to reveal or conceal your password.
      internal static let footer = L10n.tr("Localizable", "account.eye.footer")
    }
    internal enum Other {
      /// Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.
      internal static let footer = L10n.tr("Localizable", "account.other.footer")
    }
    internal enum Password {
      /// Password
      internal static let caption = L10n.tr("Localizable", "account.password.caption")
    }
    internal enum Restore {
      /// RESTORE PURCHASE
      internal static let button = L10n.tr("Localizable", "account.restore.button")
      /// If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.
      internal static let description = L10n.tr("Localizable", "account.restore.description")
      /// Restore uncredited purchase
      internal static let title = L10n.tr("Localizable", "account.restore.title")
      internal enum Failure {
        /// No redeemable purchase was found for renewal.
        internal static let message = L10n.tr("Localizable", "account.restore.failure.message")
        /// Restore purchase
        internal static let title = L10n.tr("Localizable", "account.restore.failure.title")
      }
    }
    internal enum Reveal {
      /// Authenticate to reveal
      internal static let prompt = L10n.tr("Localizable", "account.reveal.prompt")
    }
    internal enum Save {
      /// Update email
      internal static let item = L10n.tr("Localizable", "account.save.item")
      /// Authenticate to save changes
      internal static let prompt = L10n.tr("Localizable", "account.save.prompt")
      /// Your email address has been saved.
      internal static let success = L10n.tr("Localizable", "account.save.success")
    }
    internal enum Update {
      internal enum Email {
        internal enum Require {
          internal enum Password {
            /// Submit
            internal static let button = L10n.tr("Localizable", "account.update.email.require.password.button")
            /// For security reasons we require your PIA password to perform a change in your account. Please input your PIA password to proceed.
            internal static let message = L10n.tr("Localizable", "account.update.email.require.password.message")
            /// PIA Password Required
            internal static let title = L10n.tr("Localizable", "account.update.email.require.password.title")
          }
        }
      }
    }
    internal enum Username {
      /// Username
      internal static let caption = L10n.tr("Localizable", "account.username.caption")
    }
  }

  internal enum ContentBlocker {
    /// Content Blocker
    internal static let title = L10n.tr("Localizable", "content_blocker.title")
    internal enum Body {
      /// Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.
      internal static let footer = L10n.tr("Localizable", "content_blocker.body.footer")
      /// To enable our Content Blocker for use with Safari please go to Settings > Safari, and under General touch Content Blockers toggle on PIA VPN.
      internal static let subtitle = L10n.tr("Localizable", "content_blocker.body.subtitle")
    }
  }

  internal enum Dashboard {
    /// Status
    internal static let status = L10n.tr("Localizable", "dashboard.status")
    internal enum Connection {
      internal enum Ip {
        /// PUBLIC IP
        internal static let caption = L10n.tr("Localizable", "dashboard.connection.ip.caption")
        /// Internet unreachable
        internal static let unreachable = L10n.tr("Localizable", "dashboard.connection.ip.unreachable")
      }
      internal enum Region {
        /// CURRENT REGION
        internal static let caption = L10n.tr("Localizable", "dashboard.connection.region.caption")
        /// CHANGE REGION
        internal static let change = L10n.tr("Localizable", "dashboard.connection.region.change")
      }
    }
    internal enum ContentBlocker {
      internal enum Intro {
        /// This version replaces MACE with our Safari Content Blocker.\n\nCheck it out in the 'Settings' section.
        internal static let message = L10n.tr("Localizable", "dashboard.content_blocker.intro.message")
      }
    }
    internal enum Vpn {
      /// Changing region...
      internal static let changingRegion = L10n.tr("Localizable", "dashboard.vpn.changing_region")
      /// Connected to VPN
      internal static let connected = L10n.tr("Localizable", "dashboard.vpn.connected")
      /// Connecting...
      internal static let connecting = L10n.tr("Localizable", "dashboard.vpn.connecting")
      /// Disconnected
      internal static let disconnected = L10n.tr("Localizable", "dashboard.vpn.disconnected")
      /// Disconnecting...
      internal static let disconnecting = L10n.tr("Localizable", "dashboard.vpn.disconnecting")
    }
  }

  internal enum Expiration {
    /// Your subscription expires soon. Renew to stay protected.
    internal static let message = L10n.tr("Localizable", "expiration.message")
    /// Renewal
    internal static let title = L10n.tr("Localizable", "expiration.title")
  }

  internal enum Global {
    /// Automatic
    internal static let automatic = L10n.tr("Localizable", "global.automatic")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "global.cancel")
    /// Clear
    internal static let clear = L10n.tr("Localizable", "global.clear")
    /// Close
    internal static let close = L10n.tr("Localizable", "global.close")
    /// Disabled
    internal static let disabled = L10n.tr("Localizable", "global.disabled")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "global.edit")
    /// Enabled
    internal static let enabled = L10n.tr("Localizable", "global.enabled")
    /// Error
    internal static let error = L10n.tr("Localizable", "global.error")
    /// OK
    internal static let ok = L10n.tr("Localizable", "global.ok")
    /// Optional
    internal static let `optional` = L10n.tr("Localizable", "global.optional")
    /// Required
    internal static let `required` = L10n.tr("Localizable", "global.required")
    /// Update
    internal static let update = L10n.tr("Localizable", "global.update")
  }

  internal enum Hotspothelper {
    internal enum Display {
      /// 🔒 Activate VPN WiFi Protection in PIA Settings to secure this connection.
      internal static let name = L10n.tr("Localizable", "hotspothelper.display.name")
      internal enum Protected {
        /// 🔒 PIA VPN WiFi Protection Enabled - We got your back.
        internal static let name = L10n.tr("Localizable", "hotspothelper.display.protected.name")
      }
    }
  }

  internal enum Menu {
    internal enum Accessibility {
      /// Menu
      internal static let item = L10n.tr("Localizable", "menu.accessibility.item")
      /// Logged in as %@
      internal static func loggedAs(_ p1: String) -> String {
        return L10n.tr("Localizable", "menu.accessibility.logged_as", p1)
      }
    }
    internal enum Expiration {
      /// %d days
      internal static func days(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.days", p1)
      }
      /// Subscription expires in
      internal static let expiresIn = L10n.tr("Localizable", "menu.expiration.expires_in")
      /// %d hours
      internal static func hours(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.hours", p1)
      }
      /// one hour
      internal static let oneHour = L10n.tr("Localizable", "menu.expiration.one_hour")
      /// UPGRADE ACCOUNT
      internal static let upgrade = L10n.tr("Localizable", "menu.expiration.upgrade")
    }
    internal enum Item {
      /// About
      internal static let about = L10n.tr("Localizable", "menu.item.about")
      /// Account
      internal static let account = L10n.tr("Localizable", "menu.item.account")
      /// Log out
      internal static let logout = L10n.tr("Localizable", "menu.item.logout")
      /// Region selection
      internal static let region = L10n.tr("Localizable", "menu.item.region")
      /// Settings
      internal static let settings = L10n.tr("Localizable", "menu.item.settings")
      internal enum Web {
        /// Home page
        internal static let home = L10n.tr("Localizable", "menu.item.web.home")
        /// Privacy policy
        internal static let privacy = L10n.tr("Localizable", "menu.item.web.privacy")
        /// Support
        internal static let support = L10n.tr("Localizable", "menu.item.web.support")
      }
    }
    internal enum Logout {
      /// Log out
      internal static let confirm = L10n.tr("Localizable", "menu.logout.confirm")
      /// Logging out will disable the VPN and leave you unprotected.
      internal static let message = L10n.tr("Localizable", "menu.logout.message")
      /// Log out
      internal static let title = L10n.tr("Localizable", "menu.logout.title")
    }
    internal enum Renewal {
      /// Purchase
      internal static let purchase = L10n.tr("Localizable", "menu.renewal.purchase")
      /// Renew
      internal static let renew = L10n.tr("Localizable", "menu.renewal.renew")
      /// Renewal
      internal static let title = L10n.tr("Localizable", "menu.renewal.title")
      internal enum Message {
        /// Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.
        internal static let trial = L10n.tr("Localizable", "menu.renewal.message.trial")
        /// Apple servers currently unavailable. Please try again later.
        internal static let unavailable = L10n.tr("Localizable", "menu.renewal.message.unavailable")
        /// Please use our website to renew your subscription.
        internal static let website = L10n.tr("Localizable", "menu.renewal.message.website")
      }
    }
  }

  internal enum Notifications {
    internal enum Disabled {
      /// Enable notifications to get a reminder to renew your subscription before it expires.
      internal static let message = L10n.tr("Localizable", "notifications.disabled.message")
      /// Settings
      internal static let settings = L10n.tr("Localizable", "notifications.disabled.settings")
      /// Notifications disabled
      internal static let title = L10n.tr("Localizable", "notifications.disabled.title")
    }
  }

  internal enum Renewal {
    internal enum Failure {
      /// Your purchase receipt couldn't be submitted, please retry at a later time.
      internal static let message = L10n.tr("Localizable", "renewal.failure.message")
    }
    internal enum Success {
      /// Your account was successfully renewed.
      internal static let message = L10n.tr("Localizable", "renewal.success.message")
      /// Thank you
      internal static let title = L10n.tr("Localizable", "renewal.success.title")
    }
  }

  internal enum Settings {
    internal enum ApplicationInformation {
      /// APPLICATION INFORMATION
      internal static let title = L10n.tr("Localizable", "settings.application_information.title")
      internal enum Debug {
        /// Send debug to support
        internal static let title = L10n.tr("Localizable", "settings.application_information.debug.title")
        internal enum Empty {
          /// Debug information is empty, please attempt a connection before retrying submission.
          internal static let message = L10n.tr("Localizable", "settings.application_information.debug.empty.message")
          /// Empty debug information
          internal static let title = L10n.tr("Localizable", "settings.application_information.debug.empty.title")
        }
        internal enum Failure {
          /// Debug information could not be submitted. Please disconnect from the VPN and retry.
          internal static let message = L10n.tr("Localizable", "settings.application_information.debug.failure.message")
          /// Error during submission
          internal static let title = L10n.tr("Localizable", "settings.application_information.debug.failure.title")
        }
        internal enum Success {
          /// Debug information successfully submitted.\nID: %@\nPlease note this ID, as our support team will require this to locate your submission.
          internal static func message(_ p1: String) -> String {
            return L10n.tr("Localizable", "settings.application_information.debug.success.message", p1)
          }
          /// Debug information submitted
          internal static let title = L10n.tr("Localizable", "settings.application_information.debug.success.title")
        }
      }
    }
    internal enum ApplicationSettings {
      /// APPLICATION SETTINGS
      internal static let title = L10n.tr("Localizable", "settings.application_settings.title")
      internal enum DarkTheme {
        /// Dark theme
        internal static let title = L10n.tr("Localizable", "settings.application_settings.dark_theme.title")
      }
      internal enum KillSwitch {
        /// The VPN kill switch prevents access to the Internet if the VPN connection is reconnecting. This excludes disconnecting manually.
        internal static let footer = L10n.tr("Localizable", "settings.application_settings.kill_switch.footer")
        /// VPN kill switch
        internal static let title = L10n.tr("Localizable", "settings.application_settings.kill_switch.title")
      }
      internal enum Mace {
        /// PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.
        internal static let footer = L10n.tr("Localizable", "settings.application_settings.mace.footer")
        /// PIA MACE™
        internal static let title = L10n.tr("Localizable", "settings.application_settings.mace.title")
      }
    }
    internal enum Commit {
      internal enum Buttons {
        /// Later
        internal static let later = L10n.tr("Localizable", "settings.commit.buttons.later")
        /// Reconnect
        internal static let reconnect = L10n.tr("Localizable", "settings.commit.buttons.reconnect")
      }
      internal enum Messages {
        /// The VPN must reconnect for some changes to take effect.
        internal static let mustDisconnect = L10n.tr("Localizable", "settings.commit.messages.must_disconnect")
        /// Reconnect the VPN to apply changes.
        internal static let shouldReconnect = L10n.tr("Localizable", "settings.commit.messages.should_reconnect")
      }
    }
    internal enum Connection {
      /// CONNECTION
      internal static let title = L10n.tr("Localizable", "settings.connection.title")
      internal enum RemotePort {
        /// Remote port
        internal static let title = L10n.tr("Localizable", "settings.connection.remote_port.title")
      }
      internal enum SocketProtocol {
        /// Socket
        internal static let title = L10n.tr("Localizable", "settings.connection.socket_protocol.title")
      }
      internal enum VpnProtocol {
        /// Protocol
        internal static let title = L10n.tr("Localizable", "settings.connection.vpn_protocol.title")
      }
    }
    internal enum ContentBlocker {
      /// To enable or disable Content Blocker go to Settings > Safari > Content Blockers and toggle PIA VPN.
      internal static let footer = L10n.tr("Localizable", "settings.content_blocker.footer")
      /// Safari Content Blocker
      internal static let title = L10n.tr("Localizable", "settings.content_blocker.title")
      internal enum Refresh {
        /// Refresh block list
        internal static let title = L10n.tr("Localizable", "settings.content_blocker.refresh.title")
      }
      internal enum State {
        /// Current state
        internal static let title = L10n.tr("Localizable", "settings.content_blocker.state.title")
      }
    }
    internal enum Dns {
      /// Custom
      internal static let custom = L10n.tr("Localizable", "settings.dns.custom")
      /// Primary DNS
      internal static let primaryDNS = L10n.tr("Localizable", "settings.dns.primaryDNS")
      /// Secondary DNS
      internal static let secondaryDNS = L10n.tr("Localizable", "settings.dns.secondaryDNS")
      internal enum Alert {
        internal enum Clear {
          /// This will clear your custom DNS and default to PIA DNS.
          internal static let message = L10n.tr("Localizable", "settings.dns.alert.clear.message")
          /// Clear DNS
          internal static let title = L10n.tr("Localizable", "settings.dns.alert.clear.title")
        }
        internal enum Create {
          /// Using non PIA DNS could expose your DNS traffic to third parties and compromise your privacy.
          internal static let message = L10n.tr("Localizable", "settings.dns.alert.create.message")
        }
      }
      internal enum Custom {
        /// Custom DNS
        internal static let dns = L10n.tr("Localizable", "settings.dns.custom.dns")
      }
      internal enum Validation {
        internal enum Primary {
          /// Primary DNS is not valid.
          internal static let invalid = L10n.tr("Localizable", "settings.dns.validation.primary.invalid")
          /// Primary DNS is mandatory.
          internal static let mandatory = L10n.tr("Localizable", "settings.dns.validation.primary.mandatory")
        }
        internal enum Secondary {
          /// Secondary DNS is not valid.
          internal static let invalid = L10n.tr("Localizable", "settings.dns.validation.secondary.invalid")
        }
      }
    }
    internal enum Encryption {
      /// ENCRYPTION
      internal static let title = L10n.tr("Localizable", "settings.encryption.title")
      internal enum Cipher {
        /// Data encryption
        internal static let title = L10n.tr("Localizable", "settings.encryption.cipher.title")
      }
      internal enum Digest {
        /// Data authentication
        internal static let title = L10n.tr("Localizable", "settings.encryption.digest.title")
      }
      internal enum Handshake {
        /// Handshake
        internal static let title = L10n.tr("Localizable", "settings.encryption.handshake.title")
      }
    }
    internal enum Hotspothelper {
      /// Configure how PIA will behave on connection to WiFi or cellular networks.
      internal static let description = L10n.tr("Localizable", "settings.hotspothelper.description")
      /// Network management tool
      internal static let title = L10n.tr("Localizable", "settings.hotspothelper.title")
      internal enum All {
        /// VPN WiFi Protection will activate on all networks, including trusted networks.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.all.description")
        /// Protect all networks
        internal static let title = L10n.tr("Localizable", "settings.hotspothelper.all.title")
      }
      internal enum Available {
        /// To populate this list go to iOS Settings > WiFi.
        internal static let help = L10n.tr("Localizable", "settings.hotspothelper.available.help")
        internal enum Add {
          /// Tap + to add to Trusted networks.
          internal static let help = L10n.tr("Localizable", "settings.hotspothelper.available.add.help")
        }
      }
      internal enum Cellular {
        /// PIA automatically enables the VPN when connecting to cellular networks if this option is disabled.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.cellular.description")
        /// Cellular networks
        internal static let networks = L10n.tr("Localizable", "settings.hotspothelper.cellular.networks")
        /// Trust cellular networks
        internal static let title = L10n.tr("Localizable", "settings.hotspothelper.cellular.title")
      }
      internal enum Enable {
        /// VPN WiFi Protection automatically enables the VPN when connecting to untrusted networks if this option is enabled.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.enable.description")
      }
      internal enum Wifi {
        /// WiFi networks
        internal static let networks = L10n.tr("Localizable", "settings.hotspothelper.wifi.networks")
        internal enum Trust {
          /// VPN WiFi Protection
          internal static let title = L10n.tr("Localizable", "settings.hotspothelper.wifi.trust.title")
        }
      }
    }
    internal enum Reset {
      /// This will reset all of the above settings to default.
      internal static let footer = L10n.tr("Localizable", "settings.reset.footer")
      /// RESET
      internal static let title = L10n.tr("Localizable", "settings.reset.title")
      internal enum Defaults {
        /// Reset to default settings
        internal static let title = L10n.tr("Localizable", "settings.reset.defaults.title")
        internal enum Confirm {
          /// Reset
          internal static let button = L10n.tr("Localizable", "settings.reset.defaults.confirm.button")
          /// This will bring the app back to default. You will lose all changes you have made.
          internal static let message = L10n.tr("Localizable", "settings.reset.defaults.confirm.message")
          /// Reset settings
          internal static let title = L10n.tr("Localizable", "settings.reset.defaults.confirm.title")
        }
      }
    }
    internal enum Trusted {
      internal enum Networks {
        /// PIA won't automatically connect on these networks.
        internal static let message = L10n.tr("Localizable", "settings.trusted.networks.message")
        internal enum Connect {
          /// Protect this network by connecting to VPN?
          internal static let message = L10n.tr("Localizable", "settings.trusted.networks.connect.message")
        }
        internal enum Sections {
          /// Available networks
          internal static let available = L10n.tr("Localizable", "settings.trusted.networks.sections.available")
          /// Current network
          internal static let current = L10n.tr("Localizable", "settings.trusted.networks.sections.current")
          /// Trusted networks
          internal static let trusted = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted")
        }
      }
    }
  }

  internal enum Shortcuts {
    /// Connect
    internal static let connect = L10n.tr("Localizable", "shortcuts.connect")
    /// Disconnect
    internal static let disconnect = L10n.tr("Localizable", "shortcuts.disconnect")
    /// Select a region
    internal static let selectRegion = L10n.tr("Localizable", "shortcuts.select_region")
  }

  internal enum VpnPermission {
    /// PIA
    internal static let title = L10n.tr("Localizable", "vpn_permission.title")
    internal enum Body {
      /// We don’t monitor, filter or log any network activity.
      internal static let footer = L10n.tr("Localizable", "vpn_permission.body.footer")
      /// To proceed tap “%@”.
      internal static func subtitle(_ p1: String) -> String {
        return L10n.tr("Localizable", "vpn_permission.body.subtitle", p1)
      }
      /// PIA needs access to your VPN profiles to secure your traffic
      internal static let title = L10n.tr("Localizable", "vpn_permission.body.title")
    }
    internal enum Disallow {
      /// Contact
      internal static let contact = L10n.tr("Localizable", "vpn_permission.disallow.contact")
      internal enum Message {
        /// We need this permission for the application to function.
        internal static let basic = L10n.tr("Localizable", "vpn_permission.disallow.message.basic")
        /// You can also get in touch with customer support if you need assistance.
        internal static let support = L10n.tr("Localizable", "vpn_permission.disallow.message.support")
      }
    }
  }

  internal enum Walkthrough {
    internal enum Action {
      /// DONE
      internal static let done = L10n.tr("Localizable", "walkthrough.action.done")
      /// NEXT
      internal static let next = L10n.tr("Localizable", "walkthrough.action.next")
      /// SKIP
      internal static let skip = L10n.tr("Localizable", "walkthrough.action.skip")
    }
    internal enum Page {
      internal enum _1 {
        /// Protect yourself on up to 5 devices at a time.
        internal static let description = L10n.tr("Localizable", "walkthrough.page.1.description")
        /// Support 5 devices at once
        internal static let title = L10n.tr("Localizable", "walkthrough.page.1.title")
      }
      internal enum _2 {
        /// With servers around the globe, you are always under protection.
        internal static let description = L10n.tr("Localizable", "walkthrough.page.2.description")
        /// Connect to any region easily
        internal static let title = L10n.tr("Localizable", "walkthrough.page.2.title")
      }
      internal enum _3 {
        /// Enabling our Content Blocker prevents ads from showing in Safari.
        internal static let description = L10n.tr("Localizable", "walkthrough.page.3.description")
        /// Protect yourself from ads
        internal static let title = L10n.tr("Localizable", "walkthrough.page.3.title")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
