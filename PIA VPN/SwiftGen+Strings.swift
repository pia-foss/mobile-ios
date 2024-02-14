// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Localizable {
    internal enum About {
      /// VPN by Private Internet Access
      internal static let app = L10n.tr("Localizable", "about.app", fallback: "VPN by Private Internet Access")
      /// This program uses the following components:
      internal static let intro = L10n.tr("Localizable", "about.intro", fallback: "This program uses the following components:")
      internal enum Accessibility {
        internal enum Component {
          /// Tap to read full license
          internal static let expand = L10n.tr("Localizable", "about.accessibility.component.expand", fallback: "Tap to read full license")
        }
      }
    }
    internal enum Account {
      /// Delete Account
      internal static let delete = L10n.tr("Localizable", "account.delete", fallback: "Delete Account")
      /// Something went wrong. Please try logging in again
      internal static let unauthorized = L10n.tr("Localizable", "account.unauthorized", fallback: "Something went wrong. Please try logging in again")
      internal enum Delete {
        internal enum Alert {
          /// Something went wrong while deleting your account, please try again later.
          internal static let failureMessage = L10n.tr("Localizable", "account.delete.alert.failureMessage", fallback: "Something went wrong while deleting your account, please try again later.")
          /// Deleting your PIA account is permanent and irreversible. You will not be able to retrieve your PIA credentials after performing this action. Please note that this action only deletes your PIA account from our database, but it does NOT delete your subscription. You will need to go to your Apple account and cancel the Private Internet Access subscription from there. Otherwise, you will still be charged, even though your PIA account will no longer be active.
          internal static let message = L10n.tr("Localizable", "account.delete.alert.message", fallback: "Deleting your PIA account is permanent and irreversible. You will not be able to retrieve your PIA credentials after performing this action. Please note that this action only deletes your PIA account from our database, but it does NOT delete your subscription. You will need to go to your Apple account and cancel the Private Internet Access subscription from there. Otherwise, you will still be charged, even though your PIA account will no longer be active.")
          /// Are you sure?
          internal static let title = L10n.tr("Localizable", "account.delete.alert.title", fallback: "Are you sure?")
        }
      }
      internal enum Email {
        /// Email
        internal static let caption = L10n.tr("Localizable", "account.email.caption", fallback: "Email")
        /// Email address
        internal static let placeholder = L10n.tr("Localizable", "account.email.placeholder", fallback: "Email address")
      }
      internal enum Error {
        /// Your username or password is incorrect.
        internal static let unauthorized = L10n.tr("Localizable", "account.error.unauthorized", fallback: "Your username or password is incorrect.")
      }
      internal enum ExpiryDate {
        /// Your plan has expired.
        internal static let expired = L10n.tr("Localizable", "account.expiry_date.expired", fallback: "Your plan has expired.")
        /// Your plan will expire on %@.
        internal static func information(_ p1: Any) -> String {
          return L10n.tr("Localizable", "account.expiry_date.information", String(describing: p1), fallback: "Your plan will expire on %@.")
        }
      }
      internal enum Other {
        /// Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.
        internal static let footer = L10n.tr("Localizable", "account.other.footer", fallback: "Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.")
      }
      internal enum Restore {
        /// RESTORE PURCHASE
        internal static let button = L10n.tr("Localizable", "account.restore.button", fallback: "RESTORE PURCHASE")
        /// If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.
        internal static let description = L10n.tr("Localizable", "account.restore.description", fallback: "If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.")
        /// Restore uncredited purchase
        internal static let title = L10n.tr("Localizable", "account.restore.title", fallback: "Restore uncredited purchase")
        internal enum Failure {
          /// No redeemable purchase was found for renewal.
          internal static let message = L10n.tr("Localizable", "account.restore.failure.message", fallback: "No redeemable purchase was found for renewal.")
          /// Restore purchase
          internal static let title = L10n.tr("Localizable", "account.restore.failure.title", fallback: "Restore purchase")
        }
      }
      internal enum Reveal {
        /// Authenticate to reveal
        internal static let prompt = L10n.tr("Localizable", "account.reveal.prompt", fallback: "Authenticate to reveal")
      }
      internal enum Save {
        /// Update email
        internal static let item = L10n.tr("Localizable", "account.save.item", fallback: "Update email")
        /// Authenticate to save changes
        internal static let prompt = L10n.tr("Localizable", "account.save.prompt", fallback: "Authenticate to save changes")
        /// Your email address has been saved.
        internal static let success = L10n.tr("Localizable", "account.save.success", fallback: "Your email address has been saved.")
      }
      internal enum Set {
        internal enum Email {
          /// There was an error adding email. Please try again later.
          internal static let error = L10n.tr("Localizable", "account.set.email.error", fallback: "There was an error adding email. Please try again later.")
        }
      }
      internal enum Subscriptions {
        /// here.
        internal static let linkMessage = L10n.tr("Localizable", "account.subscriptions.linkMessage", fallback: "here.")
        /// You can manage your subscription from here.
        internal static let message = L10n.tr("Localizable", "account.subscriptions.message", fallback: "You can manage your subscription from here.")
        /// Monthly plan
        internal static let monthly = L10n.tr("Localizable", "account.subscriptions.monthly", fallback: "Monthly plan")
        /// Trial plan
        internal static let trial = L10n.tr("Localizable", "account.subscriptions.trial", fallback: "Trial plan")
        /// Yearly plan
        internal static let yearly = L10n.tr("Localizable", "account.subscriptions.yearly", fallback: "Yearly plan")
        internal enum Short {
          /// Manage subscription
          internal static let linkMessage = L10n.tr("Localizable", "account.subscriptions.short.linkMessage", fallback: "Manage subscription")
          /// Manage subscription
          internal static let message = L10n.tr("Localizable", "account.subscriptions.short.message", fallback: "Manage subscription")
        }
      }
      internal enum Survey {
        /// Want to help make PIA better? Let us know how we can improve!
        /// Take The Survey
        internal static let message = L10n.tr("Localizable", "account.survey.message", fallback: "Want to help make PIA better? Let us know how we can improve!\nTake The Survey")
        /// Take The Survey
        internal static let messageLink = L10n.tr("Localizable", "account.survey.messageLink", fallback: "Take The Survey")
      }
      internal enum Update {
        internal enum Email {
          internal enum Require {
            internal enum Password {
              /// Submit
              internal static let button = L10n.tr("Localizable", "account.update.email.require.password.button", fallback: "Submit")
              /// For security reasons we require your PIA password to perform a change in your account. Please input your PIA password to proceed.
              internal static let message = L10n.tr("Localizable", "account.update.email.require.password.message", fallback: "For security reasons we require your PIA password to perform a change in your account. Please input your PIA password to proceed.")
              /// PIA Password Required
              internal static let title = L10n.tr("Localizable", "account.update.email.require.password.title", fallback: "PIA Password Required")
            }
          }
        }
      }
      internal enum Username {
        /// Username
        internal static let caption = L10n.tr("Localizable", "account.username.caption", fallback: "Username")
      }
    }
    internal enum Card {
      internal enum Wireguard {
        /// It's a new, more efficient VPN protocol that offers better performance, lower CPU usage and longer battery life.
        internal static let description = L10n.tr("Localizable", "card.wireguard.description", fallback: "It's a new, more efficient VPN protocol that offers better performance, lower CPU usage and longer battery life.")
        /// Try WireGuard® today!
        internal static let title = L10n.tr("Localizable", "card.wireguard.title", fallback: "Try WireGuard® today!")
        internal enum Cta {
          /// Try WireGuard® now
          internal static let activate = L10n.tr("Localizable", "card.wireguard.cta.activate", fallback: "Try WireGuard® now")
          /// Learn more
          internal static let learn = L10n.tr("Localizable", "card.wireguard.cta.learn", fallback: "Learn more")
          /// Open Settings
          internal static let settings = L10n.tr("Localizable", "card.wireguard.cta.settings", fallback: "Open Settings")
        }
      }
    }
    internal enum ContentBlocker {
      /// Safari Content Blocker
      internal static let title = L10n.tr("Localizable", "content_blocker.title", fallback: "Safari Content Blocker")
      internal enum Body {
        /// Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.
        internal static let footer = L10n.tr("Localizable", "content_blocker.body.footer", fallback: "Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.")
        /// To enable our Content Blocker for use with Safari please go to Settings > Safari, and under General touch Content Blockers toggle on PIA VPN.
        internal static let subtitle = L10n.tr("Localizable", "content_blocker.body.subtitle", fallback: "To enable our Content Blocker for use with Safari please go to Settings > Safari, and under General touch Content Blockers toggle on PIA VPN.")
      }
    }
    internal enum Dashboard {
      internal enum Accessibility {
        internal enum Vpn {
          /// VPN Connection button
          internal static let button = L10n.tr("Localizable", "dashboard.accessibility.vpn.button", fallback: "VPN Connection button")
          internal enum Button {
            /// VPN Connection button. The VPN is currently disconnected
            internal static let isOff = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOff", fallback: "VPN Connection button. The VPN is currently disconnected")
            /// VPN Connection button. The VPN is currently connected
            internal static let isOn = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOn", fallback: "VPN Connection button. The VPN is currently connected")
          }
        }
      }
      internal enum Connection {
        internal enum Ip {
          /// Internet unreachable
          internal static let unreachable = L10n.tr("Localizable", "dashboard.connection.ip.unreachable", fallback: "Internet unreachable")
        }
      }
      internal enum ConnectionState {
        internal enum Connected {
          /// Connected
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.connected.title", fallback: "Connected")
        }
        internal enum Connecting {
          /// Connecting...
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.connecting.title", fallback: "Connecting...")
        }
        internal enum Disconnected {
          /// Not Connected
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.disconnected.title", fallback: "Not Connected")
        }
        internal enum Disconnecting {
          /// Disconnecting...
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.disconnecting.title", fallback: "Disconnecting...")
        }
        internal enum Error {
          /// Connection Error
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.error.title", fallback: "Connection Error")
        }
        internal enum Reconnecting {
          /// Reconnecting...
          internal static let title = L10n.tr("Localizable", "dashboard.connection_state.reconnecting.title", fallback: "Reconnecting...")
        }
      }
      internal enum ContentBlocker {
        internal enum Intro {
          /// This version replaces MACE with our Safari Content Blocker.
          /// 
          /// Check it out in the 'Settings' section.
          internal static let message = L10n.tr("Localizable", "dashboard.content_blocker.intro.message", fallback: "This version replaces MACE with our Safari Content Blocker.\n\nCheck it out in the 'Settings' section.")
        }
      }
      internal enum Vpn {
        /// Changing region...
        internal static let changingRegion = L10n.tr("Localizable", "dashboard.vpn.changing_region", fallback: "Changing region...")
        /// Connected to VPN
        internal static let connected = L10n.tr("Localizable", "dashboard.vpn.connected", fallback: "Connected to VPN")
        /// Connecting...
        internal static let connecting = L10n.tr("Localizable", "dashboard.vpn.connecting", fallback: "Connecting...")
        /// Disconnected
        internal static let disconnected = L10n.tr("Localizable", "dashboard.vpn.disconnected", fallback: "Disconnected")
        /// Disconnecting...
        internal static let disconnecting = L10n.tr("Localizable", "dashboard.vpn.disconnecting", fallback: "Disconnecting...")
        /// VPN: ON
        internal static let on = L10n.tr("Localizable", "dashboard.vpn.on", fallback: "VPN: ON")
        internal enum Disconnect {
          /// This network is untrusted. Do you really want to disconnect the VPN?
          internal static let untrusted = L10n.tr("Localizable", "dashboard.vpn.disconnect.untrusted", fallback: "This network is untrusted. Do you really want to disconnect the VPN?")
        }
        internal enum Leakprotection {
          internal enum Alert {
            /// Disable Now
            internal static let cta1 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta1", fallback: "Disable Now")
            /// Learn more
            internal static let cta2 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta2", fallback: "Learn more")
            /// Ignore
            internal static let cta3 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta3", fallback: "Ignore")
            /// To prevent data leaks, tap Disable Now to turn off “Allow access to devices on local network" and automatically reconnect.
            internal static let message = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.message", fallback: "To prevent data leaks, tap Disable Now to turn off “Allow access to devices on local network\" and automatically reconnect.")
            /// Unsecured Wi-Fi detected
            internal static let title = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.title", fallback: "Unsecured Wi-Fi detected")
          }
          internal enum Ikev2 {
            internal enum Alert {
              /// Switch Now
              internal static let cta1 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.ikev2.alert.cta1", fallback: "Switch Now")
              /// To prevent data leaks, tap Switch Now to change to the IKEv2 VPN protocol and automatically reconnect.
              internal static let message = L10n.tr("Localizable", "dashboard.vpn.leakprotection.ikev2.alert.message", fallback: "To prevent data leaks, tap Switch Now to change to the IKEv2 VPN protocol and automatically reconnect.")
            }
          }
        }
      }
    }
    internal enum Dedicated {
      internal enum Ip {
        /// Are you sure you want to remove the selected region?
        internal static let remove = L10n.tr("Localizable", "dedicated.ip.remove", fallback: "Are you sure you want to remove the selected region?")
        /// Dedicated IP
        internal static let title = L10n.tr("Localizable", "dedicated.ip.title", fallback: "Dedicated IP")
        internal enum Activate {
          internal enum Button {
            /// Activate
            internal static let title = L10n.tr("Localizable", "dedicated.ip.activate.button.title", fallback: "Activate")
          }
        }
        internal enum Activation {
          /// Activate your Dedicated IP by pasting your token in the form below. If you've recently purchased a dedicated IP, you can generate the token by going to the PIA website.
          internal static let description = L10n.tr("Localizable", "dedicated.ip.activation.description", fallback: "Activate your Dedicated IP by pasting your token in the form below. If you've recently purchased a dedicated IP, you can generate the token by going to the PIA website.")
        }
        internal enum Country {
          internal enum Flag {
            /// Country flag for %@
            internal static func accessibility(_ p1: Any) -> String {
              return L10n.tr("Localizable", "dedicated.ip.country.flag.accessibility", String(describing: p1), fallback: "Country flag for %@")
            }
          }
        }
        internal enum Limit {
          /// Secure your remote connections to any asset with a dedicated IP from a country of your choice. During your subscription, this IP will be yours and yours alone, protecting your data transfers with the strongest encryption out there.
          internal static let title = L10n.tr("Localizable", "dedicated.ip.limit.title", fallback: "Secure your remote connections to any asset with a dedicated IP from a country of your choice. During your subscription, this IP will be yours and yours alone, protecting your data transfers with the strongest encryption out there.")
        }
        internal enum Message {
          internal enum Error {
            /// Too many failed token activation requests. Please try again after %@ second(s).
            internal static func retryafter(_ p1: Any) -> String {
              return L10n.tr("Localizable", "dedicated.ip.message.error.retryafter", String(describing: p1), fallback: "Too many failed token activation requests. Please try again after %@ second(s).")
            }
            /// Your token is expired. Please generate a new one from your Account page on the website.
            internal static let token = L10n.tr("Localizable", "dedicated.ip.message.error.token", fallback: "Your token is expired. Please generate a new one from your Account page on the website.")
          }
          internal enum Expired {
            /// Your token is expired. Please generate a new one from your Account page on the website.
            internal static let token = L10n.tr("Localizable", "dedicated.ip.message.expired.token", fallback: "Your token is expired. Please generate a new one from your Account page on the website.")
          }
          internal enum Incorrect {
            /// Please make sure you have entered the token correctly
            internal static let token = L10n.tr("Localizable", "dedicated.ip.message.incorrect.token", fallback: "Please make sure you have entered the token correctly")
          }
          internal enum Invalid {
            /// Your token is invalid. Please make sure you have entered the token correctly.
            internal static let token = L10n.tr("Localizable", "dedicated.ip.message.invalid.token", fallback: "Your token is invalid. Please make sure you have entered the token correctly.")
          }
          internal enum Ip {
            /// Your dedicated IP was updated
            internal static let updated = L10n.tr("Localizable", "dedicated.ip.message.ip.updated", fallback: "Your dedicated IP was updated")
          }
          internal enum Token {
            /// Your dedicated IP will expire soon. Get a new one
            internal static let willexpire = L10n.tr("Localizable", "dedicated.ip.message.token.willexpire", fallback: "Your dedicated IP will expire soon. Get a new one")
            internal enum Willexpire {
              /// Get a new one
              internal static let link = L10n.tr("Localizable", "dedicated.ip.message.token.willexpire.link", fallback: "Get a new one")
            }
          }
          internal enum Valid {
            /// Your Dedicated IP has been activated successfully. It will be available in your Region selection list.
            internal static let token = L10n.tr("Localizable", "dedicated.ip.message.valid.token", fallback: "Your Dedicated IP has been activated successfully. It will be available in your Region selection list.")
          }
        }
        internal enum Plural {
          /// Your Dedicated IPs
          internal static let title = L10n.tr("Localizable", "dedicated.ip.plural.title", fallback: "Your Dedicated IPs")
        }
        internal enum Token {
          internal enum Textfield {
            /// The textfield to type the Dedicated IP token
            internal static let accessibility = L10n.tr("Localizable", "dedicated.ip.token.textfield.accessibility", fallback: "The textfield to type the Dedicated IP token")
            /// Paste in your token here
            internal static let placeholder = L10n.tr("Localizable", "dedicated.ip.token.textfield.placeholder", fallback: "Paste in your token here")
          }
        }
      }
    }
    internal enum ErrorAlert {
      internal enum ConnectionError {
        internal enum NoNetwork {
          /// Please check your internet connection and try again
          internal static let message = L10n.tr("Localizable", "error_alert.connection_error.no_network.message", fallback: "Please check your internet connection and try again")
          /// Unable to connect
          internal static let title = L10n.tr("Localizable", "error_alert.connection_error.no_network.title", fallback: "Unable to connect")
          internal enum RetryAction {
            /// Retry
            internal static let title = L10n.tr("Localizable", "error_alert.connection_error.no_network.retry_action.title", fallback: "Retry")
          }
        }
      }
    }
    internal enum Expiration {
      /// Your subscription expires soon. Renew to stay protected.
      internal static let message = L10n.tr("Localizable", "expiration.message", fallback: "Your subscription expires soon. Renew to stay protected.")
      /// Renewal
      internal static let title = L10n.tr("Localizable", "expiration.title", fallback: "Renewal")
    }
    internal enum Friend {
      internal enum Referrals {
        /// Full name
        internal static let fullName = L10n.tr("Localizable", "friend.referrals.fullName", fallback: "Full name")
        /// Signed up
        internal static let signedup = L10n.tr("Localizable", "friend.referrals.signedup", fallback: "Signed up")
        /// Refer a Friend
        internal static let title = L10n.tr("Localizable", "friend.referrals.title", fallback: "Refer a Friend")
        internal enum Days {
          /// Free days acquired
          internal static let acquired = L10n.tr("Localizable", "friend.referrals.days.acquired", fallback: "Free days acquired")
          /// %d days
          internal static func number(_ p1: Int) -> String {
            return L10n.tr("Localizable", "friend.referrals.days.number", p1, fallback: "%d days")
          }
        }
        internal enum Description {
          /// REFER A FRIEND. GET 30 DAYS FREE.
          internal static let short = L10n.tr("Localizable", "friend.referrals.description.short", fallback: "REFER A FRIEND. GET 30 DAYS FREE.")
        }
        internal enum Email {
          /// Invalid email. Please try again.
          internal static let validation = L10n.tr("Localizable", "friend.referrals.email.validation", fallback: "Invalid email. Please try again.")
        }
        internal enum Family {
          internal enum Friends {
            /// Family and Friends Referral Program
            internal static let program = L10n.tr("Localizable", "friend.referrals.family.friends.program", fallback: "Family and Friends Referral Program")
          }
        }
        internal enum Friends {
          internal enum Family {
            /// Refer your friends and family. For every sign up we’ll give you both 30 days free. 
            internal static let title = L10n.tr("Localizable", "friend.referrals.friends.family.title", fallback: "Refer your friends and family. For every sign up we’ll give you both 30 days free. ")
          }
        }
        internal enum Invitation {
          /// By sending this invitation, I agree to all of the terms and conditions of the Family and Friends Referral Program.
          internal static let terms = L10n.tr("Localizable", "friend.referrals.invitation.terms", fallback: "By sending this invitation, I agree to all of the terms and conditions of the Family and Friends Referral Program.")
        }
        internal enum Invite {
          /// Could not resend invite. Try again later.
          internal static let error = L10n.tr("Localizable", "friend.referrals.invite.error", fallback: "Could not resend invite. Try again later.")
          /// Invite sent successfully
          internal static let success = L10n.tr("Localizable", "friend.referrals.invite.success", fallback: "Invite sent successfully")
        }
        internal enum Invites {
          /// You have sent %d invites
          internal static func number(_ p1: Int) -> String {
            return L10n.tr("Localizable", "friend.referrals.invites.number", p1, fallback: "You have sent %d invites")
          }
          internal enum Sent {
            /// Invites sent
            internal static let title = L10n.tr("Localizable", "friend.referrals.invites.sent.title", fallback: "Invites sent")
          }
        }
        internal enum Pending {
          /// %d pending invites
          internal static func invites(_ p1: Int) -> String {
            return L10n.tr("Localizable", "friend.referrals.pending.invites", p1, fallback: "%d pending invites")
          }
          internal enum Invites {
            /// Pending invites
            internal static let title = L10n.tr("Localizable", "friend.referrals.pending.invites.title", fallback: "Pending invites")
          }
        }
        internal enum Privacy {
          /// Please note, for privacy reasons, all invites older than 30 days will be deleted.
          internal static let note = L10n.tr("Localizable", "friend.referrals.privacy.note", fallback: "Please note, for privacy reasons, all invites older than 30 days will be deleted.")
        }
        internal enum Reward {
          /// Reward given
          internal static let given = L10n.tr("Localizable", "friend.referrals.reward.given", fallback: "Reward given")
        }
        internal enum Send {
          /// Send invite
          internal static let invite = L10n.tr("Localizable", "friend.referrals.send.invite", fallback: "Send invite")
        }
        internal enum Share {
          /// Share your unique referral link
          internal static let link = L10n.tr("Localizable", "friend.referrals.share.link", fallback: "Share your unique referral link")
          internal enum Link {
            /// By sharing this link, you agree to all of the terms and conditions of the Family and Friends Referral Program.
            internal static let terms = L10n.tr("Localizable", "friend.referrals.share.link.terms", fallback: "By sharing this link, you agree to all of the terms and conditions of the Family and Friends Referral Program.")
          }
        }
        internal enum Signups {
          /// %d signups
          internal static func number(_ p1: Int) -> String {
            return L10n.tr("Localizable", "friend.referrals.signups.number", p1, fallback: "%d signups")
          }
        }
        internal enum View {
          internal enum Invites {
            /// View invites sent
            internal static let sent = L10n.tr("Localizable", "friend.referrals.view.invites.sent", fallback: "View invites sent")
          }
        }
      }
    }
    internal enum Gdpr {
      internal enum Accept {
        internal enum Button {
          /// Agree and continue
          internal static let title = L10n.tr("Localizable", "gdpr.accept.button.title", fallback: "Agree and continue")
        }
      }
      internal enum Collect {
        internal enum Data {
          /// E-mail Address for the purposes of account management and protection from abuse.
          /// 
          /// E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.
          internal static let description = L10n.tr("Localizable", "gdpr.collect.data.description", fallback: "E-mail Address for the purposes of account management and protection from abuse.\n\nE-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.")
          /// Personal information we collect
          internal static let title = L10n.tr("Localizable", "gdpr.collect.data.title", fallback: "Personal information we collect")
        }
      }
    }
    internal enum Global {
      /// Add
      internal static let add = L10n.tr("Localizable", "global.add", fallback: "Add")
      /// Automatic
      internal static let automatic = L10n.tr("Localizable", "global.automatic", fallback: "Automatic")
      /// Cancel
      internal static let cancel = L10n.tr("Localizable", "global.cancel", fallback: "Cancel")
      /// Clear
      internal static let clear = L10n.tr("Localizable", "global.clear", fallback: "Clear")
      /// Close
      internal static let close = L10n.tr("Localizable", "global.close", fallback: "Close")
      /// Copied to clipboard
      internal static let copied = L10n.tr("Localizable", "global.copied", fallback: "Copied to clipboard")
      /// Copy
      internal static let copy = L10n.tr("Localizable", "global.copy", fallback: "Copy")
      /// Disable
      internal static let disable = L10n.tr("Localizable", "global.disable", fallback: "Disable")
      /// Disabled
      internal static let disabled = L10n.tr("Localizable", "global.disabled", fallback: "Disabled")
      /// Edit
      internal static let edit = L10n.tr("Localizable", "global.edit", fallback: "Edit")
      /// Empty
      internal static let empty = L10n.tr("Localizable", "global.empty", fallback: "Empty")
      /// Enable
      internal static let enable = L10n.tr("Localizable", "global.enable", fallback: "Enable")
      /// Enabled
      internal static let enabled = L10n.tr("Localizable", "global.enabled", fallback: "Enabled")
      /// Error
      internal static let error = L10n.tr("Localizable", "global.error", fallback: "Error")
      /// No
      internal static let no = L10n.tr("Localizable", "global.no", fallback: "No")
      /// OK
      internal static let ok = L10n.tr("Localizable", "global.ok", fallback: "OK")
      /// Optional
      internal static let `optional` = L10n.tr("Localizable", "global.optional", fallback: "Optional")
      /// or
      internal static let or = L10n.tr("Localizable", "global.or", fallback: "or")
      /// Remove
      internal static let remove = L10n.tr("Localizable", "global.remove", fallback: "Remove")
      /// Required
      internal static let `required` = L10n.tr("Localizable", "global.required", fallback: "Required")
      /// Share
      internal static let share = L10n.tr("Localizable", "global.share", fallback: "Share")
      /// No internet connection found. Please confirm that you have an internet connection.
      internal static let unreachable = L10n.tr("Localizable", "global.unreachable", fallback: "No internet connection found. Please confirm that you have an internet connection.")
      /// Update
      internal static let update = L10n.tr("Localizable", "global.update", fallback: "Update")
      /// Version
      internal static let version = L10n.tr("Localizable", "global.version", fallback: "Version")
      /// Yes
      internal static let yes = L10n.tr("Localizable", "global.yes", fallback: "Yes")
      internal enum General {
        /// General Settings
        internal static let settings = L10n.tr("Localizable", "global.general.settings", fallback: "General Settings")
      }
      internal enum Row {
        /// Row selection
        internal static let selection = L10n.tr("Localizable", "global.row.selection", fallback: "Row selection")
      }
      internal enum Vpn {
        /// VPN Settings
        internal static let settings = L10n.tr("Localizable", "global.vpn.settings", fallback: "VPN Settings")
      }
    }
    internal enum Hotspothelper {
      internal enum Display {
        /// 🔒 Activate VPN WiFi Protection in PIA Settings to secure this connection.
        internal static let name = L10n.tr("Localizable", "hotspothelper.display.name", fallback: "🔒 Activate VPN WiFi Protection in PIA Settings to secure this connection.")
        internal enum Protected {
          /// 🔒 PIA VPN WiFi Protection Enabled - We got your back.
          internal static let name = L10n.tr("Localizable", "hotspothelper.display.protected.name", fallback: "🔒 PIA VPN WiFi Protection Enabled - We got your back.")
        }
      }
    }
    internal enum Inapp {
      internal enum Messages {
        internal enum Settings {
          /// Settings have been updated
          internal static let updated = L10n.tr("Localizable", "inapp.messages.settings.updated", fallback: "Settings have been updated")
        }
        internal enum Toggle {
          /// Show Service Communication Messages
          internal static let title = L10n.tr("Localizable", "inapp.messages.toggle.title", fallback: "Show Service Communication Messages")
        }
      }
    }
    internal enum LocalNotification {
      internal enum NonCompliantWifi {
        /// Tap here to secure your device
        internal static let text = L10n.tr("Localizable", "local_notification.non_compliant_wifi.text", fallback: "Tap here to secure your device")
        /// Unsecured Wi-Fi: %@
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "local_notification.non_compliant_wifi.title", String(describing: p1), fallback: "Unsecured Wi-Fi: %@")
        }
      }
    }
    internal enum LocationSelection {
      internal enum AnyOtherLocation {
        /// Selected Location
        internal static let title = L10n.tr("Localizable", "location_selection.any_other_location.title", fallback: "Selected Location")
      }
      internal enum OptimalLocation {
        /// Optimal Location
        internal static let title = L10n.tr("Localizable", "location_selection.optimal_location.title", fallback: "Optimal Location")
      }
    }
    internal enum Menu {
      internal enum Accessibility {
        /// Menu
        internal static let item = L10n.tr("Localizable", "menu.accessibility.item", fallback: "Menu")
        /// Logged in as %@
        internal static func loggedAs(_ p1: Any) -> String {
          return L10n.tr("Localizable", "menu.accessibility.logged_as", String(describing: p1), fallback: "Logged in as %@")
        }
        internal enum Edit {
          /// Edit
          internal static let tile = L10n.tr("Localizable", "menu.accessibility.edit.tile", fallback: "Edit")
        }
      }
      internal enum Expiration {
        /// %d days
        internal static func days(_ p1: Int) -> String {
          return L10n.tr("Localizable", "menu.expiration.days", p1, fallback: "%d days")
        }
        /// Subscription expires in
        internal static let expiresIn = L10n.tr("Localizable", "menu.expiration.expires_in", fallback: "Subscription expires in")
        /// %d hours
        internal static func hours(_ p1: Int) -> String {
          return L10n.tr("Localizable", "menu.expiration.hours", p1, fallback: "%d hours")
        }
        /// one hour
        internal static let oneHour = L10n.tr("Localizable", "menu.expiration.one_hour", fallback: "one hour")
        /// UPGRADE ACCOUNT
        internal static let upgrade = L10n.tr("Localizable", "menu.expiration.upgrade", fallback: "UPGRADE ACCOUNT")
      }
      internal enum Item {
        /// About
        internal static let about = L10n.tr("Localizable", "menu.item.about", fallback: "About")
        /// Account
        internal static let account = L10n.tr("Localizable", "menu.item.account", fallback: "Account")
        /// Log out
        internal static let logout = L10n.tr("Localizable", "menu.item.logout", fallback: "Log out")
        /// Region selection
        internal static let region = L10n.tr("Localizable", "menu.item.region", fallback: "Region selection")
        /// Settings
        internal static let settings = L10n.tr("Localizable", "menu.item.settings", fallback: "Settings")
        internal enum Web {
          /// Home page
          internal static let home = L10n.tr("Localizable", "menu.item.web.home", fallback: "Home page")
          /// Privacy policy
          internal static let privacy = L10n.tr("Localizable", "menu.item.web.privacy", fallback: "Privacy policy")
          /// Support
          internal static let support = L10n.tr("Localizable", "menu.item.web.support", fallback: "Support")
        }
      }
      internal enum Logout {
        /// Log out
        internal static let confirm = L10n.tr("Localizable", "menu.logout.confirm", fallback: "Log out")
        /// Logging out will disable the VPN and leave you unprotected.
        internal static let message = L10n.tr("Localizable", "menu.logout.message", fallback: "Logging out will disable the VPN and leave you unprotected.")
        /// Log out
        internal static let title = L10n.tr("Localizable", "menu.logout.title", fallback: "Log out")
      }
      internal enum Renewal {
        /// Purchase
        internal static let purchase = L10n.tr("Localizable", "menu.renewal.purchase", fallback: "Purchase")
        /// Renew
        internal static let renew = L10n.tr("Localizable", "menu.renewal.renew", fallback: "Renew")
        /// Renewal
        internal static let title = L10n.tr("Localizable", "menu.renewal.title", fallback: "Renewal")
        internal enum Message {
          /// Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.
          internal static let trial = L10n.tr("Localizable", "menu.renewal.message.trial", fallback: "Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.")
          /// Apple servers currently unavailable. Please try again later.
          internal static let unavailable = L10n.tr("Localizable", "menu.renewal.message.unavailable", fallback: "Apple servers currently unavailable. Please try again later.")
          /// Please use our website to renew your subscription.
          internal static let website = L10n.tr("Localizable", "menu.renewal.message.website", fallback: "Please use our website to renew your subscription.")
        }
      }
    }
    internal enum Network {
      internal enum Management {
        internal enum Tool {
          /// Your automation settings are configured to keep the VPN disconnected under the current network conditions.
          internal static let alert = L10n.tr("Localizable", "network.management.tool.alert", fallback: "Your automation settings are configured to keep the VPN disconnected under the current network conditions.")
          /// Disable Automation
          internal static let disable = L10n.tr("Localizable", "network.management.tool.disable", fallback: "Disable Automation")
          /// Manage Automation
          internal static let title = L10n.tr("Localizable", "network.management.tool.title", fallback: "Manage Automation")
          internal enum Add {
            /// Add new rule
            internal static let rule = L10n.tr("Localizable", "network.management.tool.add.rule", fallback: "Add new rule")
          }
          internal enum Always {
            /// Always connect VPN
            internal static let connect = L10n.tr("Localizable", "network.management.tool.always.connect", fallback: "Always connect VPN")
            /// Always disconnect VPN
            internal static let disconnect = L10n.tr("Localizable", "network.management.tool.always.disconnect", fallback: "Always disconnect VPN")
          }
          internal enum Choose {
            /// Choose a WiFi network to add a new rule. 
            internal static let wifi = L10n.tr("Localizable", "network.management.tool.choose.wifi", fallback: "Choose a WiFi network to add a new rule. ")
          }
          internal enum Enable {
            /// Enable Automation
            internal static let automation = L10n.tr("Localizable", "network.management.tool.enable.automation", fallback: "Enable Automation")
          }
          internal enum Mobile {
            /// Mobile data
            internal static let data = L10n.tr("Localizable", "network.management.tool.mobile.data", fallback: "Mobile data")
          }
          internal enum Open {
            /// Open WiFi
            internal static let wifi = L10n.tr("Localizable", "network.management.tool.open.wifi", fallback: "Open WiFi")
          }
          internal enum Retain {
            /// Retain VPN State
            internal static let state = L10n.tr("Localizable", "network.management.tool.retain.state", fallback: "Retain VPN State")
          }
          internal enum Secure {
            /// Secure WiFi
            internal static let wifi = L10n.tr("Localizable", "network.management.tool.secure.wifi", fallback: "Secure WiFi")
          }
        }
      }
    }
    internal enum Notifications {
      internal enum Disabled {
        /// Enable notifications to get a reminder to renew your subscription before it expires.
        internal static let message = L10n.tr("Localizable", "notifications.disabled.message", fallback: "Enable notifications to get a reminder to renew your subscription before it expires.")
        /// Settings
        internal static let settings = L10n.tr("Localizable", "notifications.disabled.settings", fallback: "Settings")
        /// Notifications disabled
        internal static let title = L10n.tr("Localizable", "notifications.disabled.title", fallback: "Notifications disabled")
      }
    }
    internal enum Onboarding {
      internal enum ConnectionStats {
        /// Help us improve by sharing VPN connection statistics. These report never contain personally identifiable information.
        internal static let subtitle = L10n.tr("Localizable", "onboarding.connection_stats.subtitle", fallback: "Help us improve by sharing VPN connection statistics. These report never contain personally identifiable information.")
        /// Help Improve PIA
        internal static let title = L10n.tr("Localizable", "onboarding.connection_stats.title", fallback: "Help Improve PIA")
      }
      internal enum VpnConfiguration {
        /// Configure PIA
        internal static let button = L10n.tr("Localizable", "onboarding.vpn_configuration.button", fallback: "Configure PIA")
        /// When connecting for the first time, you will be asked to allow PIA to access VPN configurations. This is necessary in order to encrypt your traffic. 
        /// 
        /// Please remember that we don't monitor, filter, or log your online activity. 
        /// 
        /// To proceed click on the button below.
        internal static let subtitle = L10n.tr("Localizable", "onboarding.vpn_configuration.subtitle", fallback: "When connecting for the first time, you will be asked to allow PIA to access VPN configurations. This is necessary in order to encrypt your traffic. \n\nPlease remember that we don't monitor, filter, or log your online activity. \n\nTo proceed click on the button below.")
        /// Configure PIA
        internal static let title = L10n.tr("Localizable", "onboarding.vpn_configuration.title", fallback: "Configure PIA")
      }
    }
    internal enum Rating {
      internal enum Alert {
        internal enum Button {
          /// No, thanks.
          internal static let nothanks = L10n.tr("Localizable", "rating.alert.button.nothanks", fallback: "No, thanks.")
          /// Not Really
          internal static let notreally = L10n.tr("Localizable", "rating.alert.button.notreally", fallback: "Not Really")
          /// Ok, sure!
          internal static let oksure = L10n.tr("Localizable", "rating.alert.button.oksure", fallback: "Ok, sure!")
        }
      }
      internal enum Enjoy {
        /// Are you enjoying PIA VPN?
        internal static let question = L10n.tr("Localizable", "rating.enjoy.question", fallback: "Are you enjoying PIA VPN?")
        /// We hope our VPN product is meeting your expectations
        internal static let subtitle = L10n.tr("Localizable", "rating.enjoy.subtitle", fallback: "We hope our VPN product is meeting your expectations")
      }
      internal enum Error {
        /// The connection couldn't be established
        internal static let question = L10n.tr("Localizable", "rating.error.question", fallback: "The connection couldn't be established")
        /// You can try selecting a different region or letting us know about it by opening a support ticket.
        internal static let subtitle = L10n.tr("Localizable", "rating.error.subtitle", fallback: "You can try selecting a different region or letting us know about it by opening a support ticket.")
        internal enum Button {
          /// Send feedback
          internal static let send = L10n.tr("Localizable", "rating.error.button.send", fallback: "Send feedback")
        }
      }
      internal enum Problems {
        /// What went wrong?
        internal static let question = L10n.tr("Localizable", "rating.problems.question", fallback: "What went wrong?")
        /// Do you want to give feedback? We can help you to improve your experience using PIA
        internal static let subtitle = L10n.tr("Localizable", "rating.problems.subtitle", fallback: "Do you want to give feedback? We can help you to improve your experience using PIA")
      }
      internal enum Rate {
        /// How about a rating on the AppStore?
        internal static let question = L10n.tr("Localizable", "rating.rate.question", fallback: "How about a rating on the AppStore?")
        /// We appreciate you sharing your experience
        internal static let subtitle = L10n.tr("Localizable", "rating.rate.subtitle", fallback: "We appreciate you sharing your experience")
      }
      internal enum Review {
        /// How about an AppStore review?
        internal static let question = L10n.tr("Localizable", "rating.review.question", fallback: "How about an AppStore review?")
      }
    }
    internal enum Region {
      internal enum Accessibility {
        /// Add a favorite region
        internal static let favorite = L10n.tr("Localizable", "region.accessibility.favorite", fallback: "Add a favorite region")
        /// Filter
        internal static let filter = L10n.tr("Localizable", "region.accessibility.filter", fallback: "Filter")
        /// Remove a favorite region
        internal static let unfavorite = L10n.tr("Localizable", "region.accessibility.unfavorite", fallback: "Remove a favorite region")
      }
      internal enum Filter {
        /// Favorites
        internal static let favorites = L10n.tr("Localizable", "region.filter.favorites", fallback: "Favorites")
        /// Latency
        internal static let latency = L10n.tr("Localizable", "region.filter.latency", fallback: "Latency")
        /// Name
        internal static let name = L10n.tr("Localizable", "region.filter.name", fallback: "Name")
        /// Sort regions by
        internal static let sortby = L10n.tr("Localizable", "region.filter.sortby", fallback: "Sort regions by")
      }
      internal enum Search {
        /// Search for a region
        internal static let placeholder = L10n.tr("Localizable", "region.search.placeholder", fallback: "Search for a region")
      }
    }
    internal enum Regions {
      internal enum ContextMenu {
        internal enum Favorites {
          internal enum Add {
            /// Add to Favorites
            internal static let text = L10n.tr("Localizable", "regions.context_menu.favorites.add.text", fallback: "Add to Favorites")
          }
          internal enum Remove {
            /// Remove from Favorites
            internal static let text = L10n.tr("Localizable", "regions.context_menu.favorites.remove.text", fallback: "Remove from Favorites")
          }
        }
      }
      internal enum Filter {
        internal enum All {
          /// All
          internal static let title = L10n.tr("Localizable", "regions.filter.all.title", fallback: "All")
        }
        internal enum Favorites {
          /// Favourite(s)
          internal static let title = L10n.tr("Localizable", "regions.filter.favorites.title", fallback: "Favourite(s)")
        }
        internal enum Search {
          /// Search
          internal static let title = L10n.tr("Localizable", "regions.filter.search.title", fallback: "Search")
        }
      }
      internal enum List {
        internal enum AllLocations {
          /// All Locations
          internal static let title = L10n.tr("Localizable", "regions.list.all_locations.title", fallback: "All Locations")
        }
        internal enum OptimalLocation {
          /// Optimal Location
          internal static let title = L10n.tr("Localizable", "regions.list.optimal_location.title", fallback: "Optimal Location")
        }
        internal enum OptimalLocationWithDipLocation {
          /// Optimal Location/Dedicated IP
          internal static let title = L10n.tr("Localizable", "regions.list.optimal_location_with_dip_location.title", fallback: "Optimal Location/Dedicated IP")
        }
      }
      internal enum ListItem {
        internal enum Default {
          /// Default Location
          internal static let title = L10n.tr("Localizable", "regions.list_item.default.title", fallback: "Default Location")
        }
      }
      internal enum Search {
        internal enum Button {
          /// Search for a Location
          internal static let title = L10n.tr("Localizable", "regions.search.button.title", fallback: "Search for a Location")
        }
        internal enum InputField {
          /// Search for city or country
          internal static let placeholder = L10n.tr("Localizable", "regions.search.input_field.placeholder", fallback: "Search for city or country")
        }
        internal enum PreviousResults {
          /// Last Searched Locations
          internal static let title = L10n.tr("Localizable", "regions.search.previous_results.title", fallback: "Last Searched Locations")
        }
        internal enum RecommendedLocations {
          /// Recommended Locations
          internal static let title = L10n.tr("Localizable", "regions.search.recommended_locations.title", fallback: "Recommended Locations")
        }
        internal enum Results {
          /// Search Results
          internal static let title = L10n.tr("Localizable", "regions.search.results.title", fallback: "Search Results")
        }
      }
    }
    internal enum Renewal {
      internal enum Failure {
        /// Your purchase receipt couldn't be submitted, please retry at a later time.
        internal static let message = L10n.tr("Localizable", "renewal.failure.message", fallback: "Your purchase receipt couldn't be submitted, please retry at a later time.")
      }
      internal enum Success {
        /// Your account was successfully renewed.
        internal static let message = L10n.tr("Localizable", "renewal.success.message", fallback: "Your account was successfully renewed.")
        /// Thank you
        internal static let title = L10n.tr("Localizable", "renewal.success.title", fallback: "Thank you")
      }
    }
    internal enum Server {
      internal enum Reconnection {
        internal enum Please {
          /// Please wait...
          internal static let wait = L10n.tr("Localizable", "server.reconnection.please.wait", fallback: "Please wait...")
        }
        internal enum Still {
          /// Still trying to connect...
          internal static let connection = L10n.tr("Localizable", "server.reconnection.still.connection", fallback: "Still trying to connect...")
        }
      }
    }
    internal enum Set {
      internal enum Email {
        /// We need your email to send your username and password.
        internal static let why = L10n.tr("Localizable", "set.email.why", fallback: "We need your email to send your username and password.")
        internal enum Error {
          /// You must enter an email address.
          internal static let validation = L10n.tr("Localizable", "set.email.error.validation", fallback: "You must enter an email address.")
        }
        internal enum Form {
          /// Enter your email address
          internal static let email = L10n.tr("Localizable", "set.email.form.email", fallback: "Enter your email address")
        }
        internal enum Password {
          /// Password
          internal static let caption = L10n.tr("Localizable", "set.email.password.caption", fallback: "Password")
        }
        internal enum Success {
          /// We have sent your account username and password at your email address at %@
          internal static func messageFormat(_ p1: Any) -> String {
            return L10n.tr("Localizable", "set.email.success.message_format", String(describing: p1), fallback: "We have sent your account username and password at your email address at %@")
          }
        }
      }
    }
    internal enum Settings {
      internal enum Account {
        internal enum LogOutAlert {
          /// Logging out will terminate any active VPN connection and leave you unprotected.
          internal static let message = L10n.tr("Localizable", "settings.account.log_out_alert.message", fallback: "Logging out will terminate any active VPN connection and leave you unprotected.")
          /// Are you sure?
          internal static let title = L10n.tr("Localizable", "settings.account.log_out_alert.title", fallback: "Are you sure?")
        }
        internal enum LogOutButton {
          /// Log Out
          internal static let title = L10n.tr("Localizable", "settings.account.log_out_button.title", fallback: "Log Out")
        }
        internal enum SubscriptionExpiry {
          /// Subscription expires on
          internal static let title = L10n.tr("Localizable", "settings.account.subscription_expiry.title", fallback: "Subscription expires on")
        }
      }
      internal enum ApplicationInformation {
        /// APPLICATION INFORMATION
        internal static let title = L10n.tr("Localizable", "settings.application_information.title", fallback: "APPLICATION INFORMATION")
        internal enum Debug {
          /// Send Debug Log to support
          internal static let title = L10n.tr("Localizable", "settings.application_information.debug.title", fallback: "Send Debug Log to support")
          internal enum Empty {
            /// Debug information is empty, please attempt a connection before retrying submission.
            internal static let message = L10n.tr("Localizable", "settings.application_information.debug.empty.message", fallback: "Debug information is empty, please attempt a connection before retrying submission.")
            /// Empty debug information
            internal static let title = L10n.tr("Localizable", "settings.application_information.debug.empty.title", fallback: "Empty debug information")
          }
          internal enum Failure {
            /// Debug information could not be submitted.
            internal static let message = L10n.tr("Localizable", "settings.application_information.debug.failure.message", fallback: "Debug information could not be submitted.")
            /// Error during submission
            internal static let title = L10n.tr("Localizable", "settings.application_information.debug.failure.title", fallback: "Error during submission")
          }
          internal enum Success {
            /// Debug information successfully submitted.
            /// ID: %@
            /// Please note this ID, as our support team will require this to locate your submission.
            internal static func message(_ p1: Any) -> String {
              return L10n.tr("Localizable", "settings.application_information.debug.success.message", String(describing: p1), fallback: "Debug information successfully submitted.\nID: %@\nPlease note this ID, as our support team will require this to locate your submission.")
            }
            /// Debug information submitted
            internal static let title = L10n.tr("Localizable", "settings.application_information.debug.success.title", fallback: "Debug information submitted")
          }
        }
      }
      internal enum ApplicationSettings {
        /// APPLICATION SETTINGS
        internal static let title = L10n.tr("Localizable", "settings.application_settings.title", fallback: "APPLICATION SETTINGS")
        internal enum ActiveTheme {
          /// Active theme
          internal static let title = L10n.tr("Localizable", "settings.application_settings.active_theme.title", fallback: "Active theme")
        }
        internal enum AllowLocalNetwork {
          /// Stay connected to local devices like printers or file servers while connected to the VPN. (Allow this only if you trust the people and devices on your network.)
          internal static let footer = L10n.tr("Localizable", "settings.application_settings.allow_local_network.footer", fallback: "Stay connected to local devices like printers or file servers while connected to the VPN. (Allow this only if you trust the people and devices on your network.)")
          /// Allow access to devices on local network
          internal static let title = L10n.tr("Localizable", "settings.application_settings.allow_local_network.title", fallback: "Allow access to devices on local network")
        }
        internal enum DarkTheme {
          /// Dark theme
          internal static let title = L10n.tr("Localizable", "settings.application_settings.dark_theme.title", fallback: "Dark theme")
        }
        internal enum KillSwitch {
          /// The VPN kill switch prevents access to the Internet if the VPN connection is reconnecting. This excludes disconnecting manually.
          internal static let footer = L10n.tr("Localizable", "settings.application_settings.kill_switch.footer", fallback: "The VPN kill switch prevents access to the Internet if the VPN connection is reconnecting. This excludes disconnecting manually.")
          /// VPN Kill Switch
          internal static let title = L10n.tr("Localizable", "settings.application_settings.kill_switch.title", fallback: "VPN Kill Switch")
        }
        internal enum LeakProtection {
          /// iOS includes features designed to operate outside the VPN by default, such as AirDrop, CarPlay, AirPlay, and Personal Hotspots. Enabling custom leak protection routes this traffic through the VPN but may affect how these features function. More info
          internal static let footer = L10n.tr("Localizable", "settings.application_settings.leak_protection.footer", fallback: "iOS includes features designed to operate outside the VPN by default, such as AirDrop, CarPlay, AirPlay, and Personal Hotspots. Enabling custom leak protection routes this traffic through the VPN but may affect how these features function. More info")
          /// More info
          internal static let moreInfo = L10n.tr("Localizable", "settings.application_settings.leak_protection.more_info", fallback: "More info")
          /// Leak Protection
          internal static let title = L10n.tr("Localizable", "settings.application_settings.leak_protection.title", fallback: "Leak Protection")
          internal enum Alert {
            /// Changes to the VPN Settings will take effect on the next connection
            internal static let title = L10n.tr("Localizable", "settings.application_settings.leak_protection.alert.title", fallback: "Changes to the VPN Settings will take effect on the next connection")
          }
        }
        internal enum Mace {
          /// PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.
          internal static let footer = L10n.tr("Localizable", "settings.application_settings.mace.footer", fallback: "PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.")
          /// PIA MACE™
          internal static let title = L10n.tr("Localizable", "settings.application_settings.mace.title", fallback: "PIA MACE™")
        }
      }
      internal enum Cards {
        internal enum History {
          /// Latest News
          internal static let title = L10n.tr("Localizable", "settings.cards.history.title", fallback: "Latest News")
        }
      }
      internal enum Commit {
        internal enum Buttons {
          /// Later
          internal static let later = L10n.tr("Localizable", "settings.commit.buttons.later", fallback: "Later")
          /// Reconnect
          internal static let reconnect = L10n.tr("Localizable", "settings.commit.buttons.reconnect", fallback: "Reconnect")
        }
        internal enum Messages {
          /// The VPN must reconnect for some changes to take effect.
          internal static let mustDisconnect = L10n.tr("Localizable", "settings.commit.messages.must_disconnect", fallback: "The VPN must reconnect for some changes to take effect.")
          /// Reconnect the VPN to apply changes.
          internal static let shouldReconnect = L10n.tr("Localizable", "settings.commit.messages.should_reconnect", fallback: "Reconnect the VPN to apply changes.")
        }
      }
      internal enum Connection {
        /// CONNECTION
        internal static let title = L10n.tr("Localizable", "settings.connection.title", fallback: "CONNECTION")
        internal enum RemotePort {
          /// Remote Port
          internal static let title = L10n.tr("Localizable", "settings.connection.remote_port.title", fallback: "Remote Port")
        }
        internal enum SocketProtocol {
          /// Socket
          internal static let title = L10n.tr("Localizable", "settings.connection.socket_protocol.title", fallback: "Socket")
        }
        internal enum Transport {
          /// Transport
          internal static let title = L10n.tr("Localizable", "settings.connection.transport.title", fallback: "Transport")
        }
        internal enum VpnProtocol {
          /// Protocol Selection
          internal static let title = L10n.tr("Localizable", "settings.connection.vpn_protocol.title", fallback: "Protocol Selection")
        }
      }
      internal enum ContentBlocker {
        /// To enable or disable Content Blocker go to Settings > Safari > Content Blockers and toggle PIA VPN.
        internal static let footer = L10n.tr("Localizable", "settings.content_blocker.footer", fallback: "To enable or disable Content Blocker go to Settings > Safari > Content Blockers and toggle PIA VPN.")
        /// Safari Content Blocker state
        internal static let title = L10n.tr("Localizable", "settings.content_blocker.title", fallback: "Safari Content Blocker state")
        internal enum Refresh {
          /// Refresh block list
          internal static let title = L10n.tr("Localizable", "settings.content_blocker.refresh.title", fallback: "Refresh block list")
        }
        internal enum State {
          /// Current state
          internal static let title = L10n.tr("Localizable", "settings.content_blocker.state.title", fallback: "Current state")
        }
      }
      internal enum Dedicatedip {
        /// Activate
        internal static let button = L10n.tr("Localizable", "settings.dedicatedip.button", fallback: "Activate")
        /// Enter Dedicated IP
        internal static let placeholder = L10n.tr("Localizable", "settings.dedicatedip.placeholder", fallback: "Enter Dedicated IP")
        /// Activate your Dedicated IP by typing your token in the field 
        /// below. If you've recently purchased a Dedicated IP, you can 
        /// generate the token by visiting your PIA account
        internal static let subtitle = L10n.tr("Localizable", "settings.dedicatedip.subtitle", fallback: "Activate your Dedicated IP by typing your token in the field \nbelow. If you've recently purchased a Dedicated IP, you can \ngenerate the token by visiting your PIA account")
        /// Enter 
        internal static let title1 = L10n.tr("Localizable", "settings.dedicatedip.title1", fallback: "Enter ")
        /// Dedicated IP
        internal static let title2 = L10n.tr("Localizable", "settings.dedicatedip.title2", fallback: "Dedicated IP")
        internal enum Alert {
          /// Your token is either invalid or has expired.
          internal static let message = L10n.tr("Localizable", "settings.dedicatedip.alert.message", fallback: "Your token is either invalid or has expired.")
          /// Something went wrong
          internal static let title = L10n.tr("Localizable", "settings.dedicatedip.alert.title", fallback: "Something went wrong")
          internal enum Message {
            /// Your token can't be empty.
            internal static let empty = L10n.tr("Localizable", "settings.dedicatedip.alert.message.empty", fallback: "Your token can't be empty.")
          }
        }
        internal enum Stats {
          /// Dedicated IP
          internal static let dedicatedip = L10n.tr("Localizable", "settings.dedicatedip.stats.dedicatedip", fallback: "Dedicated IP")
          /// IP Address
          internal static let ip = L10n.tr("Localizable", "settings.dedicatedip.stats.ip", fallback: "IP Address")
          /// Location
          internal static let location = L10n.tr("Localizable", "settings.dedicatedip.stats.location", fallback: "Location")
          /// Quick Action
          internal static let quickAction = L10n.tr("Localizable", "settings.dedicatedip.stats.quickAction", fallback: "Quick Action")
          internal enum Delete {
            /// Delete Dedicated IP
            internal static let button = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.button", fallback: "Delete Dedicated IP")
            internal enum Alert {
              /// Yes, Delete
              internal static let delete = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.delete", fallback: "Yes, Delete")
              /// You are about to remove your Dedicated IP from your account.
              internal static let message = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.message", fallback: "You are about to remove your Dedicated IP from your account.")
              /// Are you sure?
              internal static let title = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.title", fallback: "Are you sure?")
            }
          }
        }
        internal enum Status {
          /// Active
          internal static let active = L10n.tr("Localizable", "settings.dedicatedip.status.active", fallback: "Active")
          /// Error
          internal static let error = L10n.tr("Localizable", "settings.dedicatedip.status.error", fallback: "Error")
          /// Expired
          internal static let expired = L10n.tr("Localizable", "settings.dedicatedip.status.expired", fallback: "Expired")
          /// Invalid
          internal static let invalid = L10n.tr("Localizable", "settings.dedicatedip.status.invalid", fallback: "Invalid")
        }
      }
      internal enum Dns {
        /// Custom
        internal static let custom = L10n.tr("Localizable", "settings.dns.custom", fallback: "Custom")
        /// Primary DNS
        internal static let primaryDNS = L10n.tr("Localizable", "settings.dns.primaryDNS", fallback: "Primary DNS")
        /// Secondary DNS
        internal static let secondaryDNS = L10n.tr("Localizable", "settings.dns.secondaryDNS", fallback: "Secondary DNS")
        internal enum Alert {
          internal enum Clear {
            /// This will clear your custom DNS and default to PIA DNS.
            internal static let message = L10n.tr("Localizable", "settings.dns.alert.clear.message", fallback: "This will clear your custom DNS and default to PIA DNS.")
            /// Clear DNS
            internal static let title = L10n.tr("Localizable", "settings.dns.alert.clear.title", fallback: "Clear DNS")
          }
          internal enum Create {
            /// Using non PIA DNS could expose your DNS traffic to third parties and compromise your privacy.
            internal static let message = L10n.tr("Localizable", "settings.dns.alert.create.message", fallback: "Using non PIA DNS could expose your DNS traffic to third parties and compromise your privacy.")
          }
        }
        internal enum Custom {
          /// Custom DNS
          internal static let dns = L10n.tr("Localizable", "settings.dns.custom.dns", fallback: "Custom DNS")
        }
        internal enum Validation {
          internal enum Primary {
            /// Primary DNS is not valid.
            internal static let invalid = L10n.tr("Localizable", "settings.dns.validation.primary.invalid", fallback: "Primary DNS is not valid.")
            /// Primary DNS is mandatory.
            internal static let mandatory = L10n.tr("Localizable", "settings.dns.validation.primary.mandatory", fallback: "Primary DNS is mandatory.")
          }
          internal enum Secondary {
            /// Secondary DNS is not valid.
            internal static let invalid = L10n.tr("Localizable", "settings.dns.validation.secondary.invalid", fallback: "Secondary DNS is not valid.")
          }
        }
      }
      internal enum Encryption {
        /// ENCRYPTION
        internal static let title = L10n.tr("Localizable", "settings.encryption.title", fallback: "ENCRYPTION")
        internal enum Cipher {
          /// Data Encryption
          internal static let title = L10n.tr("Localizable", "settings.encryption.cipher.title", fallback: "Data Encryption")
        }
        internal enum Digest {
          /// Data Authentication
          internal static let title = L10n.tr("Localizable", "settings.encryption.digest.title", fallback: "Data Authentication")
        }
        internal enum Handshake {
          /// Handshake
          internal static let title = L10n.tr("Localizable", "settings.encryption.handshake.title", fallback: "Handshake")
        }
      }
      internal enum Geo {
        internal enum Servers {
          /// Show Geo-located Regions
          internal static let description = L10n.tr("Localizable", "settings.geo.servers.description", fallback: "Show Geo-located Regions")
        }
      }
      internal enum Hotspothelper {
        /// Configure how PIA will behaves on connection to WiFi or cellular networks. This excludes disconnecting manually.
        internal static let description = L10n.tr("Localizable", "settings.hotspothelper.description", fallback: "Configure how PIA will behaves on connection to WiFi or cellular networks. This excludes disconnecting manually.")
        /// Network management tool
        internal static let title = L10n.tr("Localizable", "settings.hotspothelper.title", fallback: "Network management tool")
        internal enum All {
          /// VPN WiFi Protection will activate on all networks, including trusted networks.
          internal static let description = L10n.tr("Localizable", "settings.hotspothelper.all.description", fallback: "VPN WiFi Protection will activate on all networks, including trusted networks.")
          /// Protect all networks
          internal static let title = L10n.tr("Localizable", "settings.hotspothelper.all.title", fallback: "Protect all networks")
        }
        internal enum Available {
          /// To populate this list go to iOS Settings > WiFi.
          internal static let help = L10n.tr("Localizable", "settings.hotspothelper.available.help", fallback: "To populate this list go to iOS Settings > WiFi.")
          internal enum Add {
            /// Tap + to add to Trusted networks.
            internal static let help = L10n.tr("Localizable", "settings.hotspothelper.available.add.help", fallback: "Tap + to add to Trusted networks.")
          }
        }
        internal enum Cellular {
          /// PIA automatically enables the VPN when connecting to cellular networks if this option is enabled.
          internal static let description = L10n.tr("Localizable", "settings.hotspothelper.cellular.description", fallback: "PIA automatically enables the VPN when connecting to cellular networks if this option is enabled.")
          /// Cellular networks
          internal static let networks = L10n.tr("Localizable", "settings.hotspothelper.cellular.networks", fallback: "Cellular networks")
          /// Protect over cellular networks
          internal static let title = L10n.tr("Localizable", "settings.hotspothelper.cellular.title", fallback: "Protect over cellular networks")
        }
        internal enum Enable {
          /// PIA automatically enables the VPN when connecting to untrusted WiFi networks if this option is enabled.
          internal static let description = L10n.tr("Localizable", "settings.hotspothelper.enable.description", fallback: "PIA automatically enables the VPN when connecting to untrusted WiFi networks if this option is enabled.")
        }
        internal enum Rules {
          /// Rules
          internal static let title = L10n.tr("Localizable", "settings.hotspothelper.rules.title", fallback: "Rules")
        }
        internal enum Wifi {
          /// WiFi networks
          internal static let networks = L10n.tr("Localizable", "settings.hotspothelper.wifi.networks", fallback: "WiFi networks")
          internal enum Trust {
            /// VPN WiFi Protection
            internal static let title = L10n.tr("Localizable", "settings.hotspothelper.wifi.trust.title", fallback: "VPN WiFi Protection")
          }
        }
      }
      internal enum Log {
        /// Save debug logs which can be submitted to technical support to help troubleshoot problems.
        internal static let information = L10n.tr("Localizable", "settings.log.information", fallback: "Save debug logs which can be submitted to technical support to help troubleshoot problems.")
        internal enum Connected {
          /// A VPN connection is required. Please connect to the VPN and retry.
          internal static let error = L10n.tr("Localizable", "settings.log.connected.error", fallback: "A VPN connection is required. Please connect to the VPN and retry.")
        }
      }
      internal enum Nmt {
        internal enum Killswitch {
          /// The VPN kill switch is currently disabled. In order to ensure that the Network Management Tool is functioning, and that you are able to reconnect when switching networks, please enable the VPN kill switch in your settings.
          internal static let disabled = L10n.tr("Localizable", "settings.nmt.killswitch.disabled", fallback: "The VPN kill switch is currently disabled. In order to ensure that the Network Management Tool is functioning, and that you are able to reconnect when switching networks, please enable the VPN kill switch in your settings.")
        }
        internal enum Optout {
          internal enum Disconnect {
            /// Opt-out disconnect confirmation alert
            internal static let alerts = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts", fallback: "Opt-out disconnect confirmation alert")
            internal enum Alerts {
              /// Disables the warning alert when disconnecting from the VPN.
              internal static let description = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts.description", fallback: "Disables the warning alert when disconnecting from the VPN.")
            }
          }
        }
        internal enum Wireguard {
          /// WireGuard® doesn't need to reconnect when you switch between different networks. It may be necessary to manually disconnect the VPN on trusted networks.
          internal static let warning = L10n.tr("Localizable", "settings.nmt.wireguard.warning", fallback: "WireGuard® doesn't need to reconnect when you switch between different networks. It may be necessary to manually disconnect the VPN on trusted networks.")
        }
      }
      internal enum Ovpn {
        internal enum Migration {
          /// We are updating our OpenVPN implementation, for more information, click here
          internal static let footer = L10n.tr("Localizable", "settings.ovpn.migration.footer", fallback: "We are updating our OpenVPN implementation, for more information, click here")
          internal enum Footer {
            /// here
            internal static let link = L10n.tr("Localizable", "settings.ovpn.migration.footer.link", fallback: "here")
          }
        }
      }
      internal enum Preview {
        /// Preview
        internal static let title = L10n.tr("Localizable", "settings.preview.title", fallback: "Preview")
      }
      internal enum Reset {
        /// This will reset all of the above settings to default.
        internal static let footer = L10n.tr("Localizable", "settings.reset.footer", fallback: "This will reset all of the above settings to default.")
        /// RESET
        internal static let title = L10n.tr("Localizable", "settings.reset.title", fallback: "RESET")
        internal enum Defaults {
          /// Reset settings to default
          internal static let title = L10n.tr("Localizable", "settings.reset.defaults.title", fallback: "Reset settings to default")
          internal enum Confirm {
            /// Reset
            internal static let button = L10n.tr("Localizable", "settings.reset.defaults.confirm.button", fallback: "Reset")
            /// This will bring the app back to default. You will lose all changes you have made.
            internal static let message = L10n.tr("Localizable", "settings.reset.defaults.confirm.message", fallback: "This will bring the app back to default. You will lose all changes you have made.")
            /// Reset settings
            internal static let title = L10n.tr("Localizable", "settings.reset.defaults.confirm.title", fallback: "Reset settings")
          }
        }
      }
      internal enum Section {
        /// Automation
        internal static let automation = L10n.tr("Localizable", "settings.section.automation", fallback: "Automation")
        /// General
        internal static let general = L10n.tr("Localizable", "settings.section.general", fallback: "General")
        /// Help
        internal static let help = L10n.tr("Localizable", "settings.section.help", fallback: "Help")
        /// Network
        internal static let network = L10n.tr("Localizable", "settings.section.network", fallback: "Network")
        /// Privacy Features
        internal static let privacyFeatures = L10n.tr("Localizable", "settings.section.privacyFeatures", fallback: "Privacy Features")
        /// Protocols
        internal static let protocols = L10n.tr("Localizable", "settings.section.protocols", fallback: "Protocols")
      }
      internal enum Server {
        internal enum Network {
          /// The VPN has to be disconnected to change the server network.
          internal static let alert = L10n.tr("Localizable", "settings.server.network.alert", fallback: "The VPN has to be disconnected to change the server network.")
          /// Next generation network
          internal static let description = L10n.tr("Localizable", "settings.server.network.description", fallback: "Next generation network")
        }
      }
      internal enum Service {
        internal enum Quality {
          internal enum Share {
            /// Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.
            internal static let description = L10n.tr("Localizable", "settings.service.quality.share.description", fallback: "Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.")
            /// Find out more
            internal static let findoutmore = L10n.tr("Localizable", "settings.service.quality.share.findoutmore", fallback: "Find out more")
            /// Help improve PIA
            internal static let title = L10n.tr("Localizable", "settings.service.quality.share.title", fallback: "Help improve PIA")
          }
          internal enum Show {
            /// Connection stats
            internal static let title = L10n.tr("Localizable", "settings.service.quality.show.title", fallback: "Connection stats")
          }
        }
      }
      internal enum Small {
        internal enum Packets {
          /// Will slightly lower the IP packet size to improve compatibility with some routers and mobile networks.
          internal static let description = L10n.tr("Localizable", "settings.small.packets.description", fallback: "Will slightly lower the IP packet size to improve compatibility with some routers and mobile networks.")
          /// Use Small Packets
          internal static let title = L10n.tr("Localizable", "settings.small.packets.title", fallback: "Use Small Packets")
        }
      }
      internal enum Trusted {
        internal enum Networks {
          /// PIA won't automatically connect on these networks.
          internal static let message = L10n.tr("Localizable", "settings.trusted.networks.message", fallback: "PIA won't automatically connect on these networks.")
          internal enum Connect {
            /// Protect this network by connecting to VPN?
            internal static let message = L10n.tr("Localizable", "settings.trusted.networks.connect.message", fallback: "Protect this network by connecting to VPN?")
          }
          internal enum Sections {
            /// Available networks
            internal static let available = L10n.tr("Localizable", "settings.trusted.networks.sections.available", fallback: "Available networks")
            /// Current network
            internal static let current = L10n.tr("Localizable", "settings.trusted.networks.sections.current", fallback: "Current network")
            /// Trusted networks
            internal static let trusted = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted", fallback: "Trusted networks")
            /// Untrusted networks
            internal static let untrusted = L10n.tr("Localizable", "settings.trusted.networks.sections.untrusted", fallback: "Untrusted networks")
            internal enum Trusted {
              internal enum Rule {
                /// Disconnect from PIA VPN
                internal static let action = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.action", fallback: "Disconnect from PIA VPN")
                /// Enable this feature, with the VPN kill switch enabled, to customize how PIA will behave on WiFi and cellular networks. Please be aware, functionality of the Network Management Tool will be disabled if you manually disconnect.
                internal static let description = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.description", fallback: "Enable this feature, with the VPN kill switch enabled, to customize how PIA will behave on WiFi and cellular networks. Please be aware, functionality of the Network Management Tool will be disabled if you manually disconnect.")
              }
            }
          }
        }
      }
    }
    internal enum Shortcuts {
      /// Connect
      internal static let connect = L10n.tr("Localizable", "shortcuts.connect", fallback: "Connect")
      /// Disconnect
      internal static let disconnect = L10n.tr("Localizable", "shortcuts.disconnect", fallback: "Disconnect")
      /// Select a region
      internal static let selectRegion = L10n.tr("Localizable", "shortcuts.select_region", fallback: "Select a region")
    }
    internal enum Siri {
      internal enum Shortcuts {
        internal enum Add {
          /// There was an error adding the Siri shortcut. Please, try it again.
          internal static let error = L10n.tr("Localizable", "siri.shortcuts.add.error", fallback: "There was an error adding the Siri shortcut. Please, try it again.")
        }
        internal enum Connect {
          /// Connect PIA VPN
          internal static let title = L10n.tr("Localizable", "siri.shortcuts.connect.title", fallback: "Connect PIA VPN")
          internal enum Row {
            /// 'Connect' Siri Shortcut
            internal static let title = L10n.tr("Localizable", "siri.shortcuts.connect.row.title", fallback: "'Connect' Siri Shortcut")
          }
        }
        internal enum Disconnect {
          /// Disconnect PIA VPN
          internal static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.title", fallback: "Disconnect PIA VPN")
          internal enum Row {
            /// 'Disconnect' Siri Shortcut
            internal static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.row.title", fallback: "'Disconnect' Siri Shortcut")
          }
        }
      }
    }
    internal enum Tiles {
      internal enum Accessibility {
        internal enum Invisible {
          internal enum Tile {
            /// Tap to add this tile to the dashboard
            internal static let action = L10n.tr("Localizable", "tiles.accessibility.invisible.tile.action", fallback: "Tap to add this tile to the dashboard")
          }
        }
        internal enum Visible {
          internal enum Tile {
            /// Tap to remove this tile from the dashboard
            internal static let action = L10n.tr("Localizable", "tiles.accessibility.visible.tile.action", fallback: "Tap to remove this tile from the dashboard")
          }
        }
      }
      internal enum Favorite {
        internal enum Servers {
          /// Favorite servers
          internal static let title = L10n.tr("Localizable", "tiles.favorite.servers.title", fallback: "Favorite servers")
        }
      }
      internal enum Nmt {
        /// Cellular
        internal static let cellular = L10n.tr("Localizable", "tiles.nmt.cellular", fallback: "Cellular")
        internal enum Accessibility {
          /// Trusted network
          internal static let trusted = L10n.tr("Localizable", "tiles.nmt.accessibility.trusted", fallback: "Trusted network")
          /// Untrusted network
          internal static let untrusted = L10n.tr("Localizable", "tiles.nmt.accessibility.untrusted", fallback: "Untrusted network")
        }
      }
      internal enum Quick {
        internal enum Connect {
          /// Quick connect
          internal static let title = L10n.tr("Localizable", "tiles.quick.connect.title", fallback: "Quick connect")
        }
      }
      internal enum Quicksetting {
        internal enum Nmt {
          /// Network Management
          internal static let title = L10n.tr("Localizable", "tiles.quicksetting.nmt.title", fallback: "Network Management")
        }
        internal enum Private {
          internal enum Browser {
            /// Private Browser
            internal static let title = L10n.tr("Localizable", "tiles.quicksetting.private.browser.title", fallback: "Private Browser")
          }
        }
      }
      internal enum Quicksettings {
        /// Quick settings
        internal static let title = L10n.tr("Localizable", "tiles.quicksettings.title", fallback: "Quick settings")
        internal enum Min {
          internal enum Elements {
            /// You should keep at least one element visible in the Quick Settings Tile
            internal static let message = L10n.tr("Localizable", "tiles.quicksettings.min.elements.message", fallback: "You should keep at least one element visible in the Quick Settings Tile")
          }
        }
      }
      internal enum Region {
        /// VPN Server
        internal static let title = L10n.tr("Localizable", "tiles.region.title", fallback: "VPN Server")
      }
      internal enum Subscription {
        /// Monthly
        internal static let monthly = L10n.tr("Localizable", "tiles.subscription.monthly", fallback: "Monthly")
        /// Subscription
        internal static let title = L10n.tr("Localizable", "tiles.subscription.title", fallback: "Subscription")
        /// Trial
        internal static let trial = L10n.tr("Localizable", "tiles.subscription.trial", fallback: "Trial")
        /// Yearly
        internal static let yearly = L10n.tr("Localizable", "tiles.subscription.yearly", fallback: "Yearly")
        internal enum Days {
          /// (%d days left)
          internal static func `left`(_ p1: Int) -> String {
            return L10n.tr("Localizable", "tiles.subscription.days.left", p1, fallback: "(%d days left)")
          }
        }
      }
      internal enum Usage {
        /// Download
        internal static let download = L10n.tr("Localizable", "tiles.usage.download", fallback: "Download")
        /// Usage
        internal static let title = L10n.tr("Localizable", "tiles.usage.title", fallback: "Usage")
        /// Upload
        internal static let upload = L10n.tr("Localizable", "tiles.usage.upload", fallback: "Upload")
        internal enum Ipsec {
          /// USAGE (Not available on IKEv2)
          internal static let title = L10n.tr("Localizable", "tiles.usage.ipsec.title", fallback: "USAGE (Not available on IKEv2)")
        }
      }
    }
    internal enum Today {
      internal enum Widget {
        /// Login
        internal static let login = L10n.tr("Localizable", "today.widget.login", fallback: "Login")
      }
    }
    internal enum TopNavigationBar {
      internal enum LocationItem {
        /// Location
        internal static let title = L10n.tr("Localizable", "top_navigation_bar.location_item.title", fallback: "Location")
      }
      internal enum LocationSelectionScreen {
        /// Location Selection
        internal static let title = L10n.tr("Localizable", "top_navigation_bar.location_selection_screen.title", fallback: "Location Selection")
      }
      internal enum VpnItem {
        /// PIA VPN
        internal static let title = L10n.tr("Localizable", "top_navigation_bar.vpn_item.title", fallback: "PIA VPN")
      }
    }
    internal enum Tvos {
      internal enum Login {
        /// Enter your PIA VPN account details
        internal static let title = L10n.tr("Localizable", "tvos.login.title", fallback: "Enter your PIA VPN account details")
        internal enum Placeholder {
          /// Enter Password
          internal static let password = L10n.tr("Localizable", "tvos.login.placeholder.password", fallback: "Enter Password")
          /// Enter Username
          internal static let username = L10n.tr("Localizable", "tvos.login.placeholder.username", fallback: "Enter Username")
        }
      }
      internal enum Welcome {
        /// Fast & Secure VPN for Streaming
        internal static let title = L10n.tr("Localizable", "tvos.welcome.title", fallback: "Fast & Secure VPN for Streaming")
        internal enum Button {
          /// Log In
          internal static let login = L10n.tr("Localizable", "tvos.welcome.button.login", fallback: "Log In")
          /// Sign Up
          internal static let signup = L10n.tr("Localizable", "tvos.welcome.button.signup", fallback: "Sign Up")
        }
      }
    }
    internal enum VpnPermission {
      /// PIA
      internal static let title = L10n.tr("Localizable", "vpn_permission.title", fallback: "PIA")
      internal enum Body {
        /// We don’t monitor, filter or log any network activity.
        internal static let footer = L10n.tr("Localizable", "vpn_permission.body.footer", fallback: "We don’t monitor, filter or log any network activity.")
        /// You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.
        /// To proceed tap on “%@”.
        internal static func subtitle(_ p1: Any) -> String {
          return L10n.tr("Localizable", "vpn_permission.body.subtitle", String(describing: p1), fallback: "You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.\nTo proceed tap on “%@”.")
        }
        /// PIA needs access to your VPN profiles to secure your traffic
        internal static let title = L10n.tr("Localizable", "vpn_permission.body.title", fallback: "PIA needs access to your VPN profiles to secure your traffic")
      }
      internal enum Disallow {
        /// Contact
        internal static let contact = L10n.tr("Localizable", "vpn_permission.disallow.contact", fallback: "Contact")
        internal enum Message {
          /// We need this permission for the application to function.
          internal static let basic = L10n.tr("Localizable", "vpn_permission.disallow.message.basic", fallback: "We need this permission for the application to function.")
          /// You can also get in touch with customer support if you need assistance.
          internal static let support = L10n.tr("Localizable", "vpn_permission.disallow.message.support", fallback: "You can also get in touch with customer support if you need assistance.")
        }
      }
    }
    internal enum Widget {
      internal enum LiveActivity {
        internal enum Region {
          /// Region
          internal static let title = L10n.tr("Localizable", "widget.liveActivity.region.title", fallback: "Region")
        }
        internal enum SelectedProtocol {
          /// Protocol
          internal static let title = L10n.tr("Localizable", "widget.liveActivity.selected_protocol.title", fallback: "Protocol")
        }
      }
    }
  }
  internal enum Signup {
    internal enum Failure {
      /// We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.
      internal static let message = L10n.tr("Signup", "failure.message", fallback: "We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.")
      /// GO BACK
      internal static let submit = L10n.tr("Signup", "failure.submit", fallback: "GO BACK")
      /// Account creation failed
      internal static let title = L10n.tr("Signup", "failure.title", fallback: "Account creation failed")
      /// Sign-up failed
      internal static let vcTitle = L10n.tr("Signup", "failure.vc_title", fallback: "Sign-up failed")
      internal enum Purchase {
        internal enum Sandbox {
          /// The selected sandbox subscription is not available in production.
          internal static let message = L10n.tr("Signup", "failure.purchase.sandbox.message", fallback: "The selected sandbox subscription is not available in production.")
        }
      }
      internal enum Redeem {
        internal enum Claimed {
          /// Looks like this card has already been claimed by another account. You can try entering a different PIN.
          internal static let message = L10n.tr("Signup", "failure.redeem.claimed.message", fallback: "Looks like this card has already been claimed by another account. You can try entering a different PIN.")
          /// Card claimed already
          internal static let title = L10n.tr("Signup", "failure.redeem.claimed.title", fallback: "Card claimed already")
        }
        internal enum Invalid {
          /// Looks like you entered an invalid card PIN. Please try again.
          internal static let message = L10n.tr("Signup", "failure.redeem.invalid.message", fallback: "Looks like you entered an invalid card PIN. Please try again.")
          /// Invalid card PIN
          internal static let title = L10n.tr("Signup", "failure.redeem.invalid.title", fallback: "Invalid card PIN")
        }
      }
    }
    internal enum InProgress {
      /// We're confirming your purchase with our system. It could take a moment so hang in there.
      internal static let message = L10n.tr("Signup", "in_progress.message", fallback: "We're confirming your purchase with our system. It could take a moment so hang in there.")
      /// Signup.strings
      ///   PIALibrary
      /// 
      ///   Created by Davide De Rosa on 12/7/17.
      ///   Copyright © 2017 London Trust Media. All rights reserved.
      internal static let title = L10n.tr("Signup", "in_progress.title", fallback: "Confirm sign-up")
      internal enum Redeem {
        /// We're confirming your card PIN with our system. It could take a moment so hang in there.
        internal static let message = L10n.tr("Signup", "in_progress.redeem.message", fallback: "We're confirming your card PIN with our system. It could take a moment so hang in there.")
      }
    }
    internal enum Purchase {
      internal enum Subscribe {
        /// Subscribe now
        internal static let now = L10n.tr("Signup", "purchase.subscribe.now", fallback: "Subscribe now")
      }
      internal enum Trials {
        /// Browse anonymously and hide your ip.
        internal static let anonymous = L10n.tr("Signup", "purchase.trials.anonymous", fallback: "Browse anonymously and hide your ip.")
        /// Support 10 devices at once
        internal static let devices = L10n.tr("Signup", "purchase.trials.devices", fallback: "Support 10 devices at once")
        /// Start your 7-day free trial
        internal static let intro = L10n.tr("Signup", "purchase.trials.intro", fallback: "Start your 7-day free trial")
        /// Connect to any region easily
        internal static let region = L10n.tr("Signup", "purchase.trials.region", fallback: "Connect to any region easily")
        /// More than 3300 servers in 32 countries
        internal static let servers = L10n.tr("Signup", "purchase.trials.servers", fallback: "More than 3300 servers in 32 countries")
        /// Start subscription
        internal static let start = L10n.tr("Signup", "purchase.trials.start", fallback: "Start subscription")
        internal enum _1year {
          /// 1 year of privacy and identity protection
          internal static let protection = L10n.tr("Signup", "purchase.trials.1year.protection", fallback: "1 year of privacy and identity protection")
        }
        internal enum All {
          /// See all available plans
          internal static let plans = L10n.tr("Signup", "purchase.trials.all.plans", fallback: "See all available plans")
        }
        internal enum Devices {
          /// Protect yourself on up to 10 devices at a time.
          internal static let description = L10n.tr("Signup", "purchase.trials.devices.description", fallback: "Protect yourself on up to 10 devices at a time.")
        }
        internal enum Money {
          /// 30 day money back guarantee
          internal static let back = L10n.tr("Signup", "purchase.trials.money.back", fallback: "30 day money back guarantee")
        }
        internal enum Price {
          /// Then %@
          internal static func after(_ p1: Any) -> String {
            return L10n.tr("Signup", "purchase.trials.price.after", String(describing: p1), fallback: "Then %@")
          }
        }
      }
      internal enum Uncredited {
        internal enum Alert {
          /// You have uncredited transactions. Do you want to recover your account details?
          internal static let message = L10n.tr("Signup", "purchase.uncredited.alert.message", fallback: "You have uncredited transactions. Do you want to recover your account details?")
          internal enum Button {
            /// Cancel
            internal static let cancel = L10n.tr("Signup", "purchase.uncredited.alert.button.cancel", fallback: "Cancel")
            /// Recover account
            internal static let recover = L10n.tr("Signup", "purchase.uncredited.alert.button.recover", fallback: "Recover account")
          }
        }
      }
    }
    internal enum Share {
      internal enum Data {
        internal enum Buttons {
          /// Accept
          internal static let accept = L10n.tr("Signup", "share.data.buttons.accept", fallback: "Accept")
          /// No, thanks
          internal static let noThanks = L10n.tr("Signup", "share.data.buttons.noThanks", fallback: "No, thanks")
          /// Read more
          internal static let readMore = L10n.tr("Signup", "share.data.buttons.readMore", fallback: "Read more")
        }
        internal enum ReadMore {
          internal enum Text {
            /// This minimal information assists us in identifying and fixing potential connection issues. Note that sharing this information requires consent and manual activation as it is turned off by default.
            /// 
            /// We will collect information about the following events:
            /// 
            ///     - Connection Attempt
            ///     - Connection Canceled
            ///     - Connection Established
            /// 
            /// For all of these events, we will collect the following information:
            ///     - Platform
            ///     - App version
            ///     - App type (pre-release or not)
            ///     - Protocol used
            ///     - Connection source (manual or using automation)
            ///     - Time To Connect (time between connecting and connected state)
            /// 
            /// All events will contain a unique ID, which is randomly generated. This ID is not associated with your user account. This unique ID is re-generated daily for privacy purposes.
            /// 
            /// You will always be in control. You can see what data we’ve collected from Settings, and you can turn it off at any time.
            internal static let description = L10n.tr("Signup", "share.data.readMore.text.description", fallback: "This minimal information assists us in identifying and fixing potential connection issues. Note that sharing this information requires consent and manual activation as it is turned off by default.\n\nWe will collect information about the following events:\n\n    - Connection Attempt\n    - Connection Canceled\n    - Connection Established\n\nFor all of these events, we will collect the following information:\n    - Platform\n    - App version\n    - App type (pre-release or not)\n    - Protocol used\n    - Connection source (manual or using automation)\n    - Time To Connect (time between connecting and connected state)\n\nAll events will contain a unique ID, which is randomly generated. This ID is not associated with your user account. This unique ID is re-generated daily for privacy purposes.\n\nYou will always be in control. You can see what data we’ve collected from Settings, and you can turn it off at any time.")
          }
        }
        internal enum Text {
          /// To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information.
          internal static let description = L10n.tr("Signup", "share.data.text.description", fallback: "To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information.")
          /// You can always control this from your settings
          internal static let footer = L10n.tr("Signup", "share.data.text.footer", fallback: "You can always control this from your settings")
          /// Please help us improve our service
          internal static let title = L10n.tr("Signup", "share.data.text.title", fallback: "Please help us improve our service")
        }
      }
    }
    internal enum Success {
      /// Thank you for signing up with us. We have sent your account username and password at your email address at %@
      internal static func messageFormat(_ p1: Any) -> String {
        return L10n.tr("Signup", "success.message_format", String(describing: p1), fallback: "Thank you for signing up with us. We have sent your account username and password at your email address at %@")
      }
      /// GET STARTED
      internal static let submit = L10n.tr("Signup", "success.submit", fallback: "GET STARTED")
      /// Purchase complete
      internal static let title = L10n.tr("Signup", "success.title", fallback: "Purchase complete")
      internal enum Password {
        /// Password
        internal static let caption = L10n.tr("Signup", "success.password.caption", fallback: "Password")
      }
      internal enum Redeem {
        /// You will receive an email shortly with your username and password.
        /// 
        /// Your login details
        internal static let message = L10n.tr("Signup", "success.redeem.message", fallback: "You will receive an email shortly with your username and password.\n\nYour login details")
        /// Card redeemed successfully
        internal static let title = L10n.tr("Signup", "success.redeem.title", fallback: "Card redeemed successfully")
      }
      internal enum Username {
        /// Username
        internal static let caption = L10n.tr("Signup", "success.username.caption", fallback: "Username")
      }
    }
    internal enum Unreachable {
      /// No internet connection found. Please confirm that you have an internet connection and hit retry below.
      /// 
      /// You can come back to the app later to finish the process.
      internal static let message = L10n.tr("Signup", "unreachable.message", fallback: "No internet connection found. Please confirm that you have an internet connection and hit retry below.\n\nYou can come back to the app later to finish the process.")
      /// TRY AGAIN
      internal static let submit = L10n.tr("Signup", "unreachable.submit", fallback: "TRY AGAIN")
      /// Whoops!
      internal static let title = L10n.tr("Signup", "unreachable.title", fallback: "Whoops!")
      /// Error
      internal static let vcTitle = L10n.tr("Signup", "unreachable.vc_title", fallback: "Error")
    }
    internal enum Walkthrough {
      internal enum Action {
        /// DONE
        internal static let done = L10n.tr("Signup", "walkthrough.action.done", fallback: "DONE")
        /// NEXT
        internal static let next = L10n.tr("Signup", "walkthrough.action.next", fallback: "NEXT")
        /// SKIP
        internal static let skip = L10n.tr("Signup", "walkthrough.action.skip", fallback: "SKIP")
      }
      internal enum Page {
        internal enum _1 {
          /// Protect yourself on up to 10 devices at a time.
          internal static let description = L10n.tr("Signup", "walkthrough.page.1.description", fallback: "Protect yourself on up to 10 devices at a time.")
          /// Support 10 devices at once
          internal static let title = L10n.tr("Signup", "walkthrough.page.1.title", fallback: "Support 10 devices at once")
        }
        internal enum _2 {
          /// With servers around the globe, you are always under protection.
          internal static let description = L10n.tr("Signup", "walkthrough.page.2.description", fallback: "With servers around the globe, you are always under protection.")
          /// Connect to any region easily
          internal static let title = L10n.tr("Signup", "walkthrough.page.2.title", fallback: "Connect to any region easily")
        }
        internal enum _3 {
          /// Enabling our Content Blocker prevents ads from showing in Safari.
          internal static let description = L10n.tr("Signup", "walkthrough.page.3.description", fallback: "Enabling our Content Blocker prevents ads from showing in Safari.")
          /// Protect yourself from ads
          internal static let title = L10n.tr("Signup", "walkthrough.page.3.title", fallback: "Protect yourself from ads")
        }
      }
    }
  }
  internal enum Ui {
    internal enum Global {
      /// Cancel
      internal static let cancel = L10n.tr("UI", "global.cancel", fallback: "Cancel")
      /// Close
      internal static let close = L10n.tr("UI", "global.close", fallback: "Close")
      /// OK
      internal static let ok = L10n.tr("UI", "global.ok", fallback: "OK")
      internal enum Version {
        /// Version %@ (%@)
        internal static func format(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("UI", "global.version.format", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
        }
      }
    }
  }
  internal enum Welcome {
    internal enum Agreement {
      /// After the 7 days free trial this subscription automatically renews for %@ unless it is canceled at least 24 hours before the end of the trial period. Your Apple ID account will be charged for renewal within 24 hours before the end of the trial period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. 7-days trial offer is limited to one 7-days trial offer per user. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription. All prices include applicable local sales taxes.
      /// 
      /// Signing up constitutes acceptance of the $1 and the $2.
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Welcome", "agreement.message", String(describing: p1), fallback: "After the 7 days free trial this subscription automatically renews for %@ unless it is canceled at least 24 hours before the end of the trial period. Your Apple ID account will be charged for renewal within 24 hours before the end of the trial period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. 7-days trial offer is limited to one 7-days trial offer per user. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription. All prices include applicable local sales taxes.\n\nSigning up constitutes acceptance of the $1 and the $2.")
      }
      internal enum Message {
        /// Privacy Policy
        internal static let privacy = L10n.tr("Welcome", "agreement.message.privacy", fallback: "Privacy Policy")
        /// Terms of Service
        internal static let tos = L10n.tr("Welcome", "agreement.message.tos", fallback: "Terms of Service")
      }
      internal enum Trials {
        /// Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.
        /// 
        /// Certain Paid Subscriptions may offer a free trial prior to charging your payment method. If you decide to unsubscribe from a Paid Subscription before we start charging your payment method, cancel the subscription at least 24 hours before the free trial ends.
        /// 
        /// Free trials are only available to new users, and are at our sole discretion, and if you attempt to sign up for an additional free trial, you will be immediately charged with the standard Subscription Fee.
        /// 
        /// We reserve the right to revoke your free trial at any time.
        /// 
        /// Any unused portion of your free trial period will be forfeited upon purchase of a subscription.
        /// 
        /// Signing up constitutes acceptance of this terms and conditions.
        internal static let message = L10n.tr("Welcome", "agreement.trials.message", fallback: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.\n\nCertain Paid Subscriptions may offer a free trial prior to charging your payment method. If you decide to unsubscribe from a Paid Subscription before we start charging your payment method, cancel the subscription at least 24 hours before the free trial ends.\n\nFree trials are only available to new users, and are at our sole discretion, and if you attempt to sign up for an additional free trial, you will be immediately charged with the standard Subscription Fee.\n\nWe reserve the right to revoke your free trial at any time.\n\nAny unused portion of your free trial period will be forfeited upon purchase of a subscription.\n\nSigning up constitutes acceptance of this terms and conditions.")
        /// Free trials terms and conditions
        internal static let title = L10n.tr("Welcome", "agreement.trials.title", fallback: "Free trials terms and conditions")
        internal enum Monthly {
          /// month
          internal static let plan = L10n.tr("Welcome", "agreement.trials.monthly.plan", fallback: "month")
        }
        internal enum Yearly {
          /// year
          internal static let plan = L10n.tr("Welcome", "agreement.trials.yearly.plan", fallback: "year")
        }
      }
    }
    internal enum Gdpr {
      internal enum Accept {
        internal enum Button {
          /// Agree and continue
          internal static let title = L10n.tr("Welcome", "gdpr.accept.button.title", fallback: "Agree and continue")
        }
      }
      internal enum Collect {
        internal enum Data {
          /// E-mail Address for the purposes of account management and protection from abuse.
          internal static let description = L10n.tr("Welcome", "gdpr.collect.data.description", fallback: "E-mail Address for the purposes of account management and protection from abuse.")
          /// Personal information we collect
          internal static let title = L10n.tr("Welcome", "gdpr.collect.data.title", fallback: "Personal information we collect")
        }
      }
      internal enum Usage {
        internal enum Data {
          /// E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.
          internal static let description = L10n.tr("Welcome", "gdpr.usage.data.description", fallback: "E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.")
          /// Uses of personal information collected by us
          internal static let title = L10n.tr("Welcome", "gdpr.usage.data.title", fallback: "Uses of personal information collected by us")
        }
      }
    }
    internal enum Getstarted {
      internal enum Buttons {
        /// Buy account
        internal static let buyaccount = L10n.tr("Welcome", "getstarted.buttons.buyaccount", fallback: "Buy account")
      }
    }
    internal enum Iap {
      internal enum Error {
        /// Error
        internal static let title = L10n.tr("Welcome", "iap.error.title", fallback: "Error")
        internal enum Message {
          /// Apple servers currently unavailable. Please try again later.
          internal static let unavailable = L10n.tr("Welcome", "iap.error.message.unavailable", fallback: "Apple servers currently unavailable. Please try again later.")
        }
      }
    }
    internal enum Login {
      /// LOGIN
      internal static let submit = L10n.tr("Welcome", "login.submit", fallback: "LOGIN")
      /// Welcome.strings
      ///   PIALibrary
      /// 
      ///   Created by Davide De Rosa on 12/7/17.
      ///   Copyright © 2017 London Trust Media. All rights reserved.
      internal static let title = L10n.tr("Welcome", "login.title", fallback: "Sign in to your account")
      internal enum Error {
        /// Too many failed login attempts with this username. Please try again after %@ second(s).
        internal static func throttled(_ p1: Any) -> String {
          return L10n.tr("Welcome", "login.error.throttled", String(describing: p1), fallback: "Too many failed login attempts with this username. Please try again after %@ second(s).")
        }
        /// Log in
        internal static let title = L10n.tr("Welcome", "login.error.title", fallback: "Log in")
        /// Your username or password is incorrect.
        internal static let unauthorized = L10n.tr("Welcome", "login.error.unauthorized", fallback: "Your username or password is incorrect.")
        /// You must enter a username and password.
        internal static let validation = L10n.tr("Welcome", "login.error.validation", fallback: "You must enter a username and password.")
      }
      internal enum Magic {
        internal enum Link {
          /// Please check your e-mail for a login link.
          internal static let response = L10n.tr("Welcome", "login.magic.link.response", fallback: "Please check your e-mail for a login link.")
          /// Send Link
          internal static let send = L10n.tr("Welcome", "login.magic.link.send", fallback: "Send Link")
          /// Login using magic email link
          internal static let title = L10n.tr("Welcome", "login.magic.link.title", fallback: "Login using magic email link")
          internal enum Invalid {
            /// Invalid email. Please try again.
            internal static let email = L10n.tr("Welcome", "login.magic.link.invalid.email", fallback: "Invalid email. Please try again.")
          }
        }
      }
      internal enum Password {
        /// Password
        internal static let placeholder = L10n.tr("Welcome", "login.password.placeholder", fallback: "Password")
      }
      internal enum Receipt {
        /// Login using purchase receipt
        internal static let button = L10n.tr("Welcome", "login.receipt.button", fallback: "Login using purchase receipt")
      }
      internal enum Restore {
        /// Didn't receive account details?
        internal static let button = L10n.tr("Welcome", "login.restore.button", fallback: "Didn't receive account details?")
      }
      internal enum Username {
        /// Username (p1234567)
        internal static let placeholder = L10n.tr("Welcome", "login.username.placeholder", fallback: "Username (p1234567)")
      }
    }
    internal enum Plan {
      /// Best value
      internal static let bestValue = L10n.tr("Welcome", "plan.best_value", fallback: "Best value")
      /// %@/mo
      internal static func priceFormat(_ p1: Any) -> String {
        return L10n.tr("Welcome", "plan.price_format", String(describing: p1), fallback: "%@/mo")
      }
      internal enum Accessibility {
        /// per month
        internal static let perMonth = L10n.tr("Welcome", "plan.accessibility.per_month", fallback: "per month")
      }
      internal enum Monthly {
        /// Monthly
        internal static let title = L10n.tr("Welcome", "plan.monthly.title", fallback: "Monthly")
      }
      internal enum Yearly {
        /// %@%@ per year
        internal static func detailFormat(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Welcome", "plan.yearly.detail_format", String(describing: p1), String(describing: p2), fallback: "%@%@ per year")
        }
        /// Yearly
        internal static let title = L10n.tr("Welcome", "plan.yearly.title", fallback: "Yearly")
      }
    }
    internal enum Purchase {
      /// Continue
      internal static let `continue` = L10n.tr("Welcome", "purchase.continue", fallback: "Continue")
      /// or
      internal static let or = L10n.tr("Welcome", "purchase.or", fallback: "or")
      /// Submit
      internal static let submit = L10n.tr("Welcome", "purchase.submit", fallback: "Submit")
      /// 30-day money back guarantee
      internal static let subtitle = L10n.tr("Welcome", "purchase.subtitle", fallback: "30-day money back guarantee")
      /// Select a VPN plan
      internal static let title = L10n.tr("Welcome", "purchase.title", fallback: "Select a VPN plan")
      internal enum Confirm {
        /// You are purchasing the %@ plan
        internal static func plan(_ p1: Any) -> String {
          return L10n.tr("Welcome", "purchase.confirm.plan", String(describing: p1), fallback: "You are purchasing the %@ plan")
        }
        internal enum Form {
          /// Enter your email address
          internal static let email = L10n.tr("Welcome", "purchase.confirm.form.email", fallback: "Enter your email address")
        }
      }
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "purchase.email.placeholder", fallback: "Email address")
        /// We need your email to send your username and password.
        internal static let why = L10n.tr("Welcome", "purchase.email.why", fallback: "We need your email to send your username and password.")
      }
      internal enum Error {
        /// Purchase
        internal static let title = L10n.tr("Welcome", "purchase.error.title", fallback: "Purchase")
        /// You must enter an email address.
        internal static let validation = L10n.tr("Welcome", "purchase.error.validation", fallback: "You must enter an email address.")
        internal enum Connectivity {
          /// We are unable to reach Private Internet Access. This may due to poor internet or our service is blocked in your country.
          internal static let description = L10n.tr("Welcome", "purchase.error.connectivity.description", fallback: "We are unable to reach Private Internet Access. This may due to poor internet or our service is blocked in your country.")
          /// Connection Failure
          internal static let title = L10n.tr("Welcome", "purchase.error.connectivity.title", fallback: "Connection Failure")
        }
      }
      internal enum Login {
        /// Sign in
        internal static let button = L10n.tr("Welcome", "purchase.login.button", fallback: "Sign in")
        /// Already have an account?
        internal static let footer = L10n.tr("Welcome", "purchase.login.footer", fallback: "Already have an account?")
      }
    }
    internal enum Redeem {
      /// SUBMIT
      internal static let submit = L10n.tr("Welcome", "redeem.submit", fallback: "SUBMIT")
      /// Type in your email address and the %lu digit PIN from your gift card or trial card below.
      internal static func subtitle(_ p1: Int) -> String {
        return L10n.tr("Welcome", "redeem.subtitle", p1, fallback: "Type in your email address and the %lu digit PIN from your gift card or trial card below.")
      }
      /// Redeem gift card
      internal static let title = L10n.tr("Welcome", "redeem.title", fallback: "Redeem gift card")
      internal enum Accessibility {
        /// Back
        internal static let back = L10n.tr("Welcome", "redeem.accessibility.back", fallback: "Back")
      }
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "redeem.email.placeholder", fallback: "Email address")
      }
      internal enum Error {
        /// Please type in your email and card PIN.
        internal static let allfields = L10n.tr("Welcome", "redeem.error.allfields", fallback: "Please type in your email and card PIN.")
        /// Code must be %lu numeric digits.
        internal static func code(_ p1: Int) -> String {
          return L10n.tr("Welcome", "redeem.error.code", p1, fallback: "Code must be %lu numeric digits.")
        }
        /// Redeem
        internal static let title = L10n.tr("Welcome", "redeem.error.title", fallback: "Redeem")
      }
      internal enum Giftcard {
        /// Gift card PIN
        internal static let placeholder = L10n.tr("Welcome", "redeem.giftcard.placeholder", fallback: "Gift card PIN")
      }
    }
    internal enum Restore {
      /// CONFIRM
      internal static let submit = L10n.tr("Welcome", "restore.submit", fallback: "CONFIRM")
      /// If you purchased a plan through this app and didn't receive your credentials, you can send them again from here. You will not be charged during this process.
      internal static let subtitle = L10n.tr("Welcome", "restore.subtitle", fallback: "If you purchased a plan through this app and didn't receive your credentials, you can send them again from here. You will not be charged during this process.")
      /// Restore uncredited purchase
      internal static let title = L10n.tr("Welcome", "restore.title", fallback: "Restore uncredited purchase")
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "restore.email.placeholder", fallback: "Email address")
      }
    }
    internal enum Update {
      internal enum Account {
        internal enum Email {
          /// Failed to modify account email
          internal static let error = L10n.tr("Welcome", "update.account.email.error", fallback: "Failed to modify account email")
        }
      }
    }
    internal enum Upgrade {
      /// Welcome Back!
      internal static let header = L10n.tr("Welcome", "upgrade.header", fallback: "Welcome Back!")
      /// In order to use Private Internet Access, you’ll need to renew your subscription.
      internal static let title = L10n.tr("Welcome", "upgrade.title", fallback: "In order to use Private Internet Access, you’ll need to renew your subscription.")
      internal enum Renew {
        /// Renew now
        internal static let now = L10n.tr("Welcome", "upgrade.renew.now", fallback: "Renew now")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
