//
//  DedicatedIPViewModel.swift
//  PIA VPN
//
//  Created by Mario on 30/03/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
//

import Combine
import Foundation
import PIAAssetsMobile
import PIALibrary
import PIALocalizations

private let log = PIALogger.logger(for: DedicatedIPViewModel.self)

final class DedicatedIPViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var dedicatedIp: ServerType?
    @Published var token: String = ""

    private var timeToRetryDIP: TimeInterval? = nil

    private let getDedicatedIp: GetDedicatedIpUseCaseType
    private let activateDIPToken: ActivateDIPTokenUseCaseType
    private let removeDIPToken: RemoveDIPUseCaseType

    init(
        getDedicatedIp: GetDedicatedIpUseCaseType,
        activateDIPToken: ActivateDIPTokenUseCaseType,
        removeDIPToken: RemoveDIPUseCaseType
    ) {
        self.getDedicatedIp = getDedicatedIp
        self.activateDIPToken = activateDIPToken
        self.removeDIPToken = removeDIPToken
    }

    @MainActor
    func load() async {
        isLoading = true
        dedicatedIp = getDedicatedIp()
        isLoading = false
    }

    @MainActor
    func activate() async {
        if let timeToRetry = timeToRetryDIP {
            let timeUntilNextTry = timeToRetry - Date().timeIntervalSince1970
            if timeUntilNextTry > 0 {
                Macros.displayImageNote(
                    withImage: Asset.iconWarning.image,
                    message: L10n.Dedicated.Ip.Message.Error.retryafter("\(Int(timeUntilNextTry))"),
                    andDuration: timeUntilNextTry
                )
                return
            }
            timeToRetryDIP = nil
        }

        guard !token.isEmpty else {
            Macros.displayStickyNote(
                withMessage: L10n.Dedicated.Ip.Message.Incorrect.token,
                andImage: Asset.iconWarning.image
            )
            return
        }

        isLoading = true
        let result = await activateDIPToken(token: token)
        isLoading = false

        switch result {
        case .success:
            Macros.displaySuccessImageNote(
                withImage: Asset.iconWarning.image,
                message: L10n.Dedicated.Ip.Message.Valid.token
            )
            token = ""
            await load()

        case .failure(.expired):
            log.error("Activate DIP token failed with expired token error.")
            Macros.displayStickyNote(
                withMessage: L10n.Dedicated.Ip.Message.Expired.token,
                andImage: Asset.iconWarning.image
            )

        case .failure(.invalid):
            log.error("Activate DIP token failed with invalid token error.")
            Macros.displayStickyNote(
                withMessage: L10n.Dedicated.Ip.Message.Invalid.token,
                andImage: Asset.iconWarning.image
            )

        case let .failure(.generic(error)):
            handleActivationError(error)
        }

        Macros.postNotification(.DedicatedIpReload)
        Macros.postNotification(.PIAThemeDidChange)
    }

    @MainActor
    func deactivate() async {
        isLoading = true
        do {
            try await removeDIPToken()
        } catch {
            log.error("Failed to remove DIP token:\(error)")
        }
        isLoading = false
        await load()
        Macros.postNotification(.PIAThemeDidChange)
    }

    private func handleActivationError(_ error: Error?) {
        guard let error else {
            Macros.displayStickyNote(
                withMessage: L10n.Dedicated.Ip.Message.Invalid.token,
                andImage: Asset.iconWarning.image
            )
            return
        }

        switch error {
        case ClientError.unauthorized:
            log.error("Activate DIP token failed with unauthorized error. Logging out...")
            Client.providers.accountProvider.logout(nil)
            Macros.postNotification(.PIAUnauthorized)
        case ClientError.throttled(let retryAfter):
            let retryAfterSeconds = Double(retryAfter)
            let message = L10n.Dedicated.Ip.Message.Error.retryafter("\(Int(retryAfter))")
            Macros.displayImageNote(
                withImage: Asset.iconWarning.image,
                message: NSLocalizedString(message, comment: message),
                andDuration: retryAfterSeconds
            )
            timeToRetryDIP = Date().timeIntervalSince1970 + retryAfterSeconds
        default:
            Macros.displayStickyNote(
                withMessage: L10n.Dedicated.Ip.Message.Invalid.token,
                andImage: Asset.iconWarning.image
            )
        }
    }
}
