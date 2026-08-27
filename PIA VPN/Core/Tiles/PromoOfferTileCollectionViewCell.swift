import PIALibrary
import PIAUIKit
import UIKit

class PromoOfferTileCollectionViewCell: UICollectionViewCell, TileableCell {

    var tileType: AvailableTiles = .promoOffer

    typealias Entity = PromoOfferTile
    @IBOutlet private weak var tile: Entity!
    @IBOutlet weak var accessoryImageRight: UIImageView!
    @IBOutlet weak var accessoryButtonLeft: UIButton!
    @IBOutlet weak var tileLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var tileRightConstraint: NSLayoutConstraint!

    private var currentTileStatus: TileStatus?

    func setupCellForStatus(_ status: TileStatus) {
        self.accessibilityIdentifier = "PromoOfferTileCollectionViewCell"

        Theme.current.applyPrincipalBackground(self)
        Theme.current.applyPrincipalBackground(self.contentView)
        self.accessoryImageRight.image = Theme.current.dragDropImage()
        tile.status = status
        let animationDuration = currentTileStatus != nil ? AppConfiguration.Animations.duration : 0
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.tileLeftConstraint.constant = 0
                self.tileRightConstraint.constant = 0
                self.accessoryButtonLeft.isHidden = true
                self.accessoryImageRight.isHidden = true
                self.layoutIfNeeded()
                self.currentTileStatus = status
            })
    }
}
