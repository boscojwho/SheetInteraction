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
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionInfo: SheetInteraction.Change) {
        print(#function,
              "\n\tclosest: \(interactionInfo.closest.detentIdentifier.rawValue)",
              "\n\tclosestDistance: \(interactionInfo.closest.distance)",
              "\n\tapproaching: \(interactionInfo.approaching.detentIdentifier.rawValue )",
              "\n\tapproachingDistance: \(interactionInfo.approaching.distance )",
              "\n\tpreceding: \(interactionInfo.preceding.detentIdentifier.rawValue )",
              "\n\tprecedingDistance: \(interactionInfo.preceding.distance )")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionInfo: interactionInfo)
        }
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, percentageTotal: CGFloat) {
        print(#function,
              "\n\ttarget: \(targetDetentInfo.detentIdentifier.rawValue)",
              "\n\tdistance: \(targetDetentInfo.distance)")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionEnded(sheetInteraction: sheetInteraction, targetDetentInfo: targetDetentInfo, percentageTotal: percentageTotal)
        }
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
