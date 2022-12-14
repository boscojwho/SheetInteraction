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
        print(#function,
              "\n\tclosest: \(interactionChange.closest.detentIdentifier.rawValue)",
              "\n\tclosestDistance: \(interactionChange.closest.distance)",
              "\n\tapproaching: \(interactionChange.approaching.detentIdentifier.rawValue )",
              "\n\tapproachingDistance: \(interactionChange.approaching.distance )",
              "\n\tpreceding: \(interactionChange.preceding.detentIdentifier.rawValue )",
              "\n\tprecedingDistance: \(interactionChange.preceding.distance )")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionChange: interactionChange)
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
