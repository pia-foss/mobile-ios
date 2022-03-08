// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Signup {
    internal enum Failure {
      /// We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.
      internal static let message = L10n.tr("Signup", "failure.message")
      /// GO BACK
      internal static let submit = L10n.tr("Signup", "failure.submit")
      /// Account creation failed
      internal static let title = L10n.tr("Signup", "failure.title")
      /// Sign-up failed
      internal static let vcTitle = L10n.tr("Signup", "failure.vc_title")
      internal enum Purchase {
        internal enum Sandbox {
          /// The selected sandbox subscription is not available in production.
          internal static let message = L10n.tr("Signup", "failure.purchase.sandbox.message")
        }
      }
      internal enum Redeem {
        internal enum Claimed {
          /// Looks like this card has already been claimed by another account. You can try entering a different PIN.
          internal static let message = L10n.tr("Signup", "failure.redeem.claimed.message")
          /// Card claimed already
          internal static let title = L10n.tr("Signup", "failure.redeem.claimed.title")
        }
        internal enum Invalid {
          /// Looks like you entered an invalid card PIN. Please try again.
          internal static let message = L10n.tr("Signup", "failure.redeem.invalid.message")
          /// Invalid card PIN
          internal static let title = L10n.tr("Signup", "failure.redeem.invalid.title")
        }
      }
    }
    internal enum InProgress {
      /// We're confirming your purchase with our system. It could take a moment so hang in there.
      internal static let message = L10n.tr("Signup", "in_progress.message")
      /// Confirm sign-up
      internal static let title = L10n.tr("Signup", "in_progress.title")
      internal enum Redeem {
        /// We're confirming your card PIN with our system. It could take a moment so hang in there.
        internal static let message = L10n.tr("Signup", "in_progress.redeem.message")
      }
    }
    internal enum Purchase {
      internal enum Subscribe {
        /// Subscribe now
        internal static let now = L10n.tr("Signup", "purchase.subscribe.now")
      }
      internal enum Trials {
        /// Browse anonymously and hide your ip.
        internal static let anonymous = L10n.tr("Signup", "purchase.trials.anonymous")
        /// Support 10 devices at once
        internal static let devices = L10n.tr("Signup", "purchase.trials.devices")
        /// Start your 7-day free trial
        internal static let intro = L10n.tr("Signup", "purchase.trials.intro")
        /// Connect to any region easily
        internal static let region = L10n.tr("Signup", "purchase.trials.region")
        /// More than 3300 servers in 32 countries
        internal static let servers = L10n.tr("Signup", "purchase.trials.servers")
        /// Start subscription
        internal static let start = L10n.tr("Signup", "purchase.trials.start")
        internal enum _1year {
          /// 1 year of privacy and identity protection
          internal static let protection = L10n.tr("Signup", "purchase.trials.1year.protection")
        }
        internal enum All {
          /// See all available plans
          internal static let plans = L10n.tr("Signup", "purchase.trials.all.plans")
        }
        internal enum Devices {
          /// Protect yourself on up to 10 devices at a time.
          internal static let description = L10n.tr("Signup", "purchase.trials.devices.description")
        }
        internal enum Money {
          /// 30 day money back guarantee
          internal static let back = L10n.tr("Signup", "purchase.trials.money.back")
        }
        internal enum Price {
          /// Then %@
          internal static func after(_ p1: Any) -> String {
            return L10n.tr("Signup", "purchase.trials.price.after", String(describing: p1))
          }
        }
      }
      internal enum Uncredited {
        internal enum Alert {
          /// You have uncredited transactions. Do you want to recover your account details?
          internal static let message = L10n.tr("Signup", "purchase.uncredited.alert.message")
          internal enum Button {
            /// Cancel
            internal static let cancel = L10n.tr("Signup", "purchase.uncredited.alert.button.cancel")
            /// Recover account
            internal static let recover = L10n.tr("Signup", "purchase.uncredited.alert.button.recover")
          }
        }
      }
    }
    internal enum Share {
      internal enum Data {
        internal enum Buttons {
          /// Accept
          internal static let accept = L10n.tr("Signup", "share.data.buttons.accept")
          /// No, thanks
          internal static let noThanks = L10n.tr("Signup", "share.data.buttons.noThanks")
          /// Read more
          internal static let readMore = L10n.tr("Signup", "share.data.buttons.readMore")
        }
        internal enum ReadMore {
          internal enum Text {
            /// This minimal information assists us in identifying and fixing potential connection issues. Note that sharing this information requires consent and manual activation as it is turned off by default.\n\nWe will collect information about the following events:\n\n    - Connection Attempt\n    - Connection Canceled\n    - Connection Established\n\nFor all of these events, we will collect the following information:\n    - Platform\n    - App version\n    - App type (pre-release or not)\n    - Protocol used\n    - Connection source (manual or using automation)\n\nAll events will contain a unique ID, which is randomly generated. This ID is not associated with your user account. This unique ID is re-generated daily for privacy purposes.\n\nYou will always be in control. You can see what data we’ve collected from Settings, and you can turn it off at any time.
            internal static let description = L10n.tr("Signup", "share.data.readMore.text.description")
          }
        }
        internal enum Text {
          /// To help us ensure our service's connection performance, you can anonymously share your connection stats with us. These reports do not include any personally identifiable information.
          internal static let description = L10n.tr("Signup", "share.data.text.description")
          /// You can always control this from your settings
          internal static let footer = L10n.tr("Signup", "share.data.text.footer")
          /// Please help us improve our service
          internal static let title = L10n.tr("Signup", "share.data.text.title")
        }
      }
    }
    internal enum Success {
      /// Thank you for signing up with us. We have sent your account username and password at your email address at %@
      internal static func messageFormat(_ p1: Any) -> String {
        return L10n.tr("Signup", "success.message_format", String(describing: p1))
      }
      /// GET STARTED
      internal static let submit = L10n.tr("Signup", "success.submit")
      /// Purchase complete
      internal static let title = L10n.tr("Signup", "success.title")
      internal enum Password {
        /// Password
        internal static let caption = L10n.tr("Signup", "success.password.caption")
      }
      internal enum Redeem {
        /// You will receive an email shortly with your username and password.\n\nYour login details
        internal static let message = L10n.tr("Signup", "success.redeem.message")
        /// Card redeemed successfully
        internal static let title = L10n.tr("Signup", "success.redeem.title")
      }
      internal enum Username {
        /// Username
        internal static let caption = L10n.tr("Signup", "success.username.caption")
      }
    }
    internal enum Unreachable {
      /// No internet connection found. Please confirm that you have an internet connection and hit retry below.\n\nYou can come back to the app later to finish the process.
      internal static let message = L10n.tr("Signup", "unreachable.message")
      /// TRY AGAIN
      internal static let submit = L10n.tr("Signup", "unreachable.submit")
      /// Whoops!
      internal static let title = L10n.tr("Signup", "unreachable.title")
      /// Error
      internal static let vcTitle = L10n.tr("Signup", "unreachable.vc_title")
    }
    internal enum Walkthrough {
      internal enum Action {
        /// DONE
        internal static let done = L10n.tr("Signup", "walkthrough.action.done")
        /// NEXT
        internal static let next = L10n.tr("Signup", "walkthrough.action.next")
        /// SKIP
        internal static let skip = L10n.tr("Signup", "walkthrough.action.skip")
      }
      internal enum Page {
        internal enum _1 {
          /// Protect yourself on up to 10 devices at a time.
          internal static let description = L10n.tr("Signup", "walkthrough.page.1.description")
          /// Support 10 devices at once
          internal static let title = L10n.tr("Signup", "walkthrough.page.1.title")
        }
        internal enum _2 {
          /// With servers around the globe, you are always under protection.
          internal static let description = L10n.tr("Signup", "walkthrough.page.2.description")
          /// Connect to any region easily
          internal static let title = L10n.tr("Signup", "walkthrough.page.2.title")
        }
        internal enum _3 {
          /// Enabling our Content Blocker prevents ads from showing in Safari.
          internal static let description = L10n.tr("Signup", "walkthrough.page.3.description")
          /// Protect yourself from ads
          internal static let title = L10n.tr("Signup", "walkthrough.page.3.title")
        }
      }
    }
  }
  internal enum Ui {
    internal enum Global {
      /// Cancel
      internal static let cancel = L10n.tr("UI", "global.cancel")
      /// Close
      internal static let close = L10n.tr("UI", "global.close")
      /// OK
      internal static let ok = L10n.tr("UI", "global.ok")
      internal enum Version {
        /// Version %@ (%@)
        internal static func format(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("UI", "global.version.format", String(describing: p1), String(describing: p2))
        }
      }
    }
  }
  internal enum Welcome {
    internal enum Agreement {
      /// After the 7 days free trial this subscription automatically renews for %@ unless it is canceled at least 24 hours before the end of the trial period. Your Apple ID account will be charged for renewal within 24 hours before the end of the trial period. You can manage and cancel your subscriptions by going to your App Store account settings after purchase. 7-days trial offer is limited to one 7-days trial offer per user. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription. All prices include applicable local sales taxes.\n\nSigning up constitutes acceptance of the $1 and the $2.
      internal static func message(_ p1: Any) -> String {
        return L10n.tr("Welcome", "agreement.message", String(describing: p1))
      }
      internal enum Message {
        /// Privacy Policy
        internal static let privacy = L10n.tr("Welcome", "agreement.message.privacy")
        /// Terms of Service
        internal static let tos = L10n.tr("Welcome", "agreement.message.tos")
      }
      internal enum Trials {
        /// Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase.\n\nCertain Paid Subscriptions may offer a free trial prior to charging your payment method. If you decide to unsubscribe from a Paid Subscription before we start charging your payment method, cancel the subscription at least 24 hours before the free trial ends.\n\nFree trials are only available to new users, and are at our sole discretion, and if you attempt to sign up for an additional free trial, you will be immediately charged with the standard Subscription Fee.\n\nWe reserve the right to revoke your free trial at any time.\n\nAny unused portion of your free trial period will be forfeited upon purchase of a subscription.\n\nSigning up constitutes acceptance of this terms and conditions.
        internal static let message = L10n.tr("Welcome", "agreement.trials.message")
        /// Free trials terms and conditions
        internal static let title = L10n.tr("Welcome", "agreement.trials.title")
        internal enum Monthly {
          /// month
          internal static let plan = L10n.tr("Welcome", "agreement.trials.monthly.plan")
        }
        internal enum Yearly {
          /// year
          internal static let plan = L10n.tr("Welcome", "agreement.trials.yearly.plan")
        }
      }
    }
    internal enum Gdpr {
      internal enum Accept {
        internal enum Button {
          /// Agree and continue
          internal static let title = L10n.tr("Welcome", "gdpr.accept.button.title")
        }
      }
      internal enum Collect {
        internal enum Data {
          /// E-mail Address for the purposes of account management and protection from abuse.
          internal static let description = L10n.tr("Welcome", "gdpr.collect.data.description")
          /// Personal information we collect
          internal static let title = L10n.tr("Welcome", "gdpr.collect.data.title")
        }
      }
      internal enum Usage {
        internal enum Data {
          /// E-mail address is used to send subscription information, payment confirmations, customer correspondence, and Private Internet Access promotional offers only.
          internal static let description = L10n.tr("Welcome", "gdpr.usage.data.description")
          /// Uses of personal information collected by us
          internal static let title = L10n.tr("Welcome", "gdpr.usage.data.title")
        }
      }
    }
    internal enum Getstarted {
      internal enum Buttons {
        /// Buy account
        internal static let buyaccount = L10n.tr("Welcome", "getstarted.buttons.buyaccount")
      }
    }
    internal enum Iap {
      internal enum Error {
        /// Error
        internal static let title = L10n.tr("Welcome", "iap.error.title")
        internal enum Message {
          /// Apple servers currently unavailable. Please try again later.
          internal static let unavailable = L10n.tr("Welcome", "iap.error.message.unavailable")
        }
      }
    }
    internal enum Login {
      /// LOGIN
      internal static let submit = L10n.tr("Welcome", "login.submit")
      /// Sign in to your account
      internal static let title = L10n.tr("Welcome", "login.title")
      internal enum Error {
        /// Too many failed login attempts with this username. Please try again after %@ second(s).
        internal static func throttled(_ p1: Any) -> String {
          return L10n.tr("Welcome", "login.error.throttled", String(describing: p1))
        }
        /// Log in
        internal static let title = L10n.tr("Welcome", "login.error.title")
        /// Your username or password is incorrect.
        internal static let unauthorized = L10n.tr("Welcome", "login.error.unauthorized")
        /// You must enter a username and password.
        internal static let validation = L10n.tr("Welcome", "login.error.validation")
      }
      internal enum Magic {
        internal enum Link {
          /// Please check your e-mail for a login link.
          internal static let response = L10n.tr("Welcome", "login.magic.link.response")
          /// Send Link
          internal static let send = L10n.tr("Welcome", "login.magic.link.send")
          /// Login using magic email link
          internal static let title = L10n.tr("Welcome", "login.magic.link.title")
          internal enum Invalid {
            /// Invalid email. Please try again.
            internal static let email = L10n.tr("Welcome", "login.magic.link.invalid.email")
          }
        }
      }
      internal enum Password {
        /// Password
        internal static let placeholder = L10n.tr("Welcome", "login.password.placeholder")
      }
      internal enum Receipt {
        /// Login using purchase receipt
        internal static let button = L10n.tr("Welcome", "login.receipt.button")
      }
      internal enum Restore {
        /// Didn't receive account details?
        internal static let button = L10n.tr("Welcome", "login.restore.button")
      }
      internal enum Username {
        /// Username (p1234567)
        internal static let placeholder = L10n.tr("Welcome", "login.username.placeholder")
      }
    }
    internal enum Plan {
      /// Best value
      internal static let bestValue = L10n.tr("Welcome", "plan.best_value")
      /// %@/mo
      internal static func priceFormat(_ p1: Any) -> String {
        return L10n.tr("Welcome", "plan.price_format", String(describing: p1))
      }
      internal enum Accessibility {
        /// per month
        internal static let perMonth = L10n.tr("Welcome", "plan.accessibility.per_month")
      }
      internal enum Monthly {
        /// Monthly
        internal static let title = L10n.tr("Welcome", "plan.monthly.title")
      }
      internal enum Yearly {
        /// %@%@ per year
        internal static func detailFormat(_ p1: Any, _ p2: Any) -> String {
          return L10n.tr("Welcome", "plan.yearly.detail_format", String(describing: p1), String(describing: p2))
        }
        /// Yearly
        internal static let title = L10n.tr("Welcome", "plan.yearly.title")
      }
    }
    internal enum Purchase {
      /// Continue
      internal static let `continue` = L10n.tr("Welcome", "purchase.continue")
      /// or
      internal static let or = L10n.tr("Welcome", "purchase.or")
      /// Submit
      internal static let submit = L10n.tr("Welcome", "purchase.submit")
      /// 30-day money back guarantee
      internal static let subtitle = L10n.tr("Welcome", "purchase.subtitle")
      /// Select a VPN plan
      internal static let title = L10n.tr("Welcome", "purchase.title")
      internal enum Confirm {
        /// You are purchasing the %@ plan
        internal static func plan(_ p1: Any) -> String {
          return L10n.tr("Welcome", "purchase.confirm.plan", String(describing: p1))
        }
        internal enum Form {
          /// Enter your email address
          internal static let email = L10n.tr("Welcome", "purchase.confirm.form.email")
        }
      }
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "purchase.email.placeholder")
        /// We need your email to send your username and password.
        internal static let why = L10n.tr("Welcome", "purchase.email.why")
      }
      internal enum Error {
        /// Purchase
        internal static let title = L10n.tr("Welcome", "purchase.error.title")
        /// You must enter an email address.
        internal static let validation = L10n.tr("Welcome", "purchase.error.validation")
        internal enum Connectivity {
          /// We are unable to reach Private Internet Access. This may due to poor internet or our service is blocked in your country.
          internal static let description = L10n.tr("Welcome", "purchase.error.connectivity.description")
          /// Connection Failure
          internal static let title = L10n.tr("Welcome", "purchase.error.connectivity.title")
        }
      }
      internal enum Login {
        /// Sign in
        internal static let button = L10n.tr("Welcome", "purchase.login.button")
        /// Already have an account?
        internal static let footer = L10n.tr("Welcome", "purchase.login.footer")
      }
    }
    internal enum Redeem {
      /// SUBMIT
      internal static let submit = L10n.tr("Welcome", "redeem.submit")
      /// Type in your email address and the %lu digit PIN from your gift card or trial card below.
      internal static func subtitle(_ p1: Int) -> String {
        return L10n.tr("Welcome", "redeem.subtitle", p1)
      }
      /// Redeem gift card
      internal static let title = L10n.tr("Welcome", "redeem.title")
      internal enum Accessibility {
        /// Back
        internal static let back = L10n.tr("Welcome", "redeem.accessibility.back")
      }
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "redeem.email.placeholder")
      }
      internal enum Error {
        /// Please type in your email and card PIN.
        internal static let allfields = L10n.tr("Welcome", "redeem.error.allfields")
        /// Code must be %lu numeric digits.
        internal static func code(_ p1: Int) -> String {
          return L10n.tr("Welcome", "redeem.error.code", p1)
        }
        /// Redeem
        internal static let title = L10n.tr("Welcome", "redeem.error.title")
      }
      internal enum Giftcard {
        /// Gift card PIN
        internal static let placeholder = L10n.tr("Welcome", "redeem.giftcard.placeholder")
      }
    }
    internal enum Restore {
      /// CONFIRM
      internal static let submit = L10n.tr("Welcome", "restore.submit")
      /// If you purchased a plan through this app and didn't receive your credentials, you can send them again from here. You will not be charged during this process.
      internal static let subtitle = L10n.tr("Welcome", "restore.subtitle")
      /// Restore uncredited purchase
      internal static let title = L10n.tr("Welcome", "restore.title")
      internal enum Email {
        /// Email address
        internal static let placeholder = L10n.tr("Welcome", "restore.email.placeholder")
      }
    }
    internal enum Update {
      internal enum Account {
        internal enum Email {
          /// Failed to modify account email
          internal static let error = L10n.tr("Welcome", "update.account.email.error")
        }
      }
    }
    internal enum Upgrade {
      /// Welcome Back!
      internal static let header = L10n.tr("Welcome", "upgrade.header")
      /// In order to use Private Internet Access, you’ll need to renew your subscription.
      internal static let title = L10n.tr("Welcome", "upgrade.title")
      internal enum Renew {
        /// Renew now
        internal static let now = L10n.tr("Welcome", "upgrade.renew.now")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
