// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum About {
    /// VPN by Private Internet Access
    public static let app = L10n.tr("Localizable", "about.app", fallback: "VPN by Private Internet Access")
    /// This program uses the following components:
    public static let intro = L10n.tr("Localizable", "about.intro", fallback: "This program uses the following components:")
    public enum Accessibility {
      public enum Component {
        /// Tap to read full license
        public static let expand = L10n.tr("Localizable", "about.accessibility.component.expand", fallback: "Tap to read full license")
      }
    }
  }
  public enum Account {
    /// Delete Account
    public static let delete = L10n.tr("Localizable", "account.delete", fallback: "Delete Account")
    /// Something went wrong. Please try logging in again
    public static let unauthorized = L10n.tr("Localizable", "account.unauthorized", fallback: "Something went wrong. Please try logging in again")
    public enum Delete {
      public enum Alert {
        /// Something went wrong while deleting your account, please try again later.
        public static let failureMessage = L10n.tr("Localizable", "account.delete.alert.failureMessage", fallback: "Something went wrong while deleting your account, please try again later.")
        /// Deleting your PIA account is permanent and irreversible. You will not be able to retrieve your PIA credentials after performing this action. Please note that this action only deletes your PIA account from our database, but it does NOT delete your subscription. You will need to go to your Apple account and cancel the Private Internet Access subscription from there. Otherwise, you will still be charged, even though your PIA account will no longer be active.
        public static let message = L10n.tr("Localizable", "account.delete.alert.message", fallback: "Deleting your PIA account is permanent and irreversible. You will not be able to retrieve your PIA credentials after performing this action. Please note that this action only deletes your PIA account from our database, but it does NOT delete your subscription. You will need to go to your Apple account and cancel the Private Internet Access subscription from there. Otherwise, you will still be charged, even though your PIA account will no longer be active.")
        /// Are you sure?
        public static let title = L10n.tr("Localizable", "account.delete.alert.title", fallback: "Are you sure?")
      }
    }
    public enum Email {
      /// Email
      public static let caption = L10n.tr("Localizable", "account.email.caption", fallback: "Email")
      /// Email address
      public static let placeholder = L10n.tr("Localizable", "account.email.placeholder", fallback: "Email address")
    }
    public enum Error {
      /// Your username or password is incorrect.
      public static let unauthorized = L10n.tr("Localizable", "account.error.unauthorized", fallback: "Your username or password is incorrect.")
    }
    public enum ExpiryDate {
      /// Your plan has expired.
      public static let expired = L10n.tr("Localizable", "account.expiry_date.expired", fallback: "Your plan has expired.")
      /// Your plan will expire on %@.
      public static func information(_ p1: Any) -> String {
        return L10n.tr("Localizable", "account.expiry_date.information", String(describing: p1), fallback: "Your plan will expire on %@.")
      }
    }
    public enum Other {
      /// Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.
      public static let footer = L10n.tr("Localizable", "account.other.footer", fallback: "Get the Private Internet Access app for your other devices and use the above username and password to login and secure your connection.")
    }
    public enum Restore {
      /// RESTORE PURCHASE
      public static let button = L10n.tr("Localizable", "account.restore.button", fallback: "RESTORE PURCHASE")
      /// If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.
      public static let description = L10n.tr("Localizable", "account.restore.description", fallback: "If you renewed your plan but your account still says it's about to expire, you can restart the renewal from here. You will not be charged during this process.")
      /// Restore uncredited purchase
      public static let title = L10n.tr("Localizable", "account.restore.title", fallback: "Restore uncredited purchase")
      public enum Failure {
        /// No redeemable purchase was found for renewal.
        public static let message = L10n.tr("Localizable", "account.restore.failure.message", fallback: "No redeemable purchase was found for renewal.")
        /// Restore purchase
        public static let title = L10n.tr("Localizable", "account.restore.failure.title", fallback: "Restore purchase")
      }
    }
    public enum Reveal {
      /// Authenticate to reveal
      public static let prompt = L10n.tr("Localizable", "account.reveal.prompt", fallback: "Authenticate to reveal")
    }
    public enum Save {
      /// Update email
      public static let item = L10n.tr("Localizable", "account.save.item", fallback: "Update email")
      /// Authenticate to save changes
      public static let prompt = L10n.tr("Localizable", "account.save.prompt", fallback: "Authenticate to save changes")
      /// Your email address has been saved.
      public static let success = L10n.tr("Localizable", "account.save.success", fallback: "Your email address has been saved.")
    }
    public enum Set {
      public enum Email {
        /// There was an error adding email. Please try again later.
        public static let error = L10n.tr("Localizable", "account.set.email.error", fallback: "There was an error adding email. Please try again later.")
      }
    }
    public enum Subscriptions {
      /// here.
      public static let linkMessage = L10n.tr("Localizable", "account.subscriptions.linkMessage", fallback: "here.")
      /// You can manage your subscription from here.
      public static let message = L10n.tr("Localizable", "account.subscriptions.message", fallback: "You can manage your subscription from here.")
      /// Monthly plan
      public static let monthly = L10n.tr("Localizable", "account.subscriptions.monthly", fallback: "Monthly plan")
      /// Trial plan
      public static let trial = L10n.tr("Localizable", "account.subscriptions.trial", fallback: "Trial plan")
      /// Yearly plan
      public static let yearly = L10n.tr("Localizable", "account.subscriptions.yearly", fallback: "Yearly plan")
      public enum Short {
        /// Manage subscription
        public static let linkMessage = L10n.tr("Localizable", "account.subscriptions.short.linkMessage", fallback: "Manage subscription")
        /// Manage subscription
        public static let message = L10n.tr("Localizable", "account.subscriptions.short.message", fallback: "Manage subscription")
      }
    }
    public enum Survey {
      /// Want to help make PIA better? Let us know how we can improve!
      /// Take The Survey
      public static let message = L10n.tr("Localizable", "account.survey.message", fallback: "Want to help make PIA better? Let us know how we can improve!\nTake The Survey")
      /// Take The Survey
      public static let messageLink = L10n.tr("Localizable", "account.survey.messageLink", fallback: "Take The Survey")
    }
    public enum Update {
      public enum Email {
        public enum Require {
          public enum Password {
            /// Submit
            public static let button = L10n.tr("Localizable", "account.update.email.require.password.button", fallback: "Submit")
            /// For security reasons we require your PIA password to perform a change in your account. Please input your PIA password to proceed.
            public static let message = L10n.tr("Localizable", "account.update.email.require.password.message", fallback: "For security reasons we require your PIA password to perform a change in your account. Please input your PIA password to proceed.")
            /// PIA Password Required
            public static let title = L10n.tr("Localizable", "account.update.email.require.password.title", fallback: "PIA Password Required")
          }
        }
      }
    }
    public enum Username {
      /// Username
      public static let caption = L10n.tr("Localizable", "account.username.caption", fallback: "Username")
    }
  }
  public enum Card {
    public enum Wireguard {
      /// It's a new, more efficient VPN protocol that offers better performance, lower CPU usage and longer battery life.
      public static let description = L10n.tr("Localizable", "card.wireguard.description", fallback: "It's a new, more efficient VPN protocol that offers better performance, lower CPU usage and longer battery life.")
      /// Try WireGuard® today!
      public static let title = L10n.tr("Localizable", "card.wireguard.title", fallback: "Try WireGuard® today!")
      public enum Cta {
        /// Try WireGuard® now
        public static let activate = L10n.tr("Localizable", "card.wireguard.cta.activate", fallback: "Try WireGuard® now")
        /// Learn more
        public static let learn = L10n.tr("Localizable", "card.wireguard.cta.learn", fallback: "Learn more")
        /// Open Settings
        public static let settings = L10n.tr("Localizable", "card.wireguard.cta.settings", fallback: "Open Settings")
      }
    }
  }
  public enum ContentBlocker {
    /// Safari Content Blocker
    public static let title = L10n.tr("Localizable", "content_blocker.title", fallback: "Safari Content Blocker")
    public enum Body {
      /// Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.
      public static let footer = L10n.tr("Localizable", "content_blocker.body.footer", fallback: "Please note: You do not need to be connected to the VPN for this Content Blocker to work, but it will only work while browsing with Safari.")
      /// To enable our Content Blocker for use with Safari please go to Settings > Apps > Safari > Extensions and toggle on PIA VPN.
      public static let subtitle = L10n.tr("Localizable", "content_blocker.body.subtitle", fallback: "To enable our Content Blocker for use with Safari please go to Settings > Apps > Safari > Extensions and toggle on PIA VPN.")
    }
  }
  public enum Dashboard {
    public enum Accessibility {
      public enum Vpn {
        /// VPN Connection button
        public static let button = L10n.tr("Localizable", "dashboard.accessibility.vpn.button", fallback: "VPN Connection button")
        public enum Button {
          /// VPN Connection button. The VPN is currently disconnected
          public static let isOff = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOff", fallback: "VPN Connection button. The VPN is currently disconnected")
          /// VPN Connection button. The VPN is currently connected
          public static let isOn = L10n.tr("Localizable", "dashboard.accessibility.vpn.button.isOn", fallback: "VPN Connection button. The VPN is currently connected")
        }
      }
    }
    public enum Connection {
      public enum Ip {
        /// Internet unreachable
        public static let unreachable = L10n.tr("Localizable", "dashboard.connection.ip.unreachable", fallback: "Internet unreachable")
      }
    }
    public enum ConnectionState {
      public enum Connected {
        /// Connected
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.connected.title", fallback: "Connected")
      }
      public enum Connecting {
        /// Connecting...
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.connecting.title", fallback: "Connecting...")
      }
      public enum Disconnected {
        /// Not Connected
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.disconnected.title", fallback: "Not Connected")
      }
      public enum Disconnecting {
        /// Disconnecting...
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.disconnecting.title", fallback: "Disconnecting...")
      }
      public enum Error {
        /// Connection Error
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.error.title", fallback: "Connection Error")
      }
      public enum NetworkErrorAlert {
        /// Please check your internet connection and try again
        public static let message = L10n.tr("Localizable", "dashboard.connection_state.network_error_alert.message", fallback: "Please check your internet connection and try again")
        public enum PrimaryAction {
          /// Retry
          public static let title = L10n.tr("Localizable", "dashboard.connection_state.network_error_alert.primary_action.title", fallback: "Retry")
        }
      }
      public enum Reconnecting {
        /// Reconnecting...
        public static let title = L10n.tr("Localizable", "dashboard.connection_state.reconnecting.title", fallback: "Reconnecting...")
      }
    }
    public enum ContentBlocker {
      public enum Intro {
        /// This version replaces MACE with our Safari Content Blocker.
        /// 
        /// Check it out in the 'Settings' section.
        public static let message = L10n.tr("Localizable", "dashboard.content_blocker.intro.message", fallback: "This version replaces MACE with our Safari Content Blocker.\n\nCheck it out in the 'Settings' section.")
      }
    }
    public enum Vpn {
      /// Changing region...
      public static let changingRegion = L10n.tr("Localizable", "dashboard.vpn.changing_region", fallback: "Changing region...")
      /// Connected to VPN
      public static let connected = L10n.tr("Localizable", "dashboard.vpn.connected", fallback: "Connected to VPN")
      /// Connecting...
      public static let connecting = L10n.tr("Localizable", "dashboard.vpn.connecting", fallback: "Connecting...")
      /// Disconnected
      public static let disconnected = L10n.tr("Localizable", "dashboard.vpn.disconnected", fallback: "Disconnected")
      /// Disconnecting...
      public static let disconnecting = L10n.tr("Localizable", "dashboard.vpn.disconnecting", fallback: "Disconnecting...")
      /// Not Protected
      public static let notProtected = L10n.tr("Localizable", "dashboard.vpn.not_protected", fallback: "Not Protected")
      /// VPN: ON
      public static let on = L10n.tr("Localizable", "dashboard.vpn.on", fallback: "VPN: ON")
      /// Protected
      public static let protected = L10n.tr("Localizable", "dashboard.vpn.protected", fallback: "Protected")
      public enum ChangeLocation {
        public enum Alert {
          /// Your VPN will briefly disconnect while connecting to the new location.
          public static let message = L10n.tr("Localizable", "dashboard.vpn.change_location.alert.message", fallback: "Your VPN will briefly disconnect while connecting to the new location.")
          /// Changing Location?
          public static let title = L10n.tr("Localizable", "dashboard.vpn.change_location.alert.title", fallback: "Changing Location?")
          public enum Button {
            /// Connect
            public static let connect = L10n.tr("Localizable", "dashboard.vpn.change_location.alert.button.connect", fallback: "Connect")
          }
        }
      }
      public enum Disconnect {
        /// This network is untrusted. Do you really want to disconnect the VPN?
        public static let untrusted = L10n.tr("Localizable", "dashboard.vpn.disconnect.untrusted", fallback: "This network is untrusted. Do you really want to disconnect the VPN?")
      }
      public enum Leakprotection {
        public enum Alert {
          /// Disable Now
          public static let cta1 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta1", fallback: "Disable Now")
          /// Learn more
          public static let cta2 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta2", fallback: "Learn more")
          /// Ignore
          public static let cta3 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.cta3", fallback: "Ignore")
          /// To prevent data leaks, tap Disable Now to turn off “Allow access to devices on local network" and automatically reconnect.
          public static let message = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.message", fallback: "To prevent data leaks, tap Disable Now to turn off “Allow access to devices on local network\" and automatically reconnect.")
          /// Unsecured Wi-Fi detected
          public static let title = L10n.tr("Localizable", "dashboard.vpn.leakprotection.alert.title", fallback: "Unsecured Wi-Fi detected")
        }
        public enum Ikev2 {
          public enum Alert {
            /// Switch Now
            public static let cta1 = L10n.tr("Localizable", "dashboard.vpn.leakprotection.ikev2.alert.cta1", fallback: "Switch Now")
            /// To prevent data leaks, tap Switch Now to change to the IKEv2 VPN protocol and automatically reconnect.
            public static let message = L10n.tr("Localizable", "dashboard.vpn.leakprotection.ikev2.alert.message", fallback: "To prevent data leaks, tap Switch Now to change to the IKEv2 VPN protocol and automatically reconnect.")
          }
        }
      }
    }
  }
  public enum Dedicated {
    public enum Ip {
      /// Are you sure you want to remove the selected region?
      public static let remove = L10n.tr("Localizable", "dedicated.ip.remove", fallback: "Are you sure you want to remove the selected region?")
      /// Dedicated IP
      public static let title = L10n.tr("Localizable", "dedicated.ip.title", fallback: "Dedicated IP")
      public enum Activate {
        public enum Button {
          /// Activate
          public static let title = L10n.tr("Localizable", "dedicated.ip.activate.button.title", fallback: "Activate")
        }
      }
      public enum Activation {
        /// Activate your Dedicated IP by pasting your token in the form below. If you've recently purchased a dedicated IP, you can generate the token by going to the PIA website.
        public static let description = L10n.tr("Localizable", "dedicated.ip.activation.description", fallback: "Activate your Dedicated IP by pasting your token in the form below. If you've recently purchased a dedicated IP, you can generate the token by going to the PIA website.")
      }
      public enum Country {
        public enum Flag {
          /// Country flag for %@
          public static func accessibility(_ p1: Any) -> String {
            return L10n.tr("Localizable", "dedicated.ip.country.flag.accessibility", String(describing: p1), fallback: "Country flag for %@")
          }
        }
      }
      public enum Limit {
        /// Secure your remote connections to any asset with a dedicated IP from a country of your choice. During your subscription, this IP will be yours and yours alone, protecting your data transfers with the strongest encryption out there.
        public static let title = L10n.tr("Localizable", "dedicated.ip.limit.title", fallback: "Secure your remote connections to any asset with a dedicated IP from a country of your choice. During your subscription, this IP will be yours and yours alone, protecting your data transfers with the strongest encryption out there.")
      }
      public enum Message {
        public enum Error {
          /// Too many failed token activation requests. Please try again after %@ second(s).
          public static func retryafter(_ p1: Any) -> String {
            return L10n.tr("Localizable", "dedicated.ip.message.error.retryafter", String(describing: p1), fallback: "Too many failed token activation requests. Please try again after %@ second(s).")
          }
          /// Your token is expired. Please generate a new one from your Account page on the website.
          public static let token = L10n.tr("Localizable", "dedicated.ip.message.error.token", fallback: "Your token is expired. Please generate a new one from your Account page on the website.")
        }
        public enum Expired {
          /// Your token is expired. Please generate a new one from your Account page on the website.
          public static let token = L10n.tr("Localizable", "dedicated.ip.message.expired.token", fallback: "Your token is expired. Please generate a new one from your Account page on the website.")
        }
        public enum Incorrect {
          /// Please make sure you have entered the token correctly
          public static let token = L10n.tr("Localizable", "dedicated.ip.message.incorrect.token", fallback: "Please make sure you have entered the token correctly")
        }
        public enum Invalid {
          /// Your token is invalid. Please make sure you have entered the token correctly.
          public static let token = L10n.tr("Localizable", "dedicated.ip.message.invalid.token", fallback: "Your token is invalid. Please make sure you have entered the token correctly.")
        }
        public enum Ip {
          /// Your dedicated IP was updated
          public static let updated = L10n.tr("Localizable", "dedicated.ip.message.ip.updated", fallback: "Your dedicated IP was updated")
        }
        public enum Token {
          /// Your dedicated IP will expire soon. Get a new one
          public static let willexpire = L10n.tr("Localizable", "dedicated.ip.message.token.willexpire", fallback: "Your dedicated IP will expire soon. Get a new one")
          public enum Willexpire {
            /// Get a new one
            public static let link = L10n.tr("Localizable", "dedicated.ip.message.token.willexpire.link", fallback: "Get a new one")
          }
        }
        public enum Valid {
          /// Your Dedicated IP has been activated successfully. It will be available in your Region selection list.
          public static let token = L10n.tr("Localizable", "dedicated.ip.message.valid.token", fallback: "Your Dedicated IP has been activated successfully. It will be available in your Region selection list.")
        }
      }
      public enum Plural {
        /// Your Dedicated IPs
        public static let title = L10n.tr("Localizable", "dedicated.ip.plural.title", fallback: "Your Dedicated IPs")
      }
      public enum Token {
        public enum Textfield {
          /// The textfield to type the Dedicated IP token
          public static let accessibility = L10n.tr("Localizable", "dedicated.ip.token.textfield.accessibility", fallback: "The textfield to type the Dedicated IP token")
          /// Paste in your token here
          public static let placeholder = L10n.tr("Localizable", "dedicated.ip.token.textfield.placeholder", fallback: "Paste in your token here")
        }
      }
    }
  }
  public enum Email {
    public enum Validation {
      /// Email can't be empty.
      public static let empty = L10n.tr("Localizable", "email.validation.empty", fallback: "Email can't be empty.")
      /// Invalid email. Please try again.
      public static let invalid = L10n.tr("Localizable", "email.validation.invalid", fallback: "Invalid email. Please try again.")
    }
  }
  public enum ErrorAlert {
    public enum ConnectionError {
      public enum NoNetwork {
        /// Please check your internet connection and try again
        public static let message = L10n.tr("Localizable", "error_alert.connection_error.no_network.message", fallback: "Please check your internet connection and try again")
        /// Unable to connect
        public static let title = L10n.tr("Localizable", "error_alert.connection_error.no_network.title", fallback: "Unable to connect")
        public enum RetryAction {
          /// Retry
          public static let title = L10n.tr("Localizable", "error_alert.connection_error.no_network.retry_action.title", fallback: "Retry")
        }
      }
    }
  }
  public enum Expiration {
    /// Your subscription expires soon. Renew to stay protected.
    public static let message = L10n.tr("Localizable", "expiration.message", fallback: "Your subscription expires soon. Renew to stay protected.")
    /// Renewal
    public static let title = L10n.tr("Localizable", "expiration.title", fallback: "Renewal")
  }
  public enum Forceupdate {
    public enum Button {
      /// Update Now
      public static let update = L10n.tr("Localizable", "forceupdate.button.update", fallback: "Update Now")
    }
    public enum Label {
      /// You’re using an older version of PIA. Update your app now to enjoy an enhanced experience with all the latest features.
      public static let subtitle = L10n.tr("Localizable", "forceupdate.label.subtitle", fallback: "You’re using an older version of PIA. Update your app now to enjoy an enhanced experience with all the latest features.")
      /// Upgrade Your Experience
      public static let title = L10n.tr("Localizable", "forceupdate.label.title", fallback: "Upgrade Your Experience")
      public enum Vpn {
        /// Tapping “Update Now” will disconnect the VPN.
        public static let connected = L10n.tr("Localizable", "forceupdate.label.vpn.connected", fallback: "Tapping “Update Now” will disconnect the VPN.")
      }
    }
  }
  public enum Friend {
    public enum Referrals {
      /// Full name
      public static let fullName = L10n.tr("Localizable", "friend.referrals.fullName", fallback: "Full name")
      /// Signed up
      public static let signedup = L10n.tr("Localizable", "friend.referrals.signedup", fallback: "Signed up")
      /// Refer a Friend
      public static let title = L10n.tr("Localizable", "friend.referrals.title", fallback: "Refer a Friend")
      public enum Days {
        /// Free days acquired
        public static let acquired = L10n.tr("Localizable", "friend.referrals.days.acquired", fallback: "Free days acquired")
        /// %d days
        public static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.days.number", p1, fallback: "%d days")
        }
      }
      public enum Description {
        /// REFER A FRIEND. GET 30 DAYS FREE.
        public static let short = L10n.tr("Localizable", "friend.referrals.description.short", fallback: "REFER A FRIEND. GET 30 DAYS FREE.")
      }
      public enum Email {
        /// Invalid email. Please try again.
        public static let validation = L10n.tr("Localizable", "friend.referrals.email.validation", fallback: "Invalid email. Please try again.")
      }
      public enum Family {
        public enum Friends {
          /// Family and Friends Referral Program
          public static let program = L10n.tr("Localizable", "friend.referrals.family.friends.program", fallback: "Family and Friends Referral Program")
        }
      }
      public enum Friends {
        public enum Family {
          /// Refer your friends and family. For every sign up we’ll give you both 30 days free. 
          public static let title = L10n.tr("Localizable", "friend.referrals.friends.family.title", fallback: "Refer your friends and family. For every sign up we’ll give you both 30 days free. ")
        }
      }
      public enum Invitation {
        /// By sending this invitation, I agree to all of the terms and conditions of the Family and Friends Referral Program.
        public static let terms = L10n.tr("Localizable", "friend.referrals.invitation.terms", fallback: "By sending this invitation, I agree to all of the terms and conditions of the Family and Friends Referral Program.")
      }
      public enum Invite {
        /// Could not resend invite. Try again later.
        public static let error = L10n.tr("Localizable", "friend.referrals.invite.error", fallback: "Could not resend invite. Try again later.")
        /// Invite sent successfully
        public static let success = L10n.tr("Localizable", "friend.referrals.invite.success", fallback: "Invite sent successfully")
      }
      public enum Invites {
        /// You have sent %d invites
        public static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.invites.number", p1, fallback: "You have sent %d invites")
        }
        public enum Sent {
          /// Invites sent
          public static let title = L10n.tr("Localizable", "friend.referrals.invites.sent.title", fallback: "Invites sent")
        }
      }
      public enum Pending {
        /// %d pending invites
        public static func invites(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.pending.invites", p1, fallback: "%d pending invites")
        }
        public enum Invites {
          /// Pending invites
          public static let title = L10n.tr("Localizable", "friend.referrals.pending.invites.title", fallback: "Pending invites")
        }
      }
      public enum Privacy {
        /// Please note, for privacy reasons, all invites older than 30 days will be deleted.
        public static let note = L10n.tr("Localizable", "friend.referrals.privacy.note", fallback: "Please note, for privacy reasons, all invites older than 30 days will be deleted.")
      }
      public enum Reward {
        /// Reward given
        public static let given = L10n.tr("Localizable", "friend.referrals.reward.given", fallback: "Reward given")
      }
      public enum Send {
        /// Send invite
        public static let invite = L10n.tr("Localizable", "friend.referrals.send.invite", fallback: "Send invite")
      }
      public enum Share {
        /// Share your unique referral link
        public static let link = L10n.tr("Localizable", "friend.referrals.share.link", fallback: "Share your unique referral link")
        public enum Link {
          /// By sharing this link, you agree to all of the terms and conditions of the Family and Friends Referral Program.
          public static let terms = L10n.tr("Localizable", "friend.referrals.share.link.terms", fallback: "By sharing this link, you agree to all of the terms and conditions of the Family and Friends Referral Program.")
        }
      }
      public enum Signups {
        /// %d signups
        public static func number(_ p1: Int) -> String {
          return L10n.tr("Localizable", "friend.referrals.signups.number", p1, fallback: "%d signups")
        }
      }
      public enum View {
        public enum Invites {
          /// View invites sent
          public static let sent = L10n.tr("Localizable", "friend.referrals.view.invites.sent", fallback: "View invites sent")
        }
      }
    }
  }
  public enum Gdpr {
    public enum Accept {
      public enum Button {
        /// Agree and continue
        public static let title = L10n.tr("Localizable", "gdpr.accept.button.title", fallback: "Agree and continue")
      }
    }
    public enum Collect {
      public enum Data {
        /// E-mail Address for the purposes of account management and protection from abuse.
        /// 
        /// E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.
        public static let description = L10n.tr("Localizable", "gdpr.collect.data.description", fallback: "E-mail Address for the purposes of account management and protection from abuse.\n\nE-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.")
        /// Personal information we collect
        public static let title = L10n.tr("Localizable", "gdpr.collect.data.title", fallback: "Personal information we collect")
      }
    }
  }
  public enum Global {
    /// Add
    public static let add = L10n.tr("Localizable", "global.add", fallback: "Add")
    /// Automatic
    public static let automatic = L10n.tr("Localizable", "global.automatic", fallback: "Automatic")
    /// Cancel
    public static let cancel = L10n.tr("Localizable", "global.cancel", fallback: "Cancel")
    /// Clear
    public static let clear = L10n.tr("Localizable", "global.clear", fallback: "Clear")
    /// Close
    public static let close = L10n.tr("Localizable", "global.close", fallback: "Close")
    /// Copied to clipboard
    public static let copied = L10n.tr("Localizable", "global.copied", fallback: "Copied to clipboard")
    /// Copy
    public static let copy = L10n.tr("Localizable", "global.copy", fallback: "Copy")
    /// Disable
    public static let disable = L10n.tr("Localizable", "global.disable", fallback: "Disable")
    /// Disabled
    public static let disabled = L10n.tr("Localizable", "global.disabled", fallback: "Disabled")
    /// Edit
    public static let edit = L10n.tr("Localizable", "global.edit", fallback: "Edit")
    /// Empty
    public static let empty = L10n.tr("Localizable", "global.empty", fallback: "Empty")
    /// Enable
    public static let enable = L10n.tr("Localizable", "global.enable", fallback: "Enable")
    /// Enabled
    public static let enabled = L10n.tr("Localizable", "global.enabled", fallback: "Enabled")
    /// Error
    public static let error = L10n.tr("Localizable", "global.error", fallback: "Error")
    /// No
    public static let no = L10n.tr("Localizable", "global.no", fallback: "No")
    /// OK
    public static let ok = L10n.tr("Localizable", "global.ok", fallback: "OK")
    /// Optional
    public static let `optional` = L10n.tr("Localizable", "global.optional", fallback: "Optional")
    /// or
    public static let or = L10n.tr("Localizable", "global.or", fallback: "or")
    /// Remove
    public static let remove = L10n.tr("Localizable", "global.remove", fallback: "Remove")
    /// Required
    public static let `required` = L10n.tr("Localizable", "global.required", fallback: "Required")
    /// Share
    public static let share = L10n.tr("Localizable", "global.share", fallback: "Share")
    /// No internet connection found. Please confirm that you have an internet connection.
    public static let unreachable = L10n.tr("Localizable", "global.unreachable", fallback: "No internet connection found. Please confirm that you have an internet connection.")
    /// Update
    public static let update = L10n.tr("Localizable", "global.update", fallback: "Update")
    /// Version
    public static let version = L10n.tr("Localizable", "global.version", fallback: "Version")
    /// Yes
    public static let yes = L10n.tr("Localizable", "global.yes", fallback: "Yes")
    public enum General {
      /// General Settings
      public static let settings = L10n.tr("Localizable", "global.general.settings", fallback: "General Settings")
    }
    public enum Row {
      /// Row selection
      public static let selection = L10n.tr("Localizable", "global.row.selection", fallback: "Row selection")
    }
    public enum Version {
      /// Version %@ (%@)
      public static func format(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "global.version.format", String(describing: p1), String(describing: p2), fallback: "Version %@ (%@)")
      }
    }
    public enum Vpn {
      /// VPN Settings
      public static let settings = L10n.tr("Localizable", "global.vpn.settings", fallback: "VPN Settings")
    }
  }
  public enum HelpMenu {
    public enum AboutOptions {
      public enum Acknowledgements {
        /// Acknowledgements
        public static let title = L10n.tr("Localizable", "help_menu.about_options.acknowledgements.title", fallback: "Acknowledgements")
      }
      public enum PrivacyPolicy {
        /// Privacy Policy
        public static let title = L10n.tr("Localizable", "help_menu.about_options.privacy_policy.title", fallback: "Privacy Policy")
      }
    }
    public enum AboutSection {
      public enum Acknowledgments {
        public enum Copyright {
          /// Our Software as a Service (SaaS) platform may occasionally include third-party content, services, or integrations to enhance user experience and functionality. This content may include but is not limited to, APIs, widgets, plugins, or links to external websites. While we strive to ensure the quality and reliability of third-party content, we want to emphasize that such content is provided 'as is' and we do not endorse or guarantee the accuracy, reliability, or suitability of any third-party content.
          /// 
          /// Users should be aware that accessing or utilizing third-party content may subject them to the terms of use, privacy policies, and other agreements of those third-party providers. We encourage users to review such terms and policies before engaging with third-party content.
          public static let description = L10n.tr("Localizable", "help_menu.about_section.acknowledgments.copyright.description", fallback: "Our Software as a Service (SaaS) platform may occasionally include third-party content, services, or integrations to enhance user experience and functionality. This content may include but is not limited to, APIs, widgets, plugins, or links to external websites. While we strive to ensure the quality and reliability of third-party content, we want to emphasize that such content is provided 'as is' and we do not endorse or guarantee the accuracy, reliability, or suitability of any third-party content.\n\nUsers should be aware that accessing or utilizing third-party content may subject them to the terms of use, privacy policies, and other agreements of those third-party providers. We encourage users to review such terms and policies before engaging with third-party content.")
          /// COPYRIGHT 2014-2024 PRIVATE INTERNET ACCESS INC VPN
          public static let title = L10n.tr("Localizable", "help_menu.about_section.acknowledgments.copyright.title", fallback: "COPYRIGHT 2014-2024 PRIVATE INTERNET ACCESS INC VPN")
        }
      }
      public enum PrivacyPolicy {
        /// This privacy policy ('Privacy Policy' or 'Policy') explains the privacy practices of Private Internet Access, Inc., (collectively, 'We', 'Us', 'Data Controller', 'Company', or 'PIA') and applies to users ('User(s)' or 'You') of PIA's services, including, among other things, the PIA VPN service ('Service') and PIA website at www.privateinternetaccess.com ('Website').
        public static let description = L10n.tr("Localizable", "help_menu.about_section.privacy_policy.description", fallback: "This privacy policy ('Privacy Policy' or 'Policy') explains the privacy practices of Private Internet Access, Inc., (collectively, 'We', 'Us', 'Data Controller', 'Company', or 'PIA') and applies to users ('User(s)' or 'You') of PIA's services, including, among other things, the PIA VPN service ('Service') and PIA website at www.privateinternetaccess.com ('Website').")
        public enum QrCode {
          /// Scan the QR code to access the full privacy policy on your device.
          public static let message = L10n.tr("Localizable", "help_menu.about_section.privacy_policy.qr_code.message", fallback: "Scan the QR code to access the full privacy policy on your device.")
        }
      }
    }
    public enum AppVersionSection {
      /// App Version
      public static let title = L10n.tr("Localizable", "help_menu.app_version_section.title", fallback: "App Version")
    }
    public enum ContactSupport {
      public enum QrCode {
        /// Scan the QR code to get in touch to our Support Team.
        public static let message = L10n.tr("Localizable", "help_menu.contact_support.qr_code.message", fallback: "Scan the QR code to get in touch to our Support Team.")
        /// Contact Support
        public static let title = L10n.tr("Localizable", "help_menu.contact_support.qr_code.title", fallback: "Contact Support")
      }
    }
    public enum HelpImprove {
      public enum Disabled {
        /// OFF
        public static let title = L10n.tr("Localizable", "help_menu.help_improve.disabled.title", fallback: "OFF")
      }
      public enum Enabled {
        /// ON
        public static let title = L10n.tr("Localizable", "help_menu.help_improve.enabled.title", fallback: "ON")
      }
    }
  }
  public enum Hotspothelper {
    public enum Display {
      /// 🔒 Activate VPN WiFi Protection in PIA Settings to secure this connection.
      public static let name = L10n.tr("Localizable", "hotspothelper.display.name", fallback: "🔒 Activate VPN WiFi Protection in PIA Settings to secure this connection.")
      public enum Protected {
        /// 🔒 PIA VPN WiFi Protection Enabled - We got your back.
        public static let name = L10n.tr("Localizable", "hotspothelper.display.protected.name", fallback: "🔒 PIA VPN WiFi Protection Enabled - We got your back.")
      }
    }
  }
  public enum Inapp {
    public enum Messages {
      public enum Settings {
        /// Settings have been updated
        public static let updated = L10n.tr("Localizable", "inapp.messages.settings.updated", fallback: "Settings have been updated")
      }
      public enum Toggle {
        /// Show Service Communication Messages
        public static let title = L10n.tr("Localizable", "inapp.messages.toggle.title", fallback: "Show Service Communication Messages")
      }
    }
  }
  public enum LocalNotification {
    public enum NonCompliantWifi {
      /// Tap here to secure your device
      public static let text = L10n.tr("Localizable", "local_notification.non_compliant_wifi.text", fallback: "Tap here to secure your device")
      /// Unsecured Wi-Fi: %@
      public static func title(_ p1: Any) -> String {
        return L10n.tr("Localizable", "local_notification.non_compliant_wifi.title", String(describing: p1), fallback: "Unsecured Wi-Fi: %@")
      }
    }
  }
  public enum LocationSelection {
    public enum AnyOtherLocation {
      /// Selected Location
      public static let title = L10n.tr("Localizable", "location_selection.any_other_location.title", fallback: "Selected Location")
    }
    public enum OptimalLocation {
      /// Optimal Location
      public static let title = L10n.tr("Localizable", "location_selection.optimal_location.title", fallback: "Optimal Location")
    }
  }
  public enum Menu {
    public enum Accessibility {
      /// Menu
      public static let item = L10n.tr("Localizable", "menu.accessibility.item", fallback: "Menu")
      /// Logged in as %@
      public static func loggedAs(_ p1: Any) -> String {
        return L10n.tr("Localizable", "menu.accessibility.logged_as", String(describing: p1), fallback: "Logged in as %@")
      }
      public enum Edit {
        /// Edit
        public static let tile = L10n.tr("Localizable", "menu.accessibility.edit.tile", fallback: "Edit")
      }
    }
    public enum Expiration {
      /// %d days
      public static func days(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.days", p1, fallback: "%d days")
      }
      /// Subscription expires in
      public static let expiresIn = L10n.tr("Localizable", "menu.expiration.expires_in", fallback: "Subscription expires in")
      /// %d hours
      public static func hours(_ p1: Int) -> String {
        return L10n.tr("Localizable", "menu.expiration.hours", p1, fallback: "%d hours")
      }
      /// one hour
      public static let oneHour = L10n.tr("Localizable", "menu.expiration.one_hour", fallback: "one hour")
      /// UPGRADE ACCOUNT
      public static let upgrade = L10n.tr("Localizable", "menu.expiration.upgrade", fallback: "UPGRADE ACCOUNT")
    }
    public enum Item {
      /// About
      public static let about = L10n.tr("Localizable", "menu.item.about", fallback: "About")
      /// Account
      public static let account = L10n.tr("Localizable", "menu.item.account", fallback: "Account")
      /// Log out
      public static let logout = L10n.tr("Localizable", "menu.item.logout", fallback: "Log out")
      /// Region selection
      public static let region = L10n.tr("Localizable", "menu.item.region", fallback: "Region selection")
      /// Settings
      public static let settings = L10n.tr("Localizable", "menu.item.settings", fallback: "Settings")
      public enum Web {
        /// Home page
        public static let home = L10n.tr("Localizable", "menu.item.web.home", fallback: "Home page")
        /// Privacy policy
        public static let privacy = L10n.tr("Localizable", "menu.item.web.privacy", fallback: "Privacy policy")
        /// Support
        public static let support = L10n.tr("Localizable", "menu.item.web.support", fallback: "Support")
      }
    }
    public enum Logout {
      /// Log out
      public static let confirm = L10n.tr("Localizable", "menu.logout.confirm", fallback: "Log out")
      /// Logging out will disable the VPN and leave you unprotected.
      public static let message = L10n.tr("Localizable", "menu.logout.message", fallback: "Logging out will disable the VPN and leave you unprotected.")
      /// Log out
      public static let title = L10n.tr("Localizable", "menu.logout.title", fallback: "Log out")
    }
    public enum Renewal {
      /// Purchase
      public static let purchase = L10n.tr("Localizable", "menu.renewal.purchase", fallback: "Purchase")
      /// Renew
      public static let renew = L10n.tr("Localizable", "menu.renewal.renew", fallback: "Renew")
      /// Renewal
      public static let title = L10n.tr("Localizable", "menu.renewal.title", fallback: "Renewal")
      public enum Message {
        /// Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.
        public static let trial = L10n.tr("Localizable", "menu.renewal.message.trial", fallback: "Trial accounts are not eligible for renewal. Please purchase a new account upon expiry to continue service.")
        /// Apple servers currently unavailable. Please try again later.
        public static let unavailable = L10n.tr("Localizable", "menu.renewal.message.unavailable", fallback: "Apple servers currently unavailable. Please try again later.")
        /// Please use our website to renew your subscription.
        public static let website = L10n.tr("Localizable", "menu.renewal.message.website", fallback: "Please use our website to renew your subscription.")
      }
    }
  }
  public enum Network {
    public enum Management {
      public enum Tool {
        /// Your automation settings are configured to keep the VPN disconnected under the current network conditions.
        public static let alert = L10n.tr("Localizable", "network.management.tool.alert", fallback: "Your automation settings are configured to keep the VPN disconnected under the current network conditions.")
        /// Disable Automation
        public static let disable = L10n.tr("Localizable", "network.management.tool.disable", fallback: "Disable Automation")
        /// Manage Automation
        public static let title = L10n.tr("Localizable", "network.management.tool.title", fallback: "Manage Automation")
        public enum Add {
          /// Add new rule
          public static let rule = L10n.tr("Localizable", "network.management.tool.add.rule", fallback: "Add new rule")
        }
        public enum Always {
          /// Always connect VPN
          public static let connect = L10n.tr("Localizable", "network.management.tool.always.connect", fallback: "Always connect VPN")
          /// Always disconnect VPN
          public static let disconnect = L10n.tr("Localizable", "network.management.tool.always.disconnect", fallback: "Always disconnect VPN")
        }
        public enum Choose {
          /// Choose a WiFi network to add a new rule. 
          public static let wifi = L10n.tr("Localizable", "network.management.tool.choose.wifi", fallback: "Choose a WiFi network to add a new rule. ")
        }
        public enum Enable {
          /// Enable Automation
          public static let automation = L10n.tr("Localizable", "network.management.tool.enable.automation", fallback: "Enable Automation")
        }
        public enum Mobile {
          /// Mobile data
          public static let data = L10n.tr("Localizable", "network.management.tool.mobile.data", fallback: "Mobile data")
        }
        public enum Open {
          /// Open WiFi
          public static let wifi = L10n.tr("Localizable", "network.management.tool.open.wifi", fallback: "Open WiFi")
        }
        public enum Retain {
          /// Retain VPN State
          public static let state = L10n.tr("Localizable", "network.management.tool.retain.state", fallback: "Retain VPN State")
        }
        public enum Secure {
          /// Secure WiFi
          public static let wifi = L10n.tr("Localizable", "network.management.tool.secure.wifi", fallback: "Secure WiFi")
        }
      }
    }
  }
  public enum Notifications {
    public enum Disabled {
      /// Enable notifications to get a reminder to renew your subscription before it expires.
      public static let message = L10n.tr("Localizable", "notifications.disabled.message", fallback: "Enable notifications to get a reminder to renew your subscription before it expires.")
      /// Settings
      public static let settings = L10n.tr("Localizable", "notifications.disabled.settings", fallback: "Settings")
      /// Notifications disabled
      public static let title = L10n.tr("Localizable", "notifications.disabled.title", fallback: "Notifications disabled")
    }
  }
  public enum Onboarding {
    public enum ConnectionStats {
      /// Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.
      public static let subtitle = L10n.tr("Localizable", "onboarding.connection_stats.subtitle", fallback: "Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.")
      /// Help Improve PIA
      public static let title = L10n.tr("Localizable", "onboarding.connection_stats.title", fallback: "Help Improve PIA")
    }
    public enum VpnConfiguration {
      /// Configure PIA
      public static let button = L10n.tr("Localizable", "onboarding.vpn_configuration.button", fallback: "Configure PIA")
      /// When connecting for the first time, you will be asked to allow PIA to access VPN configurations. This is necessary in order to encrypt your traffic. 
      /// 
      /// Please remember that we don't monitor, filter, or log your online activity. 
      /// 
      /// To proceed click on the button below.
      public static let subtitle = L10n.tr("Localizable", "onboarding.vpn_configuration.subtitle", fallback: "When connecting for the first time, you will be asked to allow PIA to access VPN configurations. This is necessary in order to encrypt your traffic. \n\nPlease remember that we don't monitor, filter, or log your online activity. \n\nTo proceed click on the button below.")
      /// Configure PIA
      public static let title = L10n.tr("Localizable", "onboarding.vpn_configuration.title", fallback: "Configure PIA")
    }
  }
  public enum Rating {
    public enum Alert {
      public enum Button {
        /// No, thanks.
        public static let nothanks = L10n.tr("Localizable", "rating.alert.button.nothanks", fallback: "No, thanks.")
        /// Not Really
        public static let notreally = L10n.tr("Localizable", "rating.alert.button.notreally", fallback: "Not Really")
        /// Ok, sure!
        public static let oksure = L10n.tr("Localizable", "rating.alert.button.oksure", fallback: "Ok, sure!")
      }
    }
    public enum Enjoy {
      /// Are you enjoying PIA VPN?
      public static let question = L10n.tr("Localizable", "rating.enjoy.question", fallback: "Are you enjoying PIA VPN?")
      /// We hope our VPN product is meeting your expectations
      public static let subtitle = L10n.tr("Localizable", "rating.enjoy.subtitle", fallback: "We hope our VPN product is meeting your expectations")
    }
    public enum Error {
      /// The connection couldn't be established
      public static let question = L10n.tr("Localizable", "rating.error.question", fallback: "The connection couldn't be established")
      /// You can try selecting a different region or letting us know about it by opening a support ticket.
      public static let subtitle = L10n.tr("Localizable", "rating.error.subtitle", fallback: "You can try selecting a different region or letting us know about it by opening a support ticket.")
      public enum Button {
        /// Send feedback
        public static let send = L10n.tr("Localizable", "rating.error.button.send", fallback: "Send feedback")
      }
    }
    public enum Problems {
      /// What went wrong?
      public static let question = L10n.tr("Localizable", "rating.problems.question", fallback: "What went wrong?")
      /// Do you want to give feedback? We can help you to improve your experience using PIA
      public static let subtitle = L10n.tr("Localizable", "rating.problems.subtitle", fallback: "Do you want to give feedback? We can help you to improve your experience using PIA")
    }
    public enum Rate {
      /// How about a rating on the AppStore?
      public static let question = L10n.tr("Localizable", "rating.rate.question", fallback: "How about a rating on the AppStore?")
      /// We appreciate you sharing your experience
      public static let subtitle = L10n.tr("Localizable", "rating.rate.subtitle", fallback: "We appreciate you sharing your experience")
    }
    public enum Review {
      /// How about an AppStore review?
      public static let question = L10n.tr("Localizable", "rating.review.question", fallback: "How about an AppStore review?")
    }
  }
  public enum Region {
    public enum Accessibility {
      /// Add a favorite region
      public static let favorite = L10n.tr("Localizable", "region.accessibility.favorite", fallback: "Add a favorite region")
      /// Filter
      public static let filter = L10n.tr("Localizable", "region.accessibility.filter", fallback: "Filter")
      /// Remove a favorite region
      public static let unfavorite = L10n.tr("Localizable", "region.accessibility.unfavorite", fallback: "Remove a favorite region")
    }
    public enum Filter {
      /// Favorites
      public static let favorites = L10n.tr("Localizable", "region.filter.favorites", fallback: "Favorites")
      /// Latency
      public static let latency = L10n.tr("Localizable", "region.filter.latency", fallback: "Latency")
      /// Name
      public static let name = L10n.tr("Localizable", "region.filter.name", fallback: "Name")
      /// Sort regions by
      public static let sortby = L10n.tr("Localizable", "region.filter.sortby", fallback: "Sort regions by")
    }
    public enum Refresh {
      public enum Connected {
        /// Unable to update latency while being connected to the VPN
        public static let error = L10n.tr("Localizable", "region.refresh.connected.error", fallback: "Unable to update latency while being connected to the VPN")
      }
    }
    public enum Search {
      /// Search for a region
      public static let placeholder = L10n.tr("Localizable", "region.search.placeholder", fallback: "Search for a region")
    }
  }
  public enum Regions {
    public enum ContextMenu {
      public enum Favorites {
        public enum Add {
          /// Add to Favorites
          public static let text = L10n.tr("Localizable", "regions.context_menu.favorites.add.text", fallback: "Add to Favorites")
        }
        public enum Remove {
          /// Remove from Favorites
          public static let text = L10n.tr("Localizable", "regions.context_menu.favorites.remove.text", fallback: "Remove from Favorites")
        }
      }
    }
    public enum Filter {
      public enum All {
        /// All
        public static let title = L10n.tr("Localizable", "regions.filter.all.title", fallback: "All")
      }
      public enum Favorites {
        /// Favourite(s)
        public static let title = L10n.tr("Localizable", "regions.filter.favorites.title", fallback: "Favourite(s)")
      }
      public enum Search {
        /// Search
        public static let title = L10n.tr("Localizable", "regions.filter.search.title", fallback: "Search")
      }
    }
    public enum List {
      public enum AllLocations {
        /// All Locations
        public static let title = L10n.tr("Localizable", "regions.list.all_locations.title", fallback: "All Locations")
      }
      public enum OptimalLocation {
        /// Optimal Location
        public static let title = L10n.tr("Localizable", "regions.list.optimal_location.title", fallback: "Optimal Location")
      }
      public enum OptimalLocationWithDipLocation {
        /// Optimal Location/Dedicated IP
        public static let title = L10n.tr("Localizable", "regions.list.optimal_location_with_dip_location.title", fallback: "Optimal Location/Dedicated IP")
      }
    }
    public enum ListItem {
      public enum Default {
        /// Default Location
        public static let title = L10n.tr("Localizable", "regions.list_item.default.title", fallback: "Default Location")
      }
    }
    public enum Search {
      public enum Button {
        /// Search for a Location
        public static let title = L10n.tr("Localizable", "regions.search.button.title", fallback: "Search for a Location")
      }
      public enum InputField {
        /// Search for city or country
        public static let placeholder = L10n.tr("Localizable", "regions.search.input_field.placeholder", fallback: "Search for city or country")
      }
      public enum PreviousResults {
        /// Last Searched Locations
        public static let title = L10n.tr("Localizable", "regions.search.previous_results.title", fallback: "Last Searched Locations")
      }
      public enum RecommendedLocations {
        /// Recommended Locations
        public static let title = L10n.tr("Localizable", "regions.search.recommended_locations.title", fallback: "Recommended Locations")
      }
      public enum Results {
        /// Search Results
        public static let title = L10n.tr("Localizable", "regions.search.results.title", fallback: "Search Results")
      }
    }
  }
  public enum Renewal {
    public enum Failure {
      /// Your purchase receipt couldn't be submitted, please retry at a later time.
      public static let message = L10n.tr("Localizable", "renewal.failure.message", fallback: "Your purchase receipt couldn't be submitted, please retry at a later time.")
    }
    public enum Success {
      /// Your account was successfully renewed.
      public static let message = L10n.tr("Localizable", "renewal.success.message", fallback: "Your account was successfully renewed.")
      /// Thank you
      public static let title = L10n.tr("Localizable", "renewal.success.title", fallback: "Thank you")
    }
  }
  public enum Server {
    public enum Reconnection {
      public enum Please {
        /// Please wait...
        public static let wait = L10n.tr("Localizable", "server.reconnection.please.wait", fallback: "Please wait...")
      }
      public enum Still {
        /// Still trying to connect...
        public static let connection = L10n.tr("Localizable", "server.reconnection.still.connection", fallback: "Still trying to connect...")
      }
    }
  }
  public enum Set {
    public enum Email {
      /// We need your email to send your username and password.
      public static let why = L10n.tr("Localizable", "set.email.why", fallback: "We need your email to send your username and password.")
      public enum Error {
        /// You must enter an email address.
        public static let validation = L10n.tr("Localizable", "set.email.error.validation", fallback: "You must enter an email address.")
      }
      public enum Form {
        /// Enter your email address
        public static let email = L10n.tr("Localizable", "set.email.form.email", fallback: "Enter your email address")
      }
      public enum Password {
        /// Password
        public static let caption = L10n.tr("Localizable", "set.email.password.caption", fallback: "Password")
      }
      public enum Success {
        /// We have sent your account username and password at your email address at %@
        public static func messageFormat(_ p1: Any) -> String {
          return L10n.tr("Localizable", "set.email.success.message_format", String(describing: p1), fallback: "We have sent your account username and password at your email address at %@")
        }
      }
    }
  }
  public enum Settings {
    public enum Account {
      public enum LogOutAlert {
        /// Logging out will terminate any active VPN connection and leave you unprotected.
        public static let message = L10n.tr("Localizable", "settings.account.log_out_alert.message", fallback: "Logging out will terminate any active VPN connection and leave you unprotected.")
        /// Are you sure?
        public static let title = L10n.tr("Localizable", "settings.account.log_out_alert.title", fallback: "Are you sure?")
      }
      public enum LogOutButton {
        /// Log Out
        public static let title = L10n.tr("Localizable", "settings.account.log_out_button.title", fallback: "Log Out")
      }
      public enum SubscriptionExpiry {
        /// Subscription expires on
        public static let title = L10n.tr("Localizable", "settings.account.subscription_expiry.title", fallback: "Subscription expires on")
      }
    }
    public enum ApplicationInformation {
      /// APPLICATION INFORMATION
      public static let title = L10n.tr("Localizable", "settings.application_information.title", fallback: "APPLICATION INFORMATION")
      public enum Debug {
        /// Send Debug Log to support
        public static let title = L10n.tr("Localizable", "settings.application_information.debug.title", fallback: "Send Debug Log to support")
        public enum Empty {
          /// Debug information is empty, please attempt a connection before retrying submission.
          public static let message = L10n.tr("Localizable", "settings.application_information.debug.empty.message", fallback: "Debug information is empty, please attempt a connection before retrying submission.")
          /// Empty debug information
          public static let title = L10n.tr("Localizable", "settings.application_information.debug.empty.title", fallback: "Empty debug information")
        }
        public enum Failure {
          /// Debug information could not be submitted.
          public static let message = L10n.tr("Localizable", "settings.application_information.debug.failure.message", fallback: "Debug information could not be submitted.")
          /// Error during submission
          public static let title = L10n.tr("Localizable", "settings.application_information.debug.failure.title", fallback: "Error during submission")
        }
        public enum Success {
          /// Debug information successfully submitted.
          /// ID: %@
          /// Please note this ID, as our support team will require this to locate your submission.
          public static func message(_ p1: Any) -> String {
            return L10n.tr("Localizable", "settings.application_information.debug.success.message", String(describing: p1), fallback: "Debug information successfully submitted.\nID: %@\nPlease note this ID, as our support team will require this to locate your submission.")
          }
          /// Debug information submitted
          public static let title = L10n.tr("Localizable", "settings.application_information.debug.success.title", fallback: "Debug information submitted")
        }
      }
      public enum DebugLogging {
        /// Enable Debug Logging
        public static let title = L10n.tr("Localizable", "settings.application_information.debug_logging.title", fallback: "Enable Debug Logging")
      }
    }
    public enum ApplicationSettings {
      /// APPLICATION SETTINGS
      public static let title = L10n.tr("Localizable", "settings.application_settings.title", fallback: "APPLICATION SETTINGS")
      public enum ActiveTheme {
        /// Active theme
        public static let title = L10n.tr("Localizable", "settings.application_settings.active_theme.title", fallback: "Active theme")
      }
      public enum AllowLocalNetwork {
        /// Stay connected to local devices like printers or file servers while connected to the VPN. (Allow this only if you trust the people and devices on your network.)
        public static let footer = L10n.tr("Localizable", "settings.application_settings.allow_local_network.footer", fallback: "Stay connected to local devices like printers or file servers while connected to the VPN. (Allow this only if you trust the people and devices on your network.)")
        /// Allow access to devices on local network
        public static let title = L10n.tr("Localizable", "settings.application_settings.allow_local_network.title", fallback: "Allow access to devices on local network")
      }
      public enum DarkTheme {
        /// Dark theme
        public static let title = L10n.tr("Localizable", "settings.application_settings.dark_theme.title", fallback: "Dark theme")
      }
      public enum KillSwitch {
        /// The VPN kill switch prevents access to the Internet if the VPN connection is reconnecting. This excludes disconnecting manually.
        public static let footer = L10n.tr("Localizable", "settings.application_settings.kill_switch.footer", fallback: "The VPN kill switch prevents access to the Internet if the VPN connection is reconnecting. This excludes disconnecting manually.")
        /// VPN Kill Switch
        public static let title = L10n.tr("Localizable", "settings.application_settings.kill_switch.title", fallback: "VPN Kill Switch")
      }
      public enum LeakProtection {
        /// iOS includes features designed to operate outside the VPN by default, such as AirDrop, CarPlay, AirPlay, and Personal Hotspots. Enabling custom leak protection routes this traffic through the VPN but may affect how these features function. More info
        public static let footer = L10n.tr("Localizable", "settings.application_settings.leak_protection.footer", fallback: "iOS includes features designed to operate outside the VPN by default, such as AirDrop, CarPlay, AirPlay, and Personal Hotspots. Enabling custom leak protection routes this traffic through the VPN but may affect how these features function. More info")
        /// More info
        public static let moreInfo = L10n.tr("Localizable", "settings.application_settings.leak_protection.more_info", fallback: "More info")
        /// Leak Protection
        public static let title = L10n.tr("Localizable", "settings.application_settings.leak_protection.title", fallback: "Leak Protection")
        public enum Alert {
          /// Changes to the VPN Settings will take effect on the next connection
          public static let title = L10n.tr("Localizable", "settings.application_settings.leak_protection.alert.title", fallback: "Changes to the VPN Settings will take effect on the next connection")
        }
      }
      public enum Mace {
        /// PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.
        public static let footer = L10n.tr("Localizable", "settings.application_settings.mace.footer", fallback: "PIA MACE™ blocks ads, trackers, and malware while you're connected to the VPN.")
        /// PIA MACE™
        public static let title = L10n.tr("Localizable", "settings.application_settings.mace.title", fallback: "PIA MACE™")
      }
      public enum ReconnectNotifications {
        /// Get alerts when VPN is reconnecting to a different location. Disable to stop receiving these notifications.
        public static let footer = L10n.tr("Localizable", "settings.application_settings.reconnect_notifications.footer", fallback: "Get alerts when VPN is reconnecting to a different location. Disable to stop receiving these notifications.")
        /// Reconnect Notifications
        public static let title = L10n.tr("Localizable", "settings.application_settings.reconnect_notifications.title", fallback: "Reconnect Notifications")
      }
    }
    public enum Cards {
      public enum History {
        /// Latest News
        public static let title = L10n.tr("Localizable", "settings.cards.history.title", fallback: "Latest News")
      }
    }
    public enum Commit {
      public enum Buttons {
        /// Later
        public static let later = L10n.tr("Localizable", "settings.commit.buttons.later", fallback: "Later")
        /// Reconnect
        public static let reconnect = L10n.tr("Localizable", "settings.commit.buttons.reconnect", fallback: "Reconnect")
      }
      public enum Messages {
        /// The VPN must reconnect for some changes to take effect.
        public static let mustDisconnect = L10n.tr("Localizable", "settings.commit.messages.must_disconnect", fallback: "The VPN must reconnect for some changes to take effect.")
        /// Reconnect the VPN to apply changes.
        public static let shouldReconnect = L10n.tr("Localizable", "settings.commit.messages.should_reconnect", fallback: "Reconnect the VPN to apply changes.")
      }
    }
    public enum Connection {
      /// CONNECTION
      public static let title = L10n.tr("Localizable", "settings.connection.title", fallback: "CONNECTION")
      public enum RemotePort {
        /// Remote Port
        public static let title = L10n.tr("Localizable", "settings.connection.remote_port.title", fallback: "Remote Port")
      }
      public enum SocketProtocol {
        /// Socket
        public static let title = L10n.tr("Localizable", "settings.connection.socket_protocol.title", fallback: "Socket")
      }
      public enum Transport {
        /// Transport
        public static let title = L10n.tr("Localizable", "settings.connection.transport.title", fallback: "Transport")
      }
      public enum VpnProtocol {
        /// Protocol Selection
        public static let title = L10n.tr("Localizable", "settings.connection.vpn_protocol.title", fallback: "Protocol Selection")
      }
    }
    public enum ContentBlocker {
      /// To enable or disable Content Blocker go to Settings > Apps > Safari > Extensions and toggle PIA VPN.
      public static let footer = L10n.tr("Localizable", "settings.content_blocker.footer", fallback: "To enable or disable Content Blocker go to Settings > Apps > Safari > Extensions and toggle PIA VPN.")
      /// Safari Content Blocker state
      public static let title = L10n.tr("Localizable", "settings.content_blocker.title", fallback: "Safari Content Blocker state")
      public enum Refresh {
        /// Refresh block list
        public static let title = L10n.tr("Localizable", "settings.content_blocker.refresh.title", fallback: "Refresh block list")
      }
      public enum State {
        /// Current state
        public static let title = L10n.tr("Localizable", "settings.content_blocker.state.title", fallback: "Current state")
      }
    }
    public enum Dedicatedip {
      /// Activate
      public static let button = L10n.tr("Localizable", "settings.dedicatedip.button", fallback: "Activate")
      /// Enter Your Dedicated IP Token
      public static let placeholder = L10n.tr("Localizable", "settings.dedicatedip.placeholder", fallback: "Enter Your Dedicated IP Token")
      /// Activate your dedicated IP by typing your token in the field 
      /// below. You can purchase a dedicated IP from your Client 
      /// Control Panel on the PIA website.
      public static let subtitle = L10n.tr("Localizable", "settings.dedicatedip.subtitle", fallback: "Activate your dedicated IP by typing your token in the field \nbelow. You can purchase a dedicated IP from your Client \nControl Panel on the PIA website.")
      /// Enter Dedicated IP
      public static let title1 = L10n.tr("Localizable", "settings.dedicatedip.title1", fallback: "Enter Dedicated IP")
      /// Dedicated IP
      public static let title2 = L10n.tr("Localizable", "settings.dedicatedip.title2", fallback: "Dedicated IP")
      public enum Alert {
        public enum Failure {
          /// Your token is either invalid or has expired.
          public static let message = L10n.tr("Localizable", "settings.dedicatedip.alert.failure.message", fallback: "Your token is either invalid or has expired.")
          /// Something went wrong
          public static let title = L10n.tr("Localizable", "settings.dedicatedip.alert.failure.title", fallback: "Something went wrong")
          public enum Message {
            /// Your token can't be empty.
            public static let empty = L10n.tr("Localizable", "settings.dedicatedip.alert.failure.message.empty", fallback: "Your token can't be empty.")
          }
        }
        public enum Success {
          /// Continue
          public static let button = L10n.tr("Localizable", "settings.dedicatedip.alert.success.button", fallback: "Continue")
          /// Your Dedicated IP it's now active.
          public static let message = L10n.tr("Localizable", "settings.dedicatedip.alert.success.message", fallback: "Your Dedicated IP it's now active.")
          /// You're all set
          public static let title = L10n.tr("Localizable", "settings.dedicatedip.alert.success.title", fallback: "You're all set")
        }
      }
      public enum Stats {
        /// Dedicated IP
        public static let dedicatedip = L10n.tr("Localizable", "settings.dedicatedip.stats.dedicatedip", fallback: "Dedicated IP")
        /// IP Address
        public static let ip = L10n.tr("Localizable", "settings.dedicatedip.stats.ip", fallback: "IP Address")
        /// Location
        public static let location = L10n.tr("Localizable", "settings.dedicatedip.stats.location", fallback: "Location")
        /// Quick Action
        public static let quickAction = L10n.tr("Localizable", "settings.dedicatedip.stats.quickAction", fallback: "Quick Action")
        public enum Delete {
          /// Delete Dedicated IP
          public static let button = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.button", fallback: "Delete Dedicated IP")
          public enum Alert {
            /// Yes, Delete
            public static let delete = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.delete", fallback: "Yes, Delete")
            /// You are about to remove your Dedicated IP from your account.
            public static let message = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.message", fallback: "You are about to remove your Dedicated IP from your account.")
            /// Are you sure?
            public static let title = L10n.tr("Localizable", "settings.dedicatedip.stats.delete.alert.title", fallback: "Are you sure?")
          }
        }
      }
      public enum Status {
        /// Active
        public static let active = L10n.tr("Localizable", "settings.dedicatedip.status.active", fallback: "Active")
        /// Error
        public static let error = L10n.tr("Localizable", "settings.dedicatedip.status.error", fallback: "Error")
        /// Expired
        public static let expired = L10n.tr("Localizable", "settings.dedicatedip.status.expired", fallback: "Expired")
        /// Invalid
        public static let invalid = L10n.tr("Localizable", "settings.dedicatedip.status.invalid", fallback: "Invalid")
      }
    }
    public enum Dns {
      /// Custom
      public static let custom = L10n.tr("Localizable", "settings.dns.custom", fallback: "Custom")
      /// Primary DNS
      public static let primaryDNS = L10n.tr("Localizable", "settings.dns.primaryDNS", fallback: "Primary DNS")
      /// Secondary DNS
      public static let secondaryDNS = L10n.tr("Localizable", "settings.dns.secondaryDNS", fallback: "Secondary DNS")
      public enum Alert {
        public enum Clear {
          /// This will clear your custom DNS and default to PIA DNS.
          public static let message = L10n.tr("Localizable", "settings.dns.alert.clear.message", fallback: "This will clear your custom DNS and default to PIA DNS.")
          /// Clear DNS
          public static let title = L10n.tr("Localizable", "settings.dns.alert.clear.title", fallback: "Clear DNS")
        }
        public enum Create {
          /// Using non PIA DNS could expose your DNS traffic to third parties and compromise your privacy.
          public static let message = L10n.tr("Localizable", "settings.dns.alert.create.message", fallback: "Using non PIA DNS could expose your DNS traffic to third parties and compromise your privacy.")
        }
      }
      public enum Custom {
        /// Custom DNS
        public static let dns = L10n.tr("Localizable", "settings.dns.custom.dns", fallback: "Custom DNS")
      }
      public enum Validation {
        public enum Primary {
          /// Primary DNS is not valid.
          public static let invalid = L10n.tr("Localizable", "settings.dns.validation.primary.invalid", fallback: "Primary DNS is not valid.")
          /// Primary DNS is mandatory.
          public static let mandatory = L10n.tr("Localizable", "settings.dns.validation.primary.mandatory", fallback: "Primary DNS is mandatory.")
        }
        public enum Secondary {
          /// Secondary DNS is not valid.
          public static let invalid = L10n.tr("Localizable", "settings.dns.validation.secondary.invalid", fallback: "Secondary DNS is not valid.")
        }
      }
    }
    public enum Encryption {
      /// ENCRYPTION
      public static let title = L10n.tr("Localizable", "settings.encryption.title", fallback: "ENCRYPTION")
      public enum Cipher {
        /// Data Encryption
        public static let title = L10n.tr("Localizable", "settings.encryption.cipher.title", fallback: "Data Encryption")
      }
      public enum Digest {
        /// Data Authentication
        public static let title = L10n.tr("Localizable", "settings.encryption.digest.title", fallback: "Data Authentication")
      }
      public enum Handshake {
        /// Handshake
        public static let title = L10n.tr("Localizable", "settings.encryption.handshake.title", fallback: "Handshake")
      }
    }
    public enum Geo {
      public enum Servers {
        /// Show Geo-located Regions
        public static let description = L10n.tr("Localizable", "settings.geo.servers.description", fallback: "Show Geo-located Regions")
      }
    }
    public enum Hotspothelper {
      /// Configure how PIA will behaves on connection to WiFi or cellular networks. This excludes disconnecting manually.
      public static let description = L10n.tr("Localizable", "settings.hotspothelper.description", fallback: "Configure how PIA will behaves on connection to WiFi or cellular networks. This excludes disconnecting manually.")
      /// Network management tool
      public static let title = L10n.tr("Localizable", "settings.hotspothelper.title", fallback: "Network management tool")
      public enum All {
        /// VPN WiFi Protection will activate on all networks, including trusted networks.
        public static let description = L10n.tr("Localizable", "settings.hotspothelper.all.description", fallback: "VPN WiFi Protection will activate on all networks, including trusted networks.")
        /// Protect all networks
        public static let title = L10n.tr("Localizable", "settings.hotspothelper.all.title", fallback: "Protect all networks")
      }
      public enum Available {
        /// To populate this list go to iOS Settings > WiFi.
        public static let help = L10n.tr("Localizable", "settings.hotspothelper.available.help", fallback: "To populate this list go to iOS Settings > WiFi.")
        public enum Add {
          /// Tap + to add to Trusted networks.
          public static let help = L10n.tr("Localizable", "settings.hotspothelper.available.add.help", fallback: "Tap + to add to Trusted networks.")
        }
      }
      public enum Cellular {
        /// PIA automatically enables the VPN when connecting to cellular networks if this option is enabled.
        public static let description = L10n.tr("Localizable", "settings.hotspothelper.cellular.description", fallback: "PIA automatically enables the VPN when connecting to cellular networks if this option is enabled.")
        /// Cellular networks
        public static let networks = L10n.tr("Localizable", "settings.hotspothelper.cellular.networks", fallback: "Cellular networks")
        /// Protect over cellular networks
        public static let title = L10n.tr("Localizable", "settings.hotspothelper.cellular.title", fallback: "Protect over cellular networks")
      }
      public enum Enable {
        /// PIA automatically enables the VPN when connecting to untrusted WiFi networks if this option is enabled.
        public static let description = L10n.tr("Localizable", "settings.hotspothelper.enable.description", fallback: "PIA automatically enables the VPN when connecting to untrusted WiFi networks if this option is enabled.")
      }
      public enum Rules {
        /// Rules
        public static let title = L10n.tr("Localizable", "settings.hotspothelper.rules.title", fallback: "Rules")
      }
      public enum Wifi {
        /// WiFi networks
        public static let networks = L10n.tr("Localizable", "settings.hotspothelper.wifi.networks", fallback: "WiFi networks")
        public enum Trust {
          /// VPN WiFi Protection
          public static let title = L10n.tr("Localizable", "settings.hotspothelper.wifi.trust.title", fallback: "VPN WiFi Protection")
        }
      }
    }
    public enum Log {
      /// Save debug logs which can be submitted to technical support to help troubleshoot problems.
      public static let information = L10n.tr("Localizable", "settings.log.information", fallback: "Save debug logs which can be submitted to technical support to help troubleshoot problems.")
      public enum Connected {
        /// A VPN connection is required. Please connect to the VPN and retry.
        public static let error = L10n.tr("Localizable", "settings.log.connected.error", fallback: "A VPN connection is required. Please connect to the VPN and retry.")
      }
    }
    public enum Nmt {
      public enum Killswitch {
        /// The VPN kill switch is currently disabled. In order to ensure that the Network Management Tool is functioning, and that you are able to reconnect when switching networks, please enable the VPN kill switch in your settings.
        public static let disabled = L10n.tr("Localizable", "settings.nmt.killswitch.disabled", fallback: "The VPN kill switch is currently disabled. In order to ensure that the Network Management Tool is functioning, and that you are able to reconnect when switching networks, please enable the VPN kill switch in your settings.")
      }
      public enum Optout {
        public enum Disconnect {
          /// Opt-out disconnect confirmation alert
          public static let alerts = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts", fallback: "Opt-out disconnect confirmation alert")
          public enum Alerts {
            /// Disables the warning alert when disconnecting from the VPN.
            public static let description = L10n.tr("Localizable", "settings.nmt.optout.disconnect.alerts.description", fallback: "Disables the warning alert when disconnecting from the VPN.")
          }
        }
      }
      public enum Wireguard {
        /// WireGuard® doesn't need to reconnect when you switch between different networks. It may be necessary to manually disconnect the VPN on trusted networks.
        public static let warning = L10n.tr("Localizable", "settings.nmt.wireguard.warning", fallback: "WireGuard® doesn't need to reconnect when you switch between different networks. It may be necessary to manually disconnect the VPN on trusted networks.")
      }
    }
    public enum Ovpn {
      public enum Migration {
        /// We are updating our OpenVPN implementation, for more information, click here
        public static let footer = L10n.tr("Localizable", "settings.ovpn.migration.footer", fallback: "We are updating our OpenVPN implementation, for more information, click here")
        public enum Footer {
          /// here
          public static let link = L10n.tr("Localizable", "settings.ovpn.migration.footer.link", fallback: "here")
        }
      }
    }
    public enum Preview {
      /// Preview
      public static let title = L10n.tr("Localizable", "settings.preview.title", fallback: "Preview")
    }
    public enum Reset {
      /// This will reset all of the above settings to default.
      public static let footer = L10n.tr("Localizable", "settings.reset.footer", fallback: "This will reset all of the above settings to default.")
      /// RESET
      public static let title = L10n.tr("Localizable", "settings.reset.title", fallback: "RESET")
      public enum Defaults {
        /// Reset settings to default
        public static let title = L10n.tr("Localizable", "settings.reset.defaults.title", fallback: "Reset settings to default")
        public enum Confirm {
          /// Reset
          public static let button = L10n.tr("Localizable", "settings.reset.defaults.confirm.button", fallback: "Reset")
          /// This will bring the app back to default. You will lose all changes you have made.
          public static let message = L10n.tr("Localizable", "settings.reset.defaults.confirm.message", fallback: "This will bring the app back to default. You will lose all changes you have made.")
          /// Reset settings
          public static let title = L10n.tr("Localizable", "settings.reset.defaults.confirm.title", fallback: "Reset settings")
        }
      }
    }
    public enum Section {
      /// Automation
      public static let automation = L10n.tr("Localizable", "settings.section.automation", fallback: "Automation")
      /// General
      public static let general = L10n.tr("Localizable", "settings.section.general", fallback: "General")
      /// Help
      public static let help = L10n.tr("Localizable", "settings.section.help", fallback: "Help")
      /// Network
      public static let network = L10n.tr("Localizable", "settings.section.network", fallback: "Network")
      /// Privacy Features
      public static let privacyFeatures = L10n.tr("Localizable", "settings.section.privacyFeatures", fallback: "Privacy Features")
      /// Protocols
      public static let protocols = L10n.tr("Localizable", "settings.section.protocols", fallback: "Protocols")
    }
    public enum Server {
      public enum Network {
        /// The VPN has to be disconnected to change the server network.
        public static let alert = L10n.tr("Localizable", "settings.server.network.alert", fallback: "The VPN has to be disconnected to change the server network.")
        /// Next generation network
        public static let description = L10n.tr("Localizable", "settings.server.network.description", fallback: "Next generation network")
      }
    }
    public enum Service {
      public enum Quality {
        public enum Share {
          /// Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.
          public static let description = L10n.tr("Localizable", "settings.service.quality.share.description", fallback: "Help us improve by sharing VPN connection statistics. These reports never contain personally identifiable information.")
          /// Find out more
          public static let findoutmore = L10n.tr("Localizable", "settings.service.quality.share.findoutmore", fallback: "Find out more")
          /// Help Improve PIA
          public static let title = L10n.tr("Localizable", "settings.service.quality.share.title", fallback: "Help Improve PIA")
        }
        public enum Show {
          /// Connection stats
          public static let title = L10n.tr("Localizable", "settings.service.quality.show.title", fallback: "Connection stats")
        }
      }
    }
    public enum Small {
      public enum Packets {
        /// Will slightly lower the IP packet size to improve compatibility with some routers and mobile networks.
        public static let description = L10n.tr("Localizable", "settings.small.packets.description", fallback: "Will slightly lower the IP packet size to improve compatibility with some routers and mobile networks.")
        /// Use Small Packets
        public static let title = L10n.tr("Localizable", "settings.small.packets.title", fallback: "Use Small Packets")
      }
    }
    public enum Trusted {
      public enum Networks {
        /// PIA won't automatically connect on these networks.
        public static let message = L10n.tr("Localizable", "settings.trusted.networks.message", fallback: "PIA won't automatically connect on these networks.")
        public enum Connect {
          /// Protect this network by connecting to VPN?
          public static let message = L10n.tr("Localizable", "settings.trusted.networks.connect.message", fallback: "Protect this network by connecting to VPN?")
        }
        public enum Sections {
          /// Available networks
          public static let available = L10n.tr("Localizable", "settings.trusted.networks.sections.available", fallback: "Available networks")
          /// Current network
          public static let current = L10n.tr("Localizable", "settings.trusted.networks.sections.current", fallback: "Current network")
          /// Trusted networks
          public static let trusted = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted", fallback: "Trusted networks")
          /// Untrusted networks
          public static let untrusted = L10n.tr("Localizable", "settings.trusted.networks.sections.untrusted", fallback: "Untrusted networks")
          public enum Trusted {
            public enum Rule {
              /// Disconnect from PIA VPN
              public static let action = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.action", fallback: "Disconnect from PIA VPN")
              /// Enable this feature, with the VPN kill switch enabled, to customize how PIA will behave on WiFi and cellular networks. Please be aware, functionality of the Network Management Tool will be disabled if you manually disconnect.
              public static let description = L10n.tr("Localizable", "settings.trusted.networks.sections.trusted.rule.description", fallback: "Enable this feature, with the VPN kill switch enabled, to customize how PIA will behave on WiFi and cellular networks. Please be aware, functionality of the Network Management Tool will be disabled if you manually disconnect.")
            }
          }
        }
      }
    }
  }
  public enum Shortcuts {
    /// Connect
    public static let connect = L10n.tr("Localizable", "shortcuts.connect", fallback: "Connect")
    /// Disconnect
    public static let disconnect = L10n.tr("Localizable", "shortcuts.disconnect", fallback: "Disconnect")
    /// Select a region
    public static let selectRegion = L10n.tr("Localizable", "shortcuts.select_region", fallback: "Select a region")
  }
  public enum Signup {
    public enum Failure {
      /// Internal app error (%d)
      public static func `internal`(_ p1: Int) -> String {
        return L10n.tr("Localizable", "signup.failure.internal", p1, fallback: "Internal app error (%d)")
      }
      /// We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.
      public static let message = L10n.tr("Localizable", "signup.failure.message", fallback: "We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.")
      /// GO BACK
      public static let submit = L10n.tr("Localizable", "signup.failure.submit", fallback: "GO BACK")
      /// Account creation failed
      public static let title = L10n.tr("Localizable", "signup.failure.title", fallback: "Account creation failed")
      /// Unknown error: %s (%d)
      public static func unknown(_ p1: UnsafePointer<CChar>, _ p2: Int) -> String {
        return L10n.tr("Localizable", "signup.failure.unknown", p1, p2, fallback: "Unknown error: %s (%d)")
      }
      /// Sign-up failed
      public static let vcTitle = L10n.tr("Localizable", "signup.failure.vc_title", fallback: "Sign-up failed")
      public enum Purchase {
        public enum Sandbox {
          /// The selected sandbox subscription is not available in production.
          public static let message = L10n.tr("Localizable", "signup.failure.purchase.sandbox.message", fallback: "The selected sandbox subscription is not available in production.")
        }
      }
      public enum Redeem {
        public enum Claimed {
          /// Looks like this card has already been claimed by another account. You can try entering a different PIN.
          public static let message = L10n.tr("Localizable", "signup.failure.redeem.claimed.message", fallback: "Looks like this card has already been claimed by another account. You can try entering a different PIN.")
          /// Card claimed already
          public static let title = L10n.tr("Localizable", "signup.failure.redeem.claimed.title", fallback: "Card claimed already")
        }
        public enum Invalid {
          /// Looks like you entered an invalid card PIN. Please try again.
          public static let message = L10n.tr("Localizable", "signup.failure.redeem.invalid.message", fallback: "Looks like you entered an invalid card PIN. Please try again.")
          /// Invalid card PIN
          public static let title = L10n.tr("Localizable", "signup.failure.redeem.invalid.title", fallback: "Invalid card PIN")
        }
      }
    }
    public enum InProgress {
      /// We're confirming your purchase with our system. It could take a moment so hang in there.
      public static let message = L10n.tr("Localizable", "signup.in_progress.message", fallback: "We're confirming your purchase with our system. It could take a moment so hang in there.")
      /// Confirm sign-up
      public static let title = L10n.tr("Localizable", "signup.in_progress.title", fallback: "Confirm sign-up")
      public enum Redeem {
        /// We're confirming your card PIN with our system. It could take a moment so hang in there.
        public static let message = L10n.tr("Localizable", "signup.in_progress.redeem.message", fallback: "We're confirming your card PIN with our system. It could take a moment so hang in there.")
      }
    }
    public enum Purchase {
      public enum Subscribe {
        /// Subscribe now
        public static let now = L10n.tr("Localizable", "signup.purchase.subscribe.now", fallback: "Subscribe now")
      }
      public enum Trials {
        /// Browse anonymously and hide your ip.
        public static let anonymous = L10n.tr("Localizable", "signup.purchase.trials.anonymous", fallback: "Browse anonymously and hide your ip.")
        /// Support 10 devices at once
        public static let devices = L10n.tr("Localizable", "signup.purchase.trials.devices", fallback: "Support 10 devices at once")
        /// Start your 7-day free trial
        public static let intro = L10n.tr("Localizable", "signup.purchase.trials.intro", fallback: "Start your 7-day free trial")
        /// Secure servers in 90+ countries
        public static let region = L10n.tr("Localizable", "signup.purchase.trials.region", fallback: "Secure servers in 90+ countries")
        /// More than 3300 servers in 32 countries
        public static let servers = L10n.tr("Localizable", "signup.purchase.trials.servers", fallback: "More than 3300 servers in 32 countries")
        /// Start subscription
        public static let start = L10n.tr("Localizable", "signup.purchase.trials.start", fallback: "Start subscription")
        public enum _1year {
          /// 1 year of privacy and identity protection
          public static let protection = L10n.tr("Localizable", "signup.purchase.trials.1year.protection", fallback: "1 year of privacy and identity protection")
        }
        public enum All {
          /// See all available plans
          public static let plans = L10n.tr("Localizable", "signup.purchase.trials.all.plans", fallback: "See all available plans")
        }
        public enum Devices {
          /// Protect yourself on up to 10 devices at a time.
          public static let description = L10n.tr("Localizable", "signup.purchase.trials.devices.description", fallback: "Protect yourself on up to 10 devices at a time.")
        }
        public enum Money {
          /// 30 day money back guarantee
          public static let back = L10n.tr("Localizable", "signup.purchase.trials.money.back", fallback: "30 day money back guarantee")
        }
        public enum Price {
          /// Then %@
          public static func after(_ p1: Any) -> String {
            return L10n.tr("Localizable", "signup.purchase.trials.price.after", String(describing: p1), fallback: "Then %@")
          }
        }
      }
      public enum Uncredited {
        public enum Alert {
          /// You have uncredited transactions. Do you want to recover your account details?
          public static let message = L10n.tr("Localizable", "signup.purchase.uncredited.alert.message", fallback: "You have uncredited transactions. Do you want to recover your account details?")
          public enum Button {
            /// Cancel
            public static let cancel = L10n.tr("Localizable", "signup.purchase.uncredited.alert.button.cancel", fallback: "Cancel")
            /// Recover account
            public static let recover = L10n.tr("Localizable", "signup.purchase.uncredited.alert.button.recover", fallback: "Recover account")
          }
        }
      }
    }
    public enum Share {
      public enum Data {
        public enum Buttons {
          /// Accept
          public static let accept = L10n.tr("Localizable", "signup.share.data.buttons.accept", fallback: "Accept")
          /// No, thanks
          public static let noThanks = L10n.tr("Localizable", "signup.share.data.buttons.noThanks", fallback: "No, thanks")
          /// Read more
          public static let readMore = L10n.tr("Localizable", "signup.share.data.buttons.readMore", fallback: "Read more")
        }
        public enum ReadMore {
          public enum Text {
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
            public static let description = L10n.tr("Localizable", "signup.share.data.readMore.text.description", fallback: "This minimal information assists us in identifying and fixing potential connection issues. Note that sharing this information requires consent and manual activation as it is turned off by default.\n\nWe will collect information about the following events:\n\n    - Connection Attempt\n    - Connection Canceled\n    - Connection Established\n\nFor all of these events, we will collect the following information:\n    - Platform\n    - App version\n    - App type (pre-release or not)\n    - Protocol used\n    - Connection source (manual or using automation)\n    - Time To Connect (time between connecting and connected state)\n\nAll events will contain a unique ID, which is randomly generated. This ID is not associated with your user account. This unique ID is re-generated daily for privacy purposes.\n\nYou will always be in control. You can see what data we’ve collected from Settings, and you can turn it off at any time.")
          }
        }
        public enum Text {
          /// To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information.
          public static let description = L10n.tr("Localizable", "signup.share.data.text.description", fallback: "To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information.")
          /// You can always control this from your settings
          public static let footer = L10n.tr("Localizable", "signup.share.data.text.footer", fallback: "You can always control this from your settings")
          /// Please help us improve our service
          public static let title = L10n.tr("Localizable", "signup.share.data.text.title", fallback: "Please help us improve our service")
        }
      }
    }
    public enum Success {
      /// Thank you for signing up with us. We have sent your account username and password at your email address at %@
      public static func messageFormat(_ p1: Any) -> String {
        return L10n.tr("Localizable", "signup.success.message_format", String(describing: p1), fallback: "Thank you for signing up with us. We have sent your account username and password at your email address at %@")
      }
      /// GET STARTED
      public static let submit = L10n.tr("Localizable", "signup.success.submit", fallback: "GET STARTED")
      /// Purchase complete
      public static let title = L10n.tr("Localizable", "signup.success.title", fallback: "Purchase complete")
      public enum Password {
        /// Password
        public static let caption = L10n.tr("Localizable", "signup.success.password.caption", fallback: "Password")
      }
      public enum Redeem {
        /// You will receive an email shortly with your username and password.
        /// 
        /// Your login details
        public static let message = L10n.tr("Localizable", "signup.success.redeem.message", fallback: "You will receive an email shortly with your username and password.\n\nYour login details")
        /// Card redeemed successfully
        public static let title = L10n.tr("Localizable", "signup.success.redeem.title", fallback: "Card redeemed successfully")
      }
      public enum Username {
        /// Username
        public static let caption = L10n.tr("Localizable", "signup.success.username.caption", fallback: "Username")
      }
    }
    public enum Unreachable {
      /// No internet connection found. Please confirm that you have an internet connection and hit retry below.
      /// 
      /// You can come back to the app later to finish the process.
      public static let message = L10n.tr("Localizable", "signup.unreachable.message", fallback: "No internet connection found. Please confirm that you have an internet connection and hit retry below.\n\nYou can come back to the app later to finish the process.")
      /// TRY AGAIN
      public static let submit = L10n.tr("Localizable", "signup.unreachable.submit", fallback: "TRY AGAIN")
      /// Whoops!
      public static let title = L10n.tr("Localizable", "signup.unreachable.title", fallback: "Whoops!")
      /// Error
      public static let vcTitle = L10n.tr("Localizable", "signup.unreachable.vc_title", fallback: "Error")
    }
    public enum Walkthrough {
      public enum Action {
        /// DONE
        public static let done = L10n.tr("Localizable", "signup.walkthrough.action.done", fallback: "DONE")
        /// NEXT
        public static let next = L10n.tr("Localizable", "signup.walkthrough.action.next", fallback: "NEXT")
        /// SKIP
        public static let skip = L10n.tr("Localizable", "signup.walkthrough.action.skip", fallback: "SKIP")
      }
      public enum Page {
        public enum _1 {
          /// Protect yourself on up to 10 devices at a time.
          public static let description = L10n.tr("Localizable", "signup.walkthrough.page.1.description", fallback: "Protect yourself on up to 10 devices at a time.")
          /// Support 10 devices at once
          public static let title = L10n.tr("Localizable", "signup.walkthrough.page.1.title", fallback: "Support 10 devices at once")
        }
        public enum _2 {
          /// With servers around the globe, you are always under protection.
          public static let description = L10n.tr("Localizable", "signup.walkthrough.page.2.description", fallback: "With servers around the globe, you are always under protection.")
          /// Secure servers in 90+ countries
          public static let title = L10n.tr("Localizable", "signup.walkthrough.page.2.title", fallback: "Secure servers in 90+ countries")
        }
        public enum _3 {
          /// Enabling our Content Blocker prevents ads from showing in Safari.
          public static let description = L10n.tr("Localizable", "signup.walkthrough.page.3.description", fallback: "Enabling our Content Blocker prevents ads from showing in Safari.")
          /// Protect yourself from ads
          public static let title = L10n.tr("Localizable", "signup.walkthrough.page.3.title", fallback: "Protect yourself from ads")
        }
      }
    }
  }
  public enum Siri {
    public enum Shortcuts {
      public enum Add {
        /// There was an error adding the Siri shortcut. Please, try it again.
        public static let error = L10n.tr("Localizable", "siri.shortcuts.add.error", fallback: "There was an error adding the Siri shortcut. Please, try it again.")
      }
      public enum Connect {
        /// Connect PIA VPN
        public static let title = L10n.tr("Localizable", "siri.shortcuts.connect.title", fallback: "Connect PIA VPN")
        public enum Row {
          /// 'Connect' Siri Shortcut
          public static let title = L10n.tr("Localizable", "siri.shortcuts.connect.row.title", fallback: "'Connect' Siri Shortcut")
        }
      }
      public enum Disconnect {
        /// Disconnect PIA VPN
        public static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.title", fallback: "Disconnect PIA VPN")
        public enum Row {
          /// 'Disconnect' Siri Shortcut
          public static let title = L10n.tr("Localizable", "siri.shortcuts.disconnect.row.title", fallback: "'Disconnect' Siri Shortcut")
        }
      }
    }
  }
  public enum Tiles {
    public enum Accessibility {
      public enum Invisible {
        public enum Tile {
          /// Tap to add this tile to the dashboard
          public static let action = L10n.tr("Localizable", "tiles.accessibility.invisible.tile.action", fallback: "Tap to add this tile to the dashboard")
        }
      }
      public enum Visible {
        public enum Tile {
          /// Tap to remove this tile from the dashboard
          public static let action = L10n.tr("Localizable", "tiles.accessibility.visible.tile.action", fallback: "Tap to remove this tile from the dashboard")
        }
      }
    }
    public enum Favorite {
      public enum Servers {
        /// Favorite servers
        public static let title = L10n.tr("Localizable", "tiles.favorite.servers.title", fallback: "Favorite servers")
      }
    }
    public enum Feedback {
      /// How are we doing?
      public static let title = L10n.tr("Localizable", "tiles.feedback.title", fallback: "How are we doing?")
    }
    public enum Nmt {
      /// Cellular
      public static let cellular = L10n.tr("Localizable", "tiles.nmt.cellular", fallback: "Cellular")
      public enum Accessibility {
        /// Trusted network
        public static let trusted = L10n.tr("Localizable", "tiles.nmt.accessibility.trusted", fallback: "Trusted network")
        /// Untrusted network
        public static let untrusted = L10n.tr("Localizable", "tiles.nmt.accessibility.untrusted", fallback: "Untrusted network")
      }
    }
    public enum Quick {
      public enum Connect {
        /// Quick connect
        public static let title = L10n.tr("Localizable", "tiles.quick.connect.title", fallback: "Quick connect")
      }
    }
    public enum Quicksetting {
      public enum Nmt {
        /// Network Management
        public static let title = L10n.tr("Localizable", "tiles.quicksetting.nmt.title", fallback: "Network Management")
      }
      public enum Private {
        public enum Browser {
          /// Private Browser
          public static let title = L10n.tr("Localizable", "tiles.quicksetting.private.browser.title", fallback: "Private Browser")
        }
      }
    }
    public enum Quicksettings {
      /// Quick settings
      public static let title = L10n.tr("Localizable", "tiles.quicksettings.title", fallback: "Quick settings")
      public enum Min {
        public enum Elements {
          /// You should keep at least one element visible in the Quick Settings Tile
          public static let message = L10n.tr("Localizable", "tiles.quicksettings.min.elements.message", fallback: "You should keep at least one element visible in the Quick Settings Tile")
        }
      }
    }
    public enum Region {
      /// VPN Server
      public static let title = L10n.tr("Localizable", "tiles.region.title", fallback: "VPN Server")
    }
    public enum Subscription {
      /// Monthly
      public static let monthly = L10n.tr("Localizable", "tiles.subscription.monthly", fallback: "Monthly")
      /// Subscription
      public static let title = L10n.tr("Localizable", "tiles.subscription.title", fallback: "Subscription")
      /// Trial
      public static let trial = L10n.tr("Localizable", "tiles.subscription.trial", fallback: "Trial")
      /// Yearly
      public static let yearly = L10n.tr("Localizable", "tiles.subscription.yearly", fallback: "Yearly")
      public enum Days {
        /// (%d days left)
        public static func `left`(_ p1: Int) -> String {
          return L10n.tr("Localizable", "tiles.subscription.days.left", p1, fallback: "(%d days left)")
        }
      }
    }
    public enum Usage {
      /// Download
      public static let download = L10n.tr("Localizable", "tiles.usage.download", fallback: "Download")
      /// Usage
      public static let title = L10n.tr("Localizable", "tiles.usage.title", fallback: "Usage")
      /// Upload
      public static let upload = L10n.tr("Localizable", "tiles.usage.upload", fallback: "Upload")
      public enum Ipsec {
        /// USAGE (Not available on IKEv2)
        public static let title = L10n.tr("Localizable", "tiles.usage.ipsec.title", fallback: "USAGE (Not available on IKEv2)")
      }
    }
  }
  public enum Today {
    public enum Widget {
      /// Login
      public static let login = L10n.tr("Localizable", "today.widget.login", fallback: "Login")
    }
  }
  public enum TopNavigationBar {
    public enum LocationItem {
      /// Location
      public static let title = L10n.tr("Localizable", "top_navigation_bar.location_item.title", fallback: "Location")
    }
    public enum LocationSelectionScreen {
      /// Location Selection
      public static let title = L10n.tr("Localizable", "top_navigation_bar.location_selection_screen.title", fallback: "Location Selection")
    }
    public enum VpnItem {
      /// PIA VPN
      public static let title = L10n.tr("Localizable", "top_navigation_bar.vpn_item.title", fallback: "PIA VPN")
    }
  }
  public enum Tvos {
    public enum Login {
      /// Enter your PIA VPN account details
      public static let title = L10n.tr("Localizable", "tvos.login.title", fallback: "Enter your PIA VPN account details")
      public enum Placeholder {
        /// Enter Password
        public static let password = L10n.tr("Localizable", "tvos.login.placeholder.password", fallback: "Enter Password")
        /// Enter Username
        public static let username = L10n.tr("Localizable", "tvos.login.placeholder.username", fallback: "Enter Username")
      }
      public enum Qr {
        /// Scan the QR Code, and validate the login from the PIA iOS app.
        public static let description = L10n.tr("Localizable", "tvos.login.qr.description", fallback: "Scan the QR Code, and validate the login from the PIA iOS app.")
        /// Other options:
        public static let options = L10n.tr("Localizable", "tvos.login.qr.options", fallback: "Other options:")
        /// The code will expire in:
        public static let timer = L10n.tr("Localizable", "tvos.login.qr.timer", fallback: "The code will expire in:")
        /// Sign in using the PIA app
        public static let title = L10n.tr("Localizable", "tvos.login.qr.title", fallback: "Sign in using the PIA app")
        public enum Button {
          /// Log In via Username
          public static let login = L10n.tr("Localizable", "tvos.login.qr.button.login", fallback: "Log In via Username")
          /// Restore Purchase
          public static let restore = L10n.tr("Localizable", "tvos.login.qr.button.restore", fallback: "Restore Purchase")
        }
        public enum Expired {
          /// Generate a new one below
          public static let description = L10n.tr("Localizable", "tvos.login.qr.expired.description", fallback: "Generate a new one below")
          /// QR Code has expired
          public static let title = L10n.tr("Localizable", "tvos.login.qr.expired.title", fallback: "QR Code has expired")
          public enum Button {
            /// Generate QR
            public static let generate = L10n.tr("Localizable", "tvos.login.qr.expired.button.generate", fallback: "Generate QR")
          }
        }
      }
    }
    public enum Signin {
      public enum Expired {
        /// Renew and regain full VPN protection while streaming.
        public static let subtitle = L10n.tr("Localizable", "tvos.signin.expired.subtitle", fallback: "Renew and regain full VPN protection while streaming.")
        /// Your subscription has expired
        public static let title = L10n.tr("Localizable", "tvos.signin.expired.title", fallback: "Your subscription has expired")
        public enum Button {
          /// I've Already Renewed
          public static let renewed = L10n.tr("Localizable", "tvos.signin.expired.button.renewed", fallback: "I've Already Renewed")
          /// Sign Out
          public static let signout = L10n.tr("Localizable", "tvos.signin.expired.button.signout", fallback: "Sign Out")
        }
        public enum Qr {
          /// Scan the QR code and choose your plan. Subscribing only takes a couple of minutes.
          public static let title1 = L10n.tr("Localizable", "tvos.signin.expired.qr.title1", fallback: "Scan the QR code and choose your plan. Subscribing only takes a couple of minutes.")
          /// Once done, return to your Apple TV and enjoy enhanced digital privacy with PIA!
          public static let title2 = L10n.tr("Localizable", "tvos.signin.expired.qr.title2", fallback: "Once done, return to your Apple TV and enjoy enhanced digital privacy with PIA!")
        }
        public enum Trial {
          /// If you enjoyed premium VPN protection, subscribe to PIA!
          public static let subtitle = L10n.tr("Localizable", "tvos.signin.expired.trial.subtitle", fallback: "If you enjoyed premium VPN protection, subscribe to PIA!")
          /// Your free trial has expired
          public static let title = L10n.tr("Localizable", "tvos.signin.expired.trial.title", fallback: "Your free trial has expired")
        }
      }
    }
    public enum Signup {
      /// Scan the QR Code and download the app to create a new account.
      public static let cta = L10n.tr("Localizable", "tvos.signup.cta", fallback: "Scan the QR Code and download the app to create a new account.")
      /// VPN servers in 91 countries
      public static let item1 = L10n.tr("Localizable", "tvos.signup.item1", fallback: "VPN servers in 91 countries")
      /// Blazing-fast speeds
      public static let item2 = L10n.tr("Localizable", "tvos.signup.item2", fallback: "Blazing-fast speeds")
      /// 24/7 customer support
      public static let item3 = L10n.tr("Localizable", "tvos.signup.item3", fallback: "24/7 customer support")
      /// Get Private Internet Access
      public static let title = L10n.tr("Localizable", "tvos.signup.title", fallback: "Get Private Internet Access")
      public enum Credentials {
        /// Success!
        public static let title = L10n.tr("Localizable", "tvos.signup.credentials.title", fallback: "Success!")
        public enum Details {
          /// Get Started
          public static let button = L10n.tr("Localizable", "tvos.signup.credentials.details.button", fallback: "Get Started")
          /// You will also receive an email shortly with your username and password.
          public static let subtitle = L10n.tr("Localizable", "tvos.signup.credentials.details.subtitle", fallback: "You will also receive an email shortly with your username and password.")
          /// Card redeemed sucessfully
          public static let title = L10n.tr("Localizable", "tvos.signup.credentials.details.title", fallback: "Card redeemed sucessfully")
        }
      }
      public enum Email {
        public enum Error {
          public enum Message {
            /// We're unable to create an account at this time. Please try again later
            public static let generic = L10n.tr("Localizable", "tvos.signup.email.error.message.generic", fallback: "We're unable to create an account at this time. Please try again later")
          }
        }
      }
      public enum Subscription {
        public enum Error {
          public enum Message {
            /// Something went wrong. Please try again.
            public static let generic = L10n.tr("Localizable", "tvos.signup.subscription.error.message.generic", fallback: "Something went wrong. Please try again.")
            /// Payment was cancelled. Please try again.
            public static let paymentCancelled = L10n.tr("Localizable", "tvos.signup.subscription.error.message.paymentCancelled", fallback: "Payment was cancelled. Please try again.")
          }
        }
        public enum Paywall {
          /// Start your 7 days free trial then %@ per year.
          public static func subtitle(_ p1: Any) -> String {
            return L10n.tr("Localizable", "tvos.signup.subscription.paywall.subtitle", String(describing: p1), fallback: "Start your 7 days free trial then %@ per year.")
          }
          public enum Button {
            /// Subscribe Now
            public static let subscribe = L10n.tr("Localizable", "tvos.signup.subscription.paywall.button.subscribe", fallback: "Subscribe Now")
          }
          public enum Price {
            /// BEST VALUE - FREE TRIAL
            public static let trial = L10n.tr("Localizable", "tvos.signup.subscription.paywall.price.trial", fallback: "BEST VALUE - FREE TRIAL")
            /// per year
            public static let year = L10n.tr("Localizable", "tvos.signup.subscription.paywall.price.year", fallback: "per year")
            public enum Month {
              /// /mo
              public static let simplified = L10n.tr("Localizable", "tvos.signup.subscription.paywall.price.month.simplified", fallback: "/mo")
            }
          }
        }
      }
      public enum TermsConditions {
        /// This Terms of Service Agreement ('Agreement') covers the scope of your use and access to the PIA Private Internet Access, Inc. ('PIA') website (“Site”) located at www.privateinternetaccess.com, virtual private networking ('VPN'), and PIA's services provided through the Site ('Service(s)'). By visiting the Site, purchasing a subscription, and/or using the Services, You ('You' or 'Subscriber') ('PIA' and 'Subscriber' collectively known as 'Parties') acknowledge that you have read the Agreement, fully understand the terms and agree to be bound by all of the terms of the Agreement.
        public static let description = L10n.tr("Localizable", "tvos.signup.terms_conditions.description", fallback: "This Terms of Service Agreement ('Agreement') covers the scope of your use and access to the PIA Private Internet Access, Inc. ('PIA') website (“Site”) located at www.privateinternetaccess.com, virtual private networking ('VPN'), and PIA's services provided through the Site ('Service(s)'). By visiting the Site, purchasing a subscription, and/or using the Services, You ('You' or 'Subscriber') ('PIA' and 'Subscriber' collectively known as 'Parties') acknowledge that you have read the Agreement, fully understand the terms and agree to be bound by all of the terms of the Agreement.")
        /// Terms and Conditions
        public static let title = L10n.tr("Localizable", "tvos.signup.terms_conditions.title", fallback: "Terms and Conditions")
        public enum QrCode {
          /// Scan the QR code to access the full terms and conditions policy on your device.
          public static let message = L10n.tr("Localizable", "tvos.signup.terms_conditions.qr_code.message", fallback: "Scan the QR code to access the full terms and conditions policy on your device.")
        }
      }
    }
    public enum Welcome {
      /// Fast & Secure VPN for Streaming
      public static let title = L10n.tr("Localizable", "tvos.welcome.title", fallback: "Fast & Secure VPN for Streaming")
      public enum Button {
        /// Log In
        public static let login = L10n.tr("Localizable", "tvos.welcome.button.login", fallback: "Log In")
        /// Sign Up
        public static let signup = L10n.tr("Localizable", "tvos.welcome.button.signup", fallback: "Sign Up")
      }
    }
  }
  public enum VpnPermission {
    /// PIA
    public static let title = L10n.tr("Localizable", "vpn_permission.title", fallback: "PIA")
    public enum Body {
      /// We don’t monitor, filter or log any network activity.
      public static let footer = L10n.tr("Localizable", "vpn_permission.body.footer", fallback: "We don’t monitor, filter or log any network activity.")
      /// You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.
      /// To proceed tap on “%@”.
      public static func subtitle(_ p1: Any) -> String {
        return L10n.tr("Localizable", "vpn_permission.body.subtitle", String(describing: p1), fallback: "You’ll see a prompt for PIA VPN and need to allow access to VPN configurations.\nTo proceed tap on “%@”.")
      }
      /// PIA needs access to your VPN profiles to secure your traffic
      public static let title = L10n.tr("Localizable", "vpn_permission.body.title", fallback: "PIA needs access to your VPN profiles to secure your traffic")
    }
    public enum Disallow {
      /// Contact
      public static let contact = L10n.tr("Localizable", "vpn_permission.disallow.contact", fallback: "Contact")
      public enum Message {
        /// We need this permission for the application to function.
        public static let basic = L10n.tr("Localizable", "vpn_permission.disallow.message.basic", fallback: "We need this permission for the application to function.")
        /// You can also get in touch with customer support if you need assistance.
        public static let support = L10n.tr("Localizable", "vpn_permission.disallow.message.support", fallback: "You can also get in touch with customer support if you need assistance.")
      }
    }
  }
  public enum Welcome {
    public enum Agreement {
      /// After the 7 days free trial this subscription automatically renews for %@ unless it is canceled at least 24 hours before the end of the trial period. Your Apple ID account will be charged for renewal within 24 hours before the end of the trial period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. 7-days trial offer is limited to one 7-days trial offer per user. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription. All prices include applicable local sales taxes.
      /// 
      /// Signing up constitutes acceptance of the $1 and the $2.
      public static func message(_ p1: Any) -> String {
        return L10n.tr("Localizable", "welcome.agreement.message", String(describing: p1), fallback: "After the 7 days free trial this subscription automatically renews for %@ unless it is canceled at least 24 hours before the end of the trial period. Your Apple ID account will be charged for renewal within 24 hours before the end of the trial period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. 7-days trial offer is limited to one 7-days trial offer per user. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription. All prices include applicable local sales taxes.\n\nSigning up constitutes acceptance of the $1 and the $2.")
      }
      public enum Message {
        /// Privacy Policy
        public static let privacy = L10n.tr("Localizable", "welcome.agreement.message.privacy", fallback: "Privacy Policy")
        /// Terms of Service
        public static let tos = L10n.tr("Localizable", "welcome.agreement.message.tos", fallback: "Terms of Service")
      }
      public enum Trials {
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
        public static let message = L10n.tr("Localizable", "welcome.agreement.trials.message", fallback: "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.\n\nCertain Paid Subscriptions may offer a free trial prior to charging your payment method. If you decide to unsubscribe from a Paid Subscription before we start charging your payment method, cancel the subscription at least 24 hours before the free trial ends.\n\nFree trials are only available to new users, and are at our sole discretion, and if you attempt to sign up for an additional free trial, you will be immediately charged with the standard Subscription Fee.\n\nWe reserve the right to revoke your free trial at any time.\n\nAny unused portion of your free trial period will be forfeited upon purchase of a subscription.\n\nSigning up constitutes acceptance of this terms and conditions.")
        /// Free trials terms and conditions
        public static let title = L10n.tr("Localizable", "welcome.agreement.trials.title", fallback: "Free trials terms and conditions")
        public enum Monthly {
          /// month
          public static let plan = L10n.tr("Localizable", "welcome.agreement.trials.monthly.plan", fallback: "month")
        }
        public enum Yearly {
          /// year
          public static let plan = L10n.tr("Localizable", "welcome.agreement.trials.yearly.plan", fallback: "year")
        }
      }
    }
    public enum Gdpr {
      public enum Accept {
        public enum Button {
          /// Agree and continue
          public static let title = L10n.tr("Localizable", "welcome.gdpr.accept.button.title", fallback: "Agree and continue")
        }
      }
      public enum Collect {
        public enum Data {
          /// E-mail Address for the purposes of account management and protection from abuse.
          public static let description = L10n.tr("Localizable", "welcome.gdpr.collect.data.description", fallback: "E-mail Address for the purposes of account management and protection from abuse.")
          /// Personal information we collect
          public static let title = L10n.tr("Localizable", "welcome.gdpr.collect.data.title", fallback: "Personal information we collect")
        }
      }
      public enum Usage {
        public enum Data {
          /// E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.
          public static let description = L10n.tr("Localizable", "welcome.gdpr.usage.data.description", fallback: "E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.")
          /// Uses of personal information collected by us
          public static let title = L10n.tr("Localizable", "welcome.gdpr.usage.data.title", fallback: "Uses of personal information collected by us")
        }
      }
    }
    public enum Getstarted {
      public enum Buttons {
        /// Buy account
        public static let buyaccount = L10n.tr("Localizable", "welcome.getstarted.buttons.buyaccount", fallback: "Buy account")
      }
    }
    public enum Iap {
      public enum Error {
        /// Error
        public static let title = L10n.tr("Localizable", "welcome.iap.error.title", fallback: "Error")
        public enum Message {
          /// Apple servers currently unavailable. Please try again later.
          public static let unavailable = L10n.tr("Localizable", "welcome.iap.error.message.unavailable", fallback: "Apple servers currently unavailable. Please try again later.")
        }
      }
    }
    public enum Login {
      /// LOGIN
      public static let submit = L10n.tr("Localizable", "welcome.login.submit", fallback: "LOGIN")
      /// Sign in to your account
      public static let title = L10n.tr("Localizable", "welcome.login.title", fallback: "Sign in to your account")
      public enum Error {
        /// Too many failed login attempts with this username. Please try again after %@ second(s).
        public static func throttled(_ p1: Any) -> String {
          return L10n.tr("Localizable", "welcome.login.error.throttled", String(describing: p1), fallback: "Too many failed login attempts with this username. Please try again after %@ second(s).")
        }
        /// Log in
        public static let title = L10n.tr("Localizable", "welcome.login.error.title", fallback: "Log in")
        /// Your username or password is incorrect.
        public static let unauthorized = L10n.tr("Localizable", "welcome.login.error.unauthorized", fallback: "Your username or password is incorrect.")
        /// You must enter a username and password.
        public static let validation = L10n.tr("Localizable", "welcome.login.error.validation", fallback: "You must enter a username and password.")
      }
      public enum Magic {
        public enum Link {
          /// Please check your e-mail for a login link.
          public static let response = L10n.tr("Localizable", "welcome.login.magic.link.response", fallback: "Please check your e-mail for a login link.")
          /// Send Link
          public static let send = L10n.tr("Localizable", "welcome.login.magic.link.send", fallback: "Send Link")
          /// Login using magic email link
          public static let title = L10n.tr("Localizable", "welcome.login.magic.link.title", fallback: "Login using magic email link")
          public enum Invalid {
            /// Invalid email. Please try again.
            public static let email = L10n.tr("Localizable", "welcome.login.magic.link.invalid.email", fallback: "Invalid email. Please try again.")
          }
        }
      }
      public enum Password {
        /// Password
        public static let placeholder = L10n.tr("Localizable", "welcome.login.password.placeholder", fallback: "Password")
      }
      public enum Receipt {
        /// Login using purchase receipt
        public static let button = L10n.tr("Localizable", "welcome.login.receipt.button", fallback: "Login using purchase receipt")
      }
      public enum Restore {
        /// Didn't receive account details?
        public static let button = L10n.tr("Localizable", "welcome.login.restore.button", fallback: "Didn't receive account details?")
      }
      public enum Username {
        /// Username (p1234567)
        public static let placeholder = L10n.tr("Localizable", "welcome.login.username.placeholder", fallback: "Username (p1234567)")
      }
    }
    public enum Plan {
      /// Best value
      public static let bestValue = L10n.tr("Localizable", "welcome.plan.best_value", fallback: "Best value")
      /// %@/mo
      public static func priceFormat(_ p1: Any) -> String {
        return L10n.tr("Localizable", "welcome.plan.price_format", String(describing: p1), fallback: "%@/mo")
      }
      public enum Accessibility {
        /// per month
        public static let perMonth = L10n.tr("Localizable", "welcome.plan.accessibility.per_month", fallback: "per month")
      }
      public enum Monthly {
        /// Monthly
        public static let title = L10n.tr("Localizable", "welcome.plan.monthly.title", fallback: "Monthly")
      }
      public enum Yearly {
        /// %@%@ per year
        public static func detailFormat(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Localizable", "welcome.plan.yearly.detail_format", String(describing: p1), String(describing: p2), fallback: "%@%@ per year")
        }
        /// Yearly
        public static let title = L10n.tr("Localizable", "welcome.plan.yearly.title", fallback: "Yearly")
      }
    }
    public enum Purchase {
      /// Continue
      public static let `continue` = L10n.tr("Localizable", "welcome.purchase.continue", fallback: "Continue")
      /// or
      public static let or = L10n.tr("Localizable", "welcome.purchase.or", fallback: "or")
      /// Submit
      public static let submit = L10n.tr("Localizable", "welcome.purchase.submit", fallback: "Submit")
      /// 30-day money back guarantee
      public static let subtitle = L10n.tr("Localizable", "welcome.purchase.subtitle", fallback: "30-day money back guarantee")
      /// Select a VPN plan
      public static let title = L10n.tr("Localizable", "welcome.purchase.title", fallback: "Select a VPN plan")
      public enum Confirm {
        /// You are purchasing the %@ plan
        public static func plan(_ p1: Any) -> String {
          return L10n.tr("Localizable", "welcome.purchase.confirm.plan", String(describing: p1), fallback: "You are purchasing the %@ plan")
        }
        public enum Form {
          /// Enter your email address
          public static let email = L10n.tr("Localizable", "welcome.purchase.confirm.form.email", fallback: "Enter your email address")
        }
      }
      public enum Email {
        /// Email address
        public static let placeholder = L10n.tr("Localizable", "welcome.purchase.email.placeholder", fallback: "Email address")
        /// We need your email to send your username and password.
        public static let why = L10n.tr("Localizable", "welcome.purchase.email.why", fallback: "We need your email to send your username and password.")
      }
      public enum Error {
        /// Purchase
        public static let title = L10n.tr("Localizable", "welcome.purchase.error.title", fallback: "Purchase")
        /// You must enter an email address.
        public static let validation = L10n.tr("Localizable", "welcome.purchase.error.validation", fallback: "You must enter an email address.")
        public enum Connectivity {
          /// We are unable to reach Private Internet Access. This may due to poor internet or our service is blocked in your country.
          public static let description = L10n.tr("Localizable", "welcome.purchase.error.connectivity.description", fallback: "We are unable to reach Private Internet Access. This may due to poor internet or our service is blocked in your country.")
          /// Connection Failure
          public static let title = L10n.tr("Localizable", "welcome.purchase.error.connectivity.title", fallback: "Connection Failure")
        }
      }
      public enum Login {
        /// Sign in
        public static let button = L10n.tr("Localizable", "welcome.purchase.login.button", fallback: "Sign in")
        /// Already have an account?
        public static let footer = L10n.tr("Localizable", "welcome.purchase.login.footer", fallback: "Already have an account?")
      }
    }
    public enum Redeem {
      /// SUBMIT
      public static let submit = L10n.tr("Localizable", "welcome.redeem.submit", fallback: "SUBMIT")
      /// Type in your email address and the %lu digit PIN from your gift card or trial card below.
      public static func subtitle(_ p1: Int) -> String {
        return L10n.tr("Localizable", "welcome.redeem.subtitle", p1, fallback: "Type in your email address and the %lu digit PIN from your gift card or trial card below.")
      }
      /// Redeem gift card
      public static let title = L10n.tr("Localizable", "welcome.redeem.title", fallback: "Redeem gift card")
      public enum Accessibility {
        /// Back
        public static let back = L10n.tr("Localizable", "welcome.redeem.accessibility.back", fallback: "Back")
      }
      public enum Email {
        /// Email address
        public static let placeholder = L10n.tr("Localizable", "welcome.redeem.email.placeholder", fallback: "Email address")
      }
      public enum Error {
        /// Please type in your email and card PIN.
        public static let allfields = L10n.tr("Localizable", "welcome.redeem.error.allfields", fallback: "Please type in your email and card PIN.")
        /// Code must be %lu numeric digits.
        public static func code(_ p1: Int) -> String {
          return L10n.tr("Localizable", "welcome.redeem.error.code", p1, fallback: "Code must be %lu numeric digits.")
        }
        /// Redeem
        public static let title = L10n.tr("Localizable", "welcome.redeem.error.title", fallback: "Redeem")
      }
      public enum Giftcard {
        /// Gift card PIN
        public static let placeholder = L10n.tr("Localizable", "welcome.redeem.giftcard.placeholder", fallback: "Gift card PIN")
      }
    }
    public enum Restore {
      /// CONFIRM
      public static let submit = L10n.tr("Localizable", "welcome.restore.submit", fallback: "CONFIRM")
      /// If you purchased a plan through this app and didn't receive your credentials, you can send them again from here. You will not be charged during this process.
      public static let subtitle = L10n.tr("Localizable", "welcome.restore.subtitle", fallback: "If you purchased a plan through this app and didn't receive your credentials, you can send them again from here. You will not be charged during this process.")
      /// Restore uncredited purchase
      public static let title = L10n.tr("Localizable", "welcome.restore.title", fallback: "Restore uncredited purchase")
      public enum Email {
        /// Email address
        public static let placeholder = L10n.tr("Localizable", "welcome.restore.email.placeholder", fallback: "Email address")
      }
    }
    public enum Update {
      public enum Account {
        public enum Email {
          /// Failed to modify account email
          public static let error = L10n.tr("Localizable", "welcome.update.account.email.error", fallback: "Failed to modify account email")
        }
      }
    }
    public enum Upgrade {
      /// Welcome Back!
      public static let header = L10n.tr("Localizable", "welcome.upgrade.header", fallback: "Welcome Back!")
      /// In order to use Private Internet Access, you’ll need to renew your subscription.
      public static let title = L10n.tr("Localizable", "welcome.upgrade.title", fallback: "In order to use Private Internet Access, you’ll need to renew your subscription.")
      public enum Renew {
        /// Renew now
        public static let now = L10n.tr("Localizable", "welcome.upgrade.renew.now", fallback: "Renew now")
      }
    }
  }
  public enum Widget {
    public enum LiveActivity {
      public enum Region {
        /// Region
        public static let title = L10n.tr("Localizable", "widget.liveActivity.region.title", fallback: "Region")
      }
      public enum SelectedProtocol {
        /// Protocol
        public static let title = L10n.tr("Localizable", "widget.liveActivity.selected_protocol.title", fallback: "Protocol")
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
