//
//  PromoOfferSheetPresenter.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
//

import Logging
import PIALibrary
import PIALocalizations
import SwiftUI
import UIKit

private let log = PIALogger.logger(for: PromoOfferSheetHost.self)

/// Owns the presentation animation and the purchase in flight, which keeps `PromoOfferDetailsSheet`
/// a pure function of its inputs.
@MainActor
struct PromoOfferSheetHost: View {
    /// Called once the dismissal animation has finished, so the host controller can be torn down.
    var onFinished: () -> Void = {}

    private let state = PromoOfferBannerState.shared

    /// Matches the container's spring, so the controller outlives the exit animation.
    private static let exitDuration: TimeInterval = 0.35

    @State private var isPresented = false
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        PromoOfferSheetContainer(isPresented: isPresented, onDismiss: close) {
            if let data = state.bannerData {
                PromoOfferDetailsSheet(
                    data: data,
                    isPurchasing: isPurchasing,
                    errorMessage: errorMessage,
                    onClaim: claim
                )
            }
        }
        .onAppear {
            isPresented = true
            // The backend contract asks us to sign while the offer is displayed, so the sign
            // round-trip is not paid inside the user's tap.
            state.prepare()
        }
    }

    private func claim() {
        errorMessage = nil
        isPurchasing = true

        Task {
            do {
                try await state.claimOffer()
                close()
            } catch {
                log.error("Claiming the promotional offer failed: \(error.localizedDescription)")
                // Kept on the sheet rather than dismissing: the user asked for the offer, so they
                // need to know they did not get it. `ServiceError`'s own messages are developer
                // text, so only these localized ones reach the user.
                if let message = Self.message(for: error) {
                    errorMessage = message
                } else {
                    close()
                }
            }
            isPurchasing = false
        }
    }

    /// The message to show for a failed claim, or `nil` when the user caused it themselves and needs
    /// no telling — cancelling the App Store sheet just closes ours.
    private static func message(for error: Error) -> String? {
        guard case PromoOffersService.ServiceError.purchase(let clientError) = error else {
            return L10n.PromoOffer.Sheet.error
        }

        switch clientError {
        case .userCancelled: return nil
        case .purchasePending: return L10n.Signup.Failure.Purchase.Pending.message
        case .sandboxPurchase: return L10n.Signup.Failure.Purchase.Sandbox.message
        default: return L10n.PromoOffer.Sheet.error
        }
    }

    /// Closing the sheet leaves the banner in place — only its own dismiss button retires the offer.
    private func close() {
        guard isPresented else { return }
        isPresented = false

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.exitDuration, execute: onFinished)
    }
}

/// Hosts `PromoOfferSheetHost` over the presenting screen.
///
/// `.overFullScreen` with a clear background because the sheet draws its own backdrop and animates
/// itself in; a UIKit transition on top would play two animations for one presentation.
@MainActor
final class PromoOfferSheetHostingController: UIHostingController<PromoOfferSheetHost> {
    init() {
        super.init(rootView: PromoOfferSheetHost())

        modalPresentationStyle = .overFullScreen
        view.backgroundColor = .clear
        rootView.onFinished = { [weak self] in
            self?.dismiss(animated: false)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Presents over `presenting`, or over whatever it already has on screen: presenting on a
    /// controller that is already presenting silently does nothing.
    static func present(from presenting: UIViewController) {
        var target = presenting
        while let presented = target.presentedViewController, !presented.isBeingDismissed {
            target = presented
        }

        target.present(PromoOfferSheetHostingController(), animated: false)
    }
}
