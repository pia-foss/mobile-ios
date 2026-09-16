import PIALibrary
import PIAUIKit
import SwiftUI
import UIKit

class PromoOfferTile: UIView, Tileable {
    var view: UIView!
    var detailSegueIdentifier: String!
    var status: TileStatus = .normal {
        didSet { statusUpdated() }
    }

    private var hostingController: UIHostingController<PromoOfferBannerView>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        let bannerView = PromoOfferBannerView(
            data: PromoOfferBannerState.shared.bannerData,
            onShowDetails: { [weak self] in self?.showOfferDetails() },
            onDismiss: PromoOfferBannerState.shared.dismiss
        )
        let hostingController = UIHostingController(rootView: bannerView)

        guard let hostedView = hostingController.view else { return }

        self.hostingController = hostingController

        addSubview(hostedView)

        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: topAnchor),
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.view = hostedView

        Theme.current.applyPrincipalBackground(self)
        self.accessibilityIdentifier = "PromoOfferTile"
    }

    /// The tile is built inside a cell before it has an owning view controller, so the hosting
    /// controller can only be parented once the cell reaches a window.
    ///
    /// Left unparented it still draws and still takes taps, but anything that needs a controller —
    /// presenting, safe-area propagation, trait updates — silently does nothing.
    override func didMoveToWindow() {
        super.didMoveToWindow()

        guard let hostingController, hostingController.parent == nil,
            let parent = owningViewController
        else { return }

        parent.addChild(hostingController)
        hostingController.didMove(toParent: parent)
    }

    private func statusUpdated() {}

    /// The sheet states the terms, and is the only place the purchase can start.
    private func showOfferDetails() {
        guard let presenter = owningViewController ?? window?.rootViewController else { return }
        PromoOfferSheetHostingController.present(from: presenter)
    }
}

private extension UIResponder {
    /// The nearest view controller up the responder chain.
    ///
    /// A storyboard hands the tile to a cell without assigning it a view controller, so the chain is
    /// the only route to the dashboard — and it behaves the same on iOS, iPadOS and Mac Catalyst.
    var owningViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let controller = current as? UIViewController {
                return controller
            }
            responder = current.next
        }
        return nil
    }
}
