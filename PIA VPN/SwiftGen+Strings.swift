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
    internal enum Other {
      /// Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.
      internal static let footer = L10n.tr("Localizable", "account.other.footer")
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
    internal enum Subscriptions {
      /// here.
      internal static let linkMessage = L10n.tr("Localizable", "account.subscriptions.linkMessage")
      /// You can manage your subscription from here.
      internal static let message = L10n.tr("Localizable", "account.subscriptions.message")
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
    internal enum Accessibility {
      internal enum Vpn {
        /// VPN Connection button
        internal static let button = L10n.tr("Localizable", "dashboard.accessibility.vpn.button")
        internal enum Button {
          /// VPN Connection button. The VPN is currently disconnected
          internal static let isOff = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOff")
          /// VPN Connection button. The VPN is currently connected
          internal static let isOn = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOn")
        }
      }
    }
    internal enum Connection {
      internal enum Ip {
        /// Internet unreachable
        internal static let unreachable = L10n.tr("Localizable", "dashboard.connection.ip.unreachable")
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
      /// VPN: ON
      internal static let on = L10n.tr("Localizable", "dashboard.vpn.on")
      internal enum Disconnect {
        /// This network is untrusted. Do you really want to disconnect the VPN?
        internal static let untrusted = L10n.tr("Localizable", "dashboard.vpn.disconnect.untrusted")
      }
    }
  }

  internal enum Expiration {
    /// Your subscription expires soon. Renew to stay protected.
    internal static let message = L10n.tr("Localizable", "expiration.message")
    /// Renewal
    internal static let title = L10n.tr("Localizable", "expiration.title")
  }

  internal enum Friend {
    internal enum Referrals {
      /// Full name
      internal static let fullName = L10n.tr("Localizable", "friend.referrals.fullName")
      /// Signed up
      internal static let signedup = L10n.tr("Localizable", "friend.referrals.signedup")
      /// Refer a Friend
      internal static let title = L10n.tr("Localizable", "friend.referrals.title")
      internal enum Days {
        /// Free days acquired
        internal static let acquired = L10n.tr("Localizable", "friend.referrals.days.acquired")
        /// %d days
        internal static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.days.number", p1)
        }
      }
      internal enum Email {
        /// Invalid email. Please try again.
        internal static let validation = L10n.tr("Localizable", "friend.referrals.email.validation")
      }
      internal enum Family {
        internal enum Friends {
          /// Family and Friends Referral Program
          internal static let program = L10n.tr("Localizable", "friend.referrals.family.friends.program")
        }
      }
      internal enum Invitation {
        /// By sending this invitation, I agree to all of the terms and conditions of the Family and Friends Referral Program.
        internal static let terms = L10n.tr("Localizable", "friend.referrals.invitation.terms")
      }
      internal enum Invite {
        /// Could not resend invite. Try again later.
        internal static let error = L10n.tr("Localizable", "friend.referrals.invite.error")
        /// Invite sent successfully
        internal static let success = L10n.tr("Localizable", "friend.referrals.invite.success")
      }
      internal enum Invites {
        /// You have sent %d invites
        internal static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.invites.number", p1)
        }
        internal enum Sent {
          /// Invites sent
          internal static let title = L10n.tr("Localizable", "friend.referrals.invites.sent.title")
        }
      }
      internal enum Pending {
        /// %d pending invites
        internal static func invites(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.pending.invites", p1)
        }
        internal enum Invites {
          /// Pending invites
          internal static let title = L10n.tr("Localizable", "friend.referrals.pending.invites.title")
        }
      }
      internal enum Privacy {
        /// Please note, for privacy reasons, all invites older than 30 days will be deleted.
        internal static let note = L10n.tr("Localizable", "friend.referrals.privacy.note")
      }
      internal enum Reward {
        /// Reward given
        internal static let given = L10n.tr("Localizable", "friend.referrals.reward.given")
      }
      internal enum Send {
        /// Send invite
        internal static let invite = L10n.tr("Localizable", "friend.referrals.send.invite")
      }
      internal enum Share {
        /// Share your unique referral link
        internal static let link = L10n.tr("Localizable", "friend.referrals.share.link")
        internal enum Link {
          /// By sharing this link, you agree to all of the terms and conditions of the Family and Friends Referral Program.
          internal static let terms = L10n.tr("Localizable", "friend.referrals.share.link.terms")
        }
      }
      internal enum Signups {
        /// %d signups
        internal static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.signups.number", p1)
        }
      }
      internal enum View {
        internal enum Invites {
          /// View invites sent
          internal static let sent = L10n.tr("Localizable", "friend.referrals.view.invites.sent")
        }
      }
    }
  }

  internal enum Global {
    /// Add
    internal static let add = L10n.tr("Localizable", "global.add")
    /// Automatic
    internal static let automatic = L10n.tr("Localizable", "global.automatic")
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "global.cancel")
    /// Clear
    internal static let clear = L10n.tr("Localizable", "global.clear")
    /// Close
    internal static let close = L10n.tr("Localizable", "global.close")
    /// Copied to clipboard
    internal static let copied = L10n.tr("Localizable", "global.copied")
    /// Copy
    internal static let copy = L10n.tr("Localizable", "global.copy")
    /// Disabled
    internal static let disabled = L10n.tr("Localizable", "global.disabled")
    /// Edit
    internal static let edit = L10n.tr("Localizable", "global.edit")
    /// Empty
    internal static let empty = L10n.tr("Localizable", "global.empty")
    /// Enable
    internal static let enable = L10n.tr("Localizable", "global.enable")
    /// Enabled
    internal static let enabled = L10n.tr("Localizable", "global.enabled")
    /// Error
    internal static let error = L10n.tr("Localizable", "global.error")
    /// No
    internal static let no = L10n.tr("Localizable", "global.no")
    /// OK
    internal static let ok = L10n.tr("Localizable", "global.ok")
    /// Optional
    internal static let `optional` = L10n.tr("Localizable", "global.optional")
    /// Remove
    internal static let remove = L10n.tr("Localizable", "global.remove")
    /// Required
    internal static let `required` = L10n.tr("Localizable", "global.required")
    /// Share
    internal static let share = L10n.tr("Localizable", "global.share")
    /// No internet connection found. Please confirm that you have an internet connection.
    internal static let unreachable = L10n.tr("Localizable", "global.unreachable")
    /// Update
    internal static let update = L10n.tr("Localizable", "global.update")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "global.yes")
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
      internal enum Edit {
        /// Edit
        internal static let tile = L10n.tr("Localizable", "menu.accessibility.edit.tile")
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

  internal enum Region {
    internal enum Accessibility {
      /// Add a favorite region
      internal static let favorite = L10n.tr("Localizable", "region.accessibility.favorite")
      /// Filter
      internal static let filter = L10n.tr("Localizable", "region.accessibility.filter")
      /// Remove a favorite region
      internal static let unfavorite = L10n.tr("Localizable", "region.accessibility.unfavorite")
    }
    internal enum Filter {
      /// Favorites
      internal static let favorites = L10n.tr("Localizable", "region.filter.favorites")
      /// Latency
      internal static let latency = L10n.tr("Localizable", "region.filter.latency")
      /// Name
      internal static let name = L10n.tr("Localizable", "region.filter.name")
      /// Sort regions by
      internal static let sortby = L10n.tr("Localizable", "region.filter.sortby")
    }
    internal enum Search {
      /// Search for a region
      internal static let placeholder = L10n.tr("Localizable", "region.search.placeholder")
    }
  }

  internal enum Renewal {
    internal enum Failure {
      /// Your purchase receipt couldn't be submitted, please retry at a later time.
      internal static let message = L10n.tr("Localizable", "renewal.failure.message")
      internal enum Receipt {
        /// Your have a sandbox receipt. Renewals with sandbox receipts are not available in Beta or Production builds.
        internal static let message = L10n.tr("Localizable", "renewal.failure.receipt.message")
      }
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
      internal enum ActiveTheme {
        /// Active theme
        internal static let title = L10n.tr("Localizable", "settings.application_settings.active_theme.title")
      }
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
      /// Configure how PIA will behave on connection to WiFi or cellular networks. This excludes disconnecting manually.
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
        /// PIA automatically enables the VPN when connecting to cellular networks if this option is enabled.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.cellular.description")
        /// Cellular networks
        internal static let networks = L10n.tr("Localizable", "settings.hotspothelper.cellular.networks")
        /// Protect over cellular networks
        internal static let title = L10n.tr("Localizable", "settings.hotspothelper.cellular.title")
      }
      internal enum Enable {
        /// PIA automatically enables the VPN when connecting to untrusted WiFi networks if this option is enabled.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.enable.description")
      }
      internal enum Rules {
        /// Rules
        internal static let title = L10n.tr("Localizable", "settings.hotspothelper.rules.title")
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
    internal enum Nmt {
      internal enum Killswitch {
        /// The VPN kill switch is currently disabled. In order to ensure that the Network Management Tool is functioning, and that you are able to reconnect when switching networks, please enable the VPN kill switch in your settings.
        internal static let disabled = L10n.tr("Localizable", "settings.nmt.killswitch.disabled")
      }
      internal enum Optout {
        internal enum Disconnect {
          /// Opt-out disconnect confirmation alert
          internal static let alerts = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts")
          internal enum Alerts {
            /// Disables the warning alert when disconnecting from the VPN.
            internal static let description = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts.description")
          }
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
          /// Untrusted networks
          internal static let untrusted = L10n.tr("Localizable", "settings.trusted.networks.sections.untrusted")
          internal enum Trusted {
            internal enum Rule {
              /// Disconnect from PIA VPN
              internal static let action = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.action")
              /// Enable this feature, with the VPN kill switch enabled, to customize how PIA will behave on WiFi and cellular networks. Please be aware, functionality of the Network Management Tool will be disabled if you manually disconnect.
              internal static let description = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.description")
            }
          }
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

  internal enum Siri {
    internal enum Shortcuts {
      internal enum Add {
        /// There was an error adding the Siri shortcut. Please, try it again.
        internal static let error = L10n.tr("Localizable", "siri.shortcuts.add.error")
      }
      internal enum Connect {
        /// Connect PIA VPN
        internal static let title = L10n.tr("Localizable", "siri.shortcuts.connect.title")
        internal enum Row {
          /// 'Connect' Siri Shortcut
          internal static let title = L10n.tr("Localizable", "siri.shortcuts.connect.row.title")
        }
      }
      internal enum Disconnect {
        /// Disconnect PIA VPN
        internal static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.title")
        internal enum Row {
          /// 'Disconnect' Siri Shortcut
          internal static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.row.title")
        }
      }
    }
  }

  internal enum Tiles {
    internal enum Accessibility {
      internal enum Invisible {
        internal enum Tile {
          /// Tap to add this tile to the dasboard
          internal static let action = L10n.tr("Localizable", "tiles.accessibility.invisible.tile.action")
        }
      }
      internal enum Visible {
        internal enum Tile {
          /// Tap to remove this tile from the dasboard
          internal static let action = L10n.tr("Localizable", "tiles.accessibility.visible.tile.action")
        }
      }
    }
    internal enum Favorite {
      internal enum Servers {
        /// Favorite servers
        internal static let title = L10n.tr("Localizable", "tiles.favorite.servers.title")
      }
    }
    internal enum Nmt {
      /// Cellular
      internal static let cellular = L10n.tr("Localizable", "tiles.nmt.cellular")
      internal enum Accessibility {
        /// Trusted network
        internal static let trusted = L10n.tr("Localizable", "tiles.nmt.accessibility.trusted")
        /// Untrusted network
        internal static let untrusted = L10n.tr("Localizable", "tiles.nmt.accessibility.untrusted")
      }
    }
    internal enum Quick {
      internal enum Connect {
        /// Recent servers
        internal static let title = L10n.tr("Localizable", "tiles.quick.connect.title")
      }
    }
    internal enum Quicksetting {
      internal enum Nmt {
        /// Network Management
        internal static let title = L10n.tr("Localizable", "tiles.quicksetting.nmt.title")
      }
    }
    internal enum Quicksettings {
      /// Quick settings
      internal static let title = L10n.tr("Localizable", "tiles.quicksettings.title")
    }
    internal enum Region {
      /// VPN Server
      internal static let title = L10n.tr("Localizable", "tiles.region.title")
    }
    internal enum Subscription {
      /// Monthly
      internal static let monthly = L10n.tr("Localizable", "tiles.subscription.monthly")
      /// Subscription
      internal static let title = L10n.tr("Localizable", "tiles.subscription.title")
      /// Trial
      internal static let trial = L10n.tr("Localizable", "tiles.subscription.trial")
      /// Yearly
      internal static let yearly = L10n.tr("Localizable", "tiles.subscription.yearly")
      internal enum Days {
        /// (%d days left)
        internal static func `left`(_ p1: Int) -> String {
          return L10n.tr("Localizable", "tiles.subscription.days.left", p1)
        }
      }
    }
    internal enum Usage {
      /// Download
      internal static let download = L10n.tr("Localizable", "tiles.usage.download")
      /// Usage
      internal static let title = L10n.tr("Localizable", "tiles.usage.title")
      /// Upload
      internal static let upload = L10n.tr("Localizable", "tiles.usage.upload")
      internal enum Ipsec {
        /// USAGE (Disabled unless using OpenVPN)
        internal static let title = L10n.tr("Localizable", "tiles.usage.ipsec.title")
      }
    }
  }

  internal enum Today {
    internal enum Widget {
      /// Login
      internal static let login = L10n.tr("Localizable", "today.widget.login")
    }
  }

  internal enum VpnPermission {
    /// PIA
    internal static let title = L10n.tr("Localizable", "vpn_permission.title")
    internal enum Body {
      /// We don’t monitor, filter or log any network activity.
      internal static let footer = L10n.tr("Localizable", "vpn_permission.body.footer")
      /// You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.\nTo proceed tap on “%@”.
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
        /// Protect yourself on up to 10 devices at a time.
        internal static let description = L10n.tr("Localizable", "walkthrough.page.1.description")
        /// Support 10 devices at once
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
