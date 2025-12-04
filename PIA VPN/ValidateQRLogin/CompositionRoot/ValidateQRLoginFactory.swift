//
//  ValidateQRLoginFactory.swift
//  PIA VPN
//
//  Created by Said Rehouni on 19/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary
import UIKit

class ValidateQRLoginFactory {
    static func makeValidateQRLoginViewController(apiToken: String, tvOSBindToken: String) -> ValidateQRLoginViewController? {
        let storyboard = UIStoryboard(name: "ValidateQRLoginView", bundle: .main)
        let viewController = storyboard.instantiateInitialViewController() as? ValidateQRLoginViewController
        
        viewController?.validateQRLogin = makeValidateQRLoginUseCase(apiToken: apiToken, tvOSBindToken: tvOSBindToken)
        
        return viewController
    }
    
    static private func makeValidateQRLoginUseCase(apiToken: String, tvOSBindToken: String) -> ValidateQRLoginUseCase {
        ValidateQRLoginUseCase(apiToken: apiToken,
                               tvOSBindToken: tvOSBindToken,
                               loginProvider: makeLoginProvider(),
                               tokenProvider: Client.configuration)
    }
    
    static private func makeLoginProvider() -> LoginProviderType {
        LoginProvider(httpClient: URLSessionHTTPClient(), urlRequestMaker: LoginURLRequestMaker())
    }
}

extension Client.Configuration: TokenProvider {
    func removeTVOSToken() {
        tvOSBindToken = nil
    }
}
