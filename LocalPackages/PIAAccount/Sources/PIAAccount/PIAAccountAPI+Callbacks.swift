import Foundation

// MARK: - Callback-Based Extensions

/// Callback wrappers for non-async code compatibility
public extension PIAAccountAPI {
    // MARK: - Authentication

    func loginWithReceipt(
        receiptBase64: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await loginWithReceipt(receiptBase64: receiptBase64)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func loginLink(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await loginLink(email: email)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func migrateApiToken(
        apiToken: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await migrateApiToken(apiToken: apiToken)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Account Management

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                try await deleteAccount()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func clientStatus(completion: @escaping (Result<ClientStatusInformation, Error>) -> Void) {
        Task {
            do {
                let result = try await clientStatus()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Email Management

    func setEmail(
        email: String,
        resetPassword: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await setEmail(email: email, resetPassword: resetPassword)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func setEmail(
        username: String,
        password: String,
        email: String,
        resetPassword: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await setEmail(username: username, password: password, email: email, resetPassword: resetPassword)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Dedicated IP

    func dedicatedIPs(
        ipTokens: [String],
        completion: @escaping (Result<[DedicatedIPInformation], Error>) -> Void
    ) {
        Task {
            do {
                let result = try await dedicatedIPs(ipTokens: ipTokens)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func renewDedicatedIP(
        ipToken: String,
        completion: @escaping (Result<DedicatedIPInformation, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await renewDedicatedIP(ipToken: ipToken)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Subscriptions (iOS)

    func subscriptions(
        receipt: String,
        completion: @escaping (Result<IOSSubscriptionInformation, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await subscriptions(receipt: receipt)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Payment (iOS)

    func payment(
        username: String,
        password: String,
        information: IOSPaymentInformation,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await payment(username: username, password: password, information: information)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Sign Up

    func signUp(
        information: IOSSignupInformation,
        completion: @escaping (Result<SignUpInformation, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await signUp(information: information)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Social

    func sendInvite(
        email: String,
        name: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await sendInvite(email: email, name: name)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func invitesDetails(completion: @escaping (Result<InvitesDetailsInformation, Error>) -> Void) {
        Task {
            do {
                let result = try await invitesDetails()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Promotions

    func redeem(
        email: String,
        code: String,
        completion: @escaping (Result<RedeemInformation, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await redeem(email: email, code: code)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Feature Management

    func message(
        appVersion: String,
        completion: @escaping (Result<MessageInformation, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await message(appVersion: appVersion)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func featureFlags(completion: @escaping (Result<FeatureFlagsInformation, Error>) -> Void) {
        Task {
            do {
                let result = try await featureFlags()
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
