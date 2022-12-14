//
//  SheetNavigationController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-05.
//

import UIKit

class SheetNavigationController: UINavigationController {
    
    private lazy var sheetInteraction: SheetInteraction = .init(
        sheet: sheetPresentationController!,
        sheetView: view!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Detent observer gesture doesn't need to be exclusive.
        sheetInteraction.sheetInteractionGesture.delegate = self
        sheetInteraction.delegate = self
    }
}

extension SheetNavigationController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        AppDelegate.logger.debug("\(#function) - \n\tclosest: \(interactionChange.closest.detentIdentifier.rawValue), closestDistance: \(interactionChange.closest.distance) \n\tapproaching: \(interactionChange.approaching.detentIdentifier.rawValue), ...Distance: \(interactionChange.approaching.distance), ...Percentage: \(interactionChange.percentageApproaching) \n\tpreceding: \(interactionChange.preceding.detentIdentifier.rawValue), ...Distance: \(interactionChange.preceding.distance), ...Percentage: \(interactionChange.percentagePreceding) \n\tpercentageTotal: \(interactionChange.percentageTotal)")
        AppDelegate.logger.debug("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionChange: interactionChange)
        }
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        AppDelegate.logger.debug("\(#function) - \n\ttarget: \(targetDetentInfo.detentIdentifier.rawValue) \n\tdistance: \(targetDetentInfo.distance)")
        AppDelegate.logger.debug("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionEnded(sheetInteraction: sheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
        }
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
