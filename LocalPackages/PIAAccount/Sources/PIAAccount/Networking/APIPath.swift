import Foundation

/// API endpoint paths
enum APIPath: String, Sendable {
    case login = "/api/client/v5/api_token"
    case vpnToken = "/api/client/v5/vpn_token"
    case refreshAPIToken = "/api/client/v5/refresh"
    case signup = "/api/client/signup"
    case setEmail = "/api/client/account"
    case loginLink = "/api/client/v2/login_link"
    case logout = "/api/client/v2/expire_token"
    case accountDetails = "/api/client/v2/account"
    case deleteAccount = "/api/client/v5/account"
    case clientStatus = "/api/client/status"
    case invites = "/api/client/invites"
    case redeem = "/api/client/giftcard_redeem"
    case refreshToken = "/api/client/v4/refresh"
    case messages = "/api/client/v2/messages"
    case dedicatedIP = "/api/client/v2/dedicated_ip"
    case renewDedicatedIP = "/api/client/v2/check_renew_dip"
    case iosPayment = "/api/client/payment"
    case iosSubscriptions = "/api/client/ios"
    case iosFeatureFlag = "/clients/desktop/ios-flags"
    case validateQR = "/api/client/v5/login_token/auth"
    case supportedDedicatedIPCountries = "/api/client/v5/dip_regions"
    case getDedicatedIP = "/api/client/v5/redeem_dip_token"

    /// Returns the subdomain for this API path
    var subdomain: String {
        switch self {
        case .login, .vpnToken, .refreshAPIToken, .validateQR, .supportedDedicatedIPCountries, .getDedicatedIP:
            return "apiv5"
        case .loginLink, .logout, .accountDetails, .messages, .dedicatedIP, .renewDedicatedIP:
            return "apiv2"
        case .deleteAccount:
            return "apiv5"
        case .refreshToken:
            return "apiv4"
        case .signup, .setEmail, .clientStatus, .invites, .redeem, .iosPayment, .iosSubscriptions, .iosFeatureFlag:
            return "api"
        }
    }
}
