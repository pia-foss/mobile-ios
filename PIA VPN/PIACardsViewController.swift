//
//  PIACardsViewController.swift
//  PIA VPN
//
//  Created by Jose Blaya on 10/07/2020.
//  Copyright © 2020 Private Internet Access Inc. All rights reserved.
//

import UIKit
import PIALibrary

class PIACardsViewController: UIViewController {

    private var cards: [Card]!
    private var slides:[PIACard] = []

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: Orientation
    @objc func onlyPortrait() -> Void {}

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        setupSlides()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    private func setupSlides() {
        self.slides = createSlides()
        self.setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }
    
    func setupWith(cards: [Card]) {
        self.cards = cards
    }
    
    func createSlides() -> [PIACard] {
        
        let closeImage = Asset.iconClose.image.withRenderingMode(.alwaysTemplate)
        
        var collectingCards = [PIACard]()
        for card in cards {
            let slide:PIACard = Bundle.main.loadNibNamed("PIACard", owner: self, options: nil)?.first as! PIACard
            slide.cardParallaxImageView.image = UIImage(named: card.cardFrontImage)
            slide.cardTitle.text = card.title
            slide.cardDescription.text = card.description
            slide.closeButton.setImage(closeImage, for: [])
            slide.closeButton.addAction(for: .touchUpInside) { (button) in
                self.dismiss(animated: true, completion: nil)
            }

            slide.cardCTAButton.style(style: TextStyle.Buttons.piaGreenButton)
            slide.cardCTAButton.setTitle(card.ctaLabel, for: [])
            slide.cardCTAButton.accessibilityIdentifier = card.ctaLabel
            slide.cardCTAButton.addAction(for: .touchUpInside) { (button) in
                self.dismiss(animated: true, completion: {
                    card.cta()
                })
            }
            if card.hasSecondCTA() {
                slide.cardSecondaryCTAButton.isHidden = false
                slide.cardSecondaryCTAButton.setTitle(L10n.Card.Wireguard.Cta.learn, for: [])
                slide.cardSecondaryCTAButton.accessibilityIdentifier = L10n.Card.Wireguard.Cta.learn
                slide.cardSecondaryCTAButton.addAction(for: .touchUpInside) { (button) in
                    if let url = card.learnMoreLink {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            } else {
                slide.cardSecondaryCTAButton.setTitle("", for: [])
                slide.cardSecondaryCTAButton.isHidden = true
            }

            slide.cardBackgroundImagePrefix = card.cardImage
            collectingCards.append(slide)
        }
        
        return collectingCards
    }
    
    func setupSlideScrollView(slides : [PIACard]) {
        
        guard let view = view else {
            return
        }
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
        
        scrollView.subviews.forEach({
            if let view = $0 as? PIACard {
                view.setupView()
            }
        })
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: slides)
    }

}
