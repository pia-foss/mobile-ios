//
//  ClientError+Localization.swift
//  
//
//  Created by Juan Docal on 2022-08-11.
//

import Foundation
import PIALibrary

extension ClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .sandboxPurchase:
            return NSLocalizedString(L10n.Signup.Failure.Purchase.Sandbox.message,
                                     comment: L10n.Signup.Failure.Purchase.Sandbox.message)
        default:
            return nil
        }
    }
}
