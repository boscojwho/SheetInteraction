//
//  SheetNavigationController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-05.
//

import UIKit
import SheetInteraction_SPM

class SheetNavigationController: UINavigationController {
    
    private(set) lazy var sheetInteraction: SheetInteraction = .init(
        sheet: sheetPresentationController!,
        sheetView: view!)
    
    private var sheetInteractionDelegate: SheetInteractionDelegate? {
        topViewController as? SheetInteractionDelegate
    }
    
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
        
        sheetInteractionDelegate?.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionChange: interactionChange)
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        AppDelegate.logger.debug("\(#function) - \n\ttarget: \(targetDetentInfo.detentIdentifier.rawValue) \n\tdistance: \(targetDetentInfo.distance)")
        AppDelegate.logger.debug("* * *")
        
        sheetInteractionDelegate?.sheetInteractionEnded(sheetInteraction: sheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction_SPM.SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        sheetInteractionDelegate?.sheetInteractionDidEnd(sheetInteraction: sheetInteraction, selectedDetentIdentifier: selectedDetentIdentifier)
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
