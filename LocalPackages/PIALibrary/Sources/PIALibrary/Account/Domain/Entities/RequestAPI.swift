

import Foundation


enum RequestAPI {
    enum Path: String {
        case login = "/api/client/v5/api_token"
        case vpnToken = "/api/client/v5/vpn_token" //refreshes the vpn token
        case refreshApiToken = "/api/client/v5/refresh"
        case signup = "/api/client/signup"
        case setEmail = "/api/client/account"
        case loginLink = "/api/client/v2/login_link"
        case logout = "/api/client/v2/expire_token"
        case accountDetails = "/api/client/v2/account"
        case deleteAccount = "/api/client/v5/account"
        // TODO: Exclude proxy endpoints when performing this request (clientStatus)
        case clientStatus = "/api/client/status"
        case invites = "/api/client/invites"
        case redeem = "/api/client/giftcard_redeem"
        case refreshToken = "/api/client/v4/refresh" //TODO: check if this refreshToken is actually in use
        case messages = "/api/client/v2/messages"
        case dedicatedIp = "/api/client/v2/dedicated_ip"
        case renewDedicatedIp = "/api/client/v2/check_renew_dip"
        case iosPayment = "/api/client/payment"
        case iosSubscriptions = "/api/client/ios"
        case iosFeatureFlag = "/clients/desktop/ios-flags"
        case generateQR = "/api/client/v5/login_token"
    }
    
    static func subdomain(for path: RequestAPI.Path) -> String {
        switch path {
        case .login:
            return "apiv5"
        case .vpnToken:
            return "apiv5"
        case .refreshApiToken:
            return "apiv5"
        case .signup:
            return "api"
        case .setEmail:
            return "api"
        case .loginLink:
            return "apiv2"
        case .logout:
            return "apiv2"
        case .accountDetails:
            return "apiv2"
        case .deleteAccount:
            return "apiv5"
        case .clientStatus:
            return "api"
        case .invites:
            return "api"
        case .redeem:
            return "api"
        case .refreshToken:
            return "apiv4"
        case .messages:
            return "apiv2"
        case .dedicatedIp:
            return "apiv2"
        case .renewDedicatedIp:
            return "apiv2"
        case .iosPayment:
            return "api"
        case .iosSubscriptions:
            return "api"
        case .iosFeatureFlag:
            return "api"
        case .generateQR:
            return "apiv5"
        }
    }
}
