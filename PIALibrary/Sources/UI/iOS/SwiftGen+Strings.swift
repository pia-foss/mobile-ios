// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
enum L10n {
  enum Welcome {

    enum Agreement {
      /// Signing up constitutes acceptance of the $1 and the $2.
      static let message = L10n.tr("Welcome", "agreement.message")

      enum Message {
        /// Privacy Policy
        static let privacy = L10n.tr("Welcome", "agreement.message.privacy")
        /// Terms of Service
        static let tos = L10n.tr("Welcome", "agreement.message.tos")
      }
    }

    enum Iap {

      enum Error {
        /// Error
        static let title = L10n.tr("Welcome", "iap.error.title")

        enum Message {
          /// Apple servers currently unavailable. Please try again later.
          static let unavailable = L10n.tr("Welcome", "iap.error.message.unavailable")
        }
      }
    }

    enum Login {
      /// LOGIN
      static let submit = L10n.tr("Welcome", "login.submit")
      /// Sign in to your account
      static let title = L10n.tr("Welcome", "login.title")

      enum Error {
        /// Too many failed login attempts with this username. Please try again later.
        static let throttled = L10n.tr("Welcome", "login.error.throttled")
        /// Log in
        static let title = L10n.tr("Welcome", "login.error.title")
        /// Your username or password is incorrect.
        static let unauthorized = L10n.tr("Welcome", "login.error.unauthorized")
        /// You must enter an username and password.
        static let validation = L10n.tr("Welcome", "login.error.validation")
      }

      enum Password {
        /// Password
        static let placeholder = L10n.tr("Welcome", "login.password.placeholder")
      }

      enum Purchase {
        /// Buy now!
        static let button = L10n.tr("Welcome", "login.purchase.button")
        /// Don’t have an account?
        static let footer = L10n.tr("Welcome", "login.purchase.footer")
      }

      enum Restore {
        /// Couldn't get your plan?
        static let button = L10n.tr("Welcome", "login.restore.button")
      }

      enum Username {
        /// Username (p1234567)
        static let placeholder = L10n.tr("Welcome", "login.username.placeholder")
      }
    }

    enum Plan {
      /// Best value
      static let bestValue = L10n.tr("Welcome", "plan.best_value")
      /// %@/mo
      static func priceFormat(_ p1: String) -> String {
        return L10n.tr("Welcome", "plan.price_format", p1)
      }

      enum Accessibility {
        /// per month
        static let perMonth = L10n.tr("Welcome", "plan.accessibility.per_month")
      }

      enum Monthly {
        /// Monthly
        static let title = L10n.tr("Welcome", "plan.monthly.title")
      }

      enum Yearly {
        /// %@%@ per year
        static func detailFormat(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Welcome", "plan.yearly.detail_format", p1, p2)
        }
        /// Yearly
        static let title = L10n.tr("Welcome", "plan.yearly.title")
      }
    }

    enum Purchase {
      /// BUY NOW
      static let submit = L10n.tr("Welcome", "purchase.submit")
      /// 7-day money back guarantee
      static let subtitle = L10n.tr("Welcome", "purchase.subtitle")
      /// Select a VPN plan
      static let title = L10n.tr("Welcome", "purchase.title")

      enum Email {
        /// Email address
        static let placeholder = L10n.tr("Welcome", "purchase.email.placeholder")
      }

      enum Error {
        /// Purchase
        static let title = L10n.tr("Welcome", "purchase.error.title")
        /// You must enter an email address.
        static let validation = L10n.tr("Welcome", "purchase.error.validation")
      }

      enum Login {
        /// Sign in!
        static let button = L10n.tr("Welcome", "purchase.login.button")
        /// Already have an account?
        static let footer = L10n.tr("Welcome", "purchase.login.footer")
      }
    }

    enum Redeem {
      /// SUBMIT
      static let submit = L10n.tr("Welcome", "redeem.submit")
      /// Type in your email address and the 16 digit PIN from your gift card or trial card below.
      static let subtitle = L10n.tr("Welcome", "redeem.subtitle")
      /// Redeem gift card
      static let title = L10n.tr("Welcome", "redeem.title")

      enum Code {
        /// 1234-5678-9012-3456
        static let placeholder = L10n.tr("Welcome", "redeem.code.placeholder")
      }

