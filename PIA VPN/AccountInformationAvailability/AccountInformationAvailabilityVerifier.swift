//
//  AccountInformationVerifier.swift
//  PIA VPN
//
//  Created by Laura S on 4/25/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

protocol AccountInformationAvailabilityVerifierType {
    typealias Completion = (() -> Void)?
    func verifyAccountInformationAvailabity(after deadline: TimeInterval?, completion: Completion)
    func verifyAccountInformationAvailabity(after deadline: TimeInterval?) async
    
}

class AccountInformationAvailabilityVerifier:
    AccountInformationAvailabilityVerifierType {
    
    private let accountProvider: AccountProviderType
    private let notificationCenter: NotificationCenterType
    private let userDefaults: UserDefaultsType
    
    internal static let defaultDeadlineInSeconds: TimeInterval = 43200
    static let kAccountInfoAvailabilityDate = "kAccountInfoAvailabilityDate"

    init(accountProvider: AccountProviderType, notificationCenter: NotificationCenterType, userDefaults: UserDefaultsType) {
        self.accountProvider = accountProvider
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
    }
    
    private func shouldVerify(after deadline: TimeInterval) -> Bool {
        
        guard let previouslyVerified = userDefaults.date(forKey: Self.kAccountInfoAvailabilityDate),
              let verifiedSecondsAgo = previouslyVerified.timeIntervalSince1970.timeUntilNow() else { return true }
        
        return verifiedSecondsAgo >= deadline

    }
    
    func verifyAccountInformationAvailabity(after deadline: TimeInterval?, completion: Completion) {
        
        guard let deadline else {
            verify(with: completion)
            return
        }
        
        if shouldVerify(after: deadline) {
            verify(with: completion)
        } else {
            completion?()
        }

    }
    
    func verifyAccountInformationAvailabity(after deadline: TimeInterval?) async {
        return await withCheckedContinuation { continuation in
            self.verifyAccountInformationAvailabity(after: deadline) {
                continuation.resume()
            }
        }
    }
    
}

extension AccountInformationAvailabilityVerifier {
    private func verify(with completion: Completion) {
        accountProvider.accountInformation { [weak self] info, error in
            if let clientError = error as? ClientError,
               clientError == ClientError.unauthorized {
                self?.notificationCenter.post(name: .PIAUnauthorized, object: nil)
                completion?()
            } else {
                self?.userDefaults.set(date: Date(), forKey: Self.kAccountInfoAvailabilityDate)
                completion?()
            }
            
        }
        
    }
}
