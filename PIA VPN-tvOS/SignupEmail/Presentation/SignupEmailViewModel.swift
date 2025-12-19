//
//  SignupEmailViewModel.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 27/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import PIALibrary

class SignupEmailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var shouldShowErrorMessage = false
    var errorMessage: String?
    
    private let signupUseCase: SignupUseCaseType
    private let transaction: InAppTransaction?
    private let onSuccessAction: (UserAccount) -> Void
    
    init(signupUseCase: SignupUseCaseType, transaction: InAppTransaction?, onSuccessAction: @escaping (UserAccount) -> Void) {
        self.signupUseCase = signupUseCase
        self.transaction = transaction
        self.onSuccessAction = onSuccessAction
    }
    
    func signup(email: String) {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try Validator.validate(email: cleanedEmail)
        } catch {
            handleError(error: error)
            return
        }
        
        isLoading = true
        Task {
            do {
                let userAccount = try await signupUseCase(email: email, transaction: transaction)
                Task { @MainActor in
                    isLoading = false
                    onSuccessAction(userAccount)
                }
            } catch {
                Task { @MainActor in
                    isLoading = false
                    handleError(error: error)
                }
            }
        }
    }

    private func handleError(error: Validator.EmailValidationError) {
        errorMessage = error.errorMessage
        shouldShowErrorMessage = true
    }
    
    private func handleError(error: Error) {
        errorMessage = L10n.Localizable.Tvos.Signup.Email.Error.Message.generic
        shouldShowErrorMessage = true
    }
}
