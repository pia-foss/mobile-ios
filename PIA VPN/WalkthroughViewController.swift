//
//  WalkthroughViewController.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 12/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

class WalkthroughViewController: AutolayoutViewController {
    @IBOutlet private weak var scrollContent: UIScrollView!

    @IBOutlet private weak var viewContent: UIView!
    
    @IBOutlet private weak var buttonSkip: UIButton!
    
    @IBOutlet private weak var buttonNext: UIButton!
    
    @IBOutlet private weak var pageControl: PIAPageControl!
    
    private lazy var allData: [WalkthroughPageView.PageData] = [
        WalkthroughPageView.PageData(
            title: L10n.Walkthrough.Page._1.title,
            detail: L10n.Walkthrough.Page._1.description,
            image: Asset.imageWalkthrough1.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Walkthrough.Page._2.title,
            detail: L10n.Walkthrough.Page._2.description,
            image: Asset.imageWalkthrough2.image
        ),
        WalkthroughPageView.PageData(
            title: L10n.Walkthrough.Page._3.title,
            detail: L10n.Walkthrough.Page._3.description,
            image: Asset.imageWalkthrough3.image
        )
    ]

    private var currentPageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    
        buttonSkip.setTitle(L10n.Walkthrough.Action.skip, for: .normal)
        addPages()
        pageControl.numberOfPages = allData.count
        updateButtonsToCurrentPage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.scrollToPage(self.currentPageIndex, animated: false, force: true, width: size.width)
        }, completion: nil)
    }

    // MARK: Actions
    
    @IBAction private func nextPage(_ sender: Any?) {
        guard (currentPageIndex < allData.count - 1) else {
            dismiss()
            return
        }
        scrollToPage(currentPageIndex + 1, animated: true)
    }
    
    @IBAction private func scrollPage(_ sender: UIPageControl) {
        scrollToPage(sender.currentPage, animated: true)
    }
    
    private func dismiss() {
        perform(segue: StoryboardSegue.Main.unwindWalkthroughSegueIdentifier)
    }
    
    // MARK: Helpers

    private func addPages() {
        let parent = viewContent!
        var constraints: [NSLayoutConstraint] = []
        var previousPage: UIView?
        
        for (i, data) in allData.enumerated() {
            let page = WalkthroughPageView(data: data)
            page.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(page)
            
            // size
            constraints.append(page.widthAnchor.constraint(equalTo: scrollContent.widthAnchor))
            constraints.append(page.centerYAnchor.constraint(equalTo: parent.centerYAnchor))
            constraints.append(page.topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor, constant: 20.0))
            constraints.append(page.bottomAnchor.constraint(lessThanOrEqualTo: parent.bottomAnchor, constant: -20.0))
            
            // left
            if let previousPage = previousPage {
                constraints.append(page.leftAnchor.constraint(equalTo: previousPage.rightAnchor))
            } else {
                constraints.append(page.leftAnchor.constraint(equalTo: parent.leftAnchor))
            }
            
            // right
            if (i == allData.count - 1) {
                constraints.append(page.rightAnchor.constraint(equalTo: parent.rightAnchor))
            }
            
            previousPage = page
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func scrollToPage(_ pageIndex: Int, animated: Bool) {
        scrollToPage(pageIndex, animated: animated, force: false, width: scrollContent.frame.size.width)
    }
    
    private func scrollToPage(_ pageIndex: Int, animated: Bool, force: Bool, width: CGFloat) {
        guard (force || (pageIndex != currentPageIndex)) else {
            return
        }
        currentPageIndex = pageIndex
        scrollContent.setContentOffset(CGPoint(x: CGFloat(pageIndex * Int(width)), y: 0), animated: animated)
        pageControl.currentPage = pageIndex
        updateButtonsToCurrentPage()
    }
    
    private func updateButtonsToCurrentPage() {
        guard (currentPageIndex < allData.count - 1) else {
            buttonSkip.isHidden = true
            buttonNext.setTitle(L10n.Walkthrough.Action.done, for: .normal)
            return
        }
        buttonSkip.isHidden = false
        buttonNext.setTitle(L10n.Walkthrough.Action.next, for: .normal)
    }

    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()
    
        Theme.current.applyHighlightedText(buttonSkip)
        Theme.current.applyHighlightedText(buttonNext)
        Theme.current.applyPageControl(pageControl)
    }
}

extension WalkthroughViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPageIndex = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        pageControl.currentPage = currentPageIndex
        updateButtonsToCurrentPage()
    }
}
