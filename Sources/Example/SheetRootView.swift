//
//  SheetRootView.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-22.
//

import UIKit
import SheetInteraction_SPM

final class SheetRootView: UIView {
    
    weak var sheetController: UISheetPresentationController?
    private var trackingDetent: UISheetPresentationController.Detent? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let sheet = sheetController {
            AppDelegate.logger.debug("\(#function) - \(sheet.layoutInfo.sheetFrameInWindow.origin.y)")
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let sheetController else {
            AppDelegate.logger.error("`SheetRootView` requires a sheet presentation controller.")
            return super.point(inside: point, with: event)
        }
        guard let event else {
            AppDelegate.logger.error("`\(#function)` called with nil event.")
            return super.point(inside: point, with: event)
        }
        let hitView = subviews.first { $0.hitTest(point, with: event) != nil }
        /// We are only interested in events that occur on a descendant scroll view.
        guard let hitView = hitView as? UIScrollView else {
            AppDelegate.logger.debug("Hit view not a scroll view, use default behaviour: \(hitView)")
            return super.point(inside: point, with: event)
        }
                
        AppDelegate.logger.debug("\(Self.self).allTouches: \(event.allTouches?.count ?? 0)")

        /// Return true to allow descendant scroll view to handle touch input.
        /// Otherwise, return `false` to forward touch to a private UIKIt view.
        switch sheetController.prefersScrollingExpandsWhenScrolledToEdge {
        case true:
            /// Check if sheet is already at largest detent height.
            AppDelegate.logger.debug("* * *")
            if hitView.bounds.origin.y > 0 {
                AppDelegate.logger.debug("Scroll view is scrolled down from top.")
                if let trackingDetent, trackingDetent.greaterThan(._large(), in: sheetController) {
                    AppDelegate.logger.debug("\ttrackingDetent: \(trackingDetent.identifier.rawValue) > _large")
                    AppDelegate.logger.debug("\t")
                    return true
                }
                AppDelegate.logger.debug("\ttrackingDetent: \(self.trackingDetent!.identifier.rawValue) <= _large")
                return false
            } else {
                AppDelegate.logger.debug("Scroll view at top or rubber-banding at top.")
                if let trackingDetent, trackingDetent.greaterThan(._large(), in: sheetController) == false {
                    AppDelegate.logger.debug("\ttrackingDetent: \(trackingDetent.identifier.rawValue) <= _large")
                    return false
                }
                AppDelegate.logger.debug("\ttrackingDetent: \(self.trackingDetent!.identifier.rawValue) > _large")
                /// On scroll down at largest possible detent, don't forward touch: Allow non-scroll view to determine target detent.
                /// On scroll up at largest possible detent, forward touch to scroll view so users can scroll content.
                return true
            }
        case false:
            return super.point(inside: point, with: event)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        AppDelegate.logger.debug("\(Self.self).\(#function) - \(hitView)")
        return hitView
    }
}

extension SheetRootView: SheetInteractionDelegate {
    
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        sheetController = sheetInteraction.sheetController
        trackingDetent = sheetInteraction.sheetController.detent(withIdentifier: detent)
    }
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        sheetController = sheetInteraction.sheetController
        trackingDetent = sheetInteraction.sheetController.detent(withIdentifier: interactionChange.approaching.detentIdentifier)
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        trackingDetent = sheetInteraction.sheetController.detent(withIdentifier: targetDetentInfo.detentIdentifier)
    }
}