      enum Email {
        /// Email address
        static let placeholder = L10n.tr("Welcome", "redeem.email.placeholder")
      }

      enum Error {
        /// Code must be 16 numeric digits.
        static let code = L10n.tr("Welcome", "redeem.error.code")
        /// Redeem
        static let title = L10n.tr("Welcome", "redeem.error.title")
      }
    }

    enum Restore {
      /// CONFIRM
      static let submit = L10n.tr("Welcome", "restore.submit")
      /// If you purchased a plan through this app and didn't receive your credentials, you can send them again from here.\nYou will not be charged during this process.
      static let subtitle = L10n.tr("Welcome", "restore.subtitle")
      /// Restore uncredited purchase
      static let title = L10n.tr("Welcome", "restore.title")

      enum Email {
        /// Email address
        static let placeholder = L10n.tr("Welcome", "restore.email.placeholder")
      }
    }
  }
  enum Ui {

    enum Global {
      /// Cancel
      static let cancel = L10n.tr("UI", "global.cancel")
      /// Close
      static let close = L10n.tr("UI", "global.close")
      /// OK
      static let ok = L10n.tr("UI", "global.ok")

      enum Version {
        /// Version %@ (%@)
        static func format(_ p1: String, _ p2: String) -> String {
          return L10n.tr("UI", "global.version.format", p1, p2)
        }
      }
    }
  }
  enum Signup {

    enum Failure {
      /// We're unable to create an account at this time. Please try again later. Reopening the app will re-attempt to create an account.
      static let message = L10n.tr("Signup", "failure.message")
      /// GO BACK
      static let submit = L10n.tr("Signup", "failure.submit")
      /// Account creation failed
      static let title = L10n.tr("Signup", "failure.title")
      /// Sign-up failed
      static let vcTitle = L10n.tr("Signup", "failure.vc_title")

      enum Redeem {

        enum Claimed {
          /// Looks like this card has already been claimed by another account. You can try entering a different PIN.
          static let message = L10n.tr("Signup", "failure.redeem.claimed.message")
          /// Card claimed already
          static let title = L10n.tr("Signup", "failure.redeem.claimed.title")
        }

        enum Invalid {
          /// Looks like you entered an invalid card PIN. Please try again.
          static let message = L10n.tr("Signup", "failure.redeem.invalid.message")
          /// Invalid card PIN
          static let title = L10n.tr("Signup", "failure.redeem.invalid.title")
        }
      }
    }

    enum InProgress {
      /// We're confirming your purchase with our system. It could take a moment so hang in there.
      static let message = L10n.tr("Signup", "in_progress.message")
      /// Confirm sign-up
      static let title = L10n.tr("Signup", "in_progress.title")

      enum Redeem {
        /// We're confirming your card PIN with our system. It could take a moment so hang in there.
        static let message = L10n.tr("Signup", "in_progress.redeem.message")
      }
    }

    enum Success {
      /// Thank you for signing up with us. We have sent your account username and password at your email address at %@
      static func messageFormat(_ p1: String) -> String {
        return L10n.tr("Signup", "success.message_format", p1)
      }
      /// GET STARTED
      static let submit = L10n.tr("Signup", "success.submit")
      /// Purchase complete
      static let title = L10n.tr("Signup", "success.title")

      enum Password {
        /// Password
        static let caption = L10n.tr("Signup", "success.password.caption")
      }

      enum Redeem {
        /// You will receive an email shortly with your username and password.
        static let message = L10n.tr("Signup", "success.redeem.message")
        /// Completed!
        static let title = L10n.tr("Signup", "success.redeem.title")
      }

      enum Username {
        /// Username
        static let caption = L10n.tr("Signup", "success.username.caption")
      }
    }

    enum Unreachable {
      /// No internet connection found. Please confirm that you have an internet connection and hit retry below.\n\nYou can come back to the app later to finish the process.
      static let message = L10n.tr("Signup", "unreachable.message")
      /// TRY AGAIN
      static let submit = L10n.tr("Signup", "unreachable.submit")
      /// Whoops!
      static let title = L10n.tr("Signup", "unreachable.title")
      /// Error
      static let vcTitle = L10n.tr("Signup", "unreachable.vc_title")
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
