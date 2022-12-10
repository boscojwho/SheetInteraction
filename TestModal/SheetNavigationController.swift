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
    
    func sheetInteractionChanged(sheet: SheetInteraction, interactionInfo: SheetInteractionInfo) {
        print(#function,
              "\n\tclosest: \(interactionInfo.closest.detent.rawValue)",
              "\n\tclosestDistance: \(interactionInfo.closest.distance)",
              "\n\tapproaching: \(interactionInfo.approaching.detent.rawValue )",
              "\n\tapproachingDistance: \(interactionInfo.approaching.distance )",
              "\n\tpreceding: \(interactionInfo.preceding.detent.rawValue )",
              "\n\tprecedingDistance: \(interactionInfo.preceding.distance )")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheet: sheet, interactionInfo: interactionInfo)
        }
    }
    
    func sheetInteractionEnded(sheet: SheetInteraction, targetDetent: SheetInteractionInfo.Change, percentageTotal: CGFloat) {
        print(#function,
              "\n\ttarget: \(targetDetent.detent.rawValue)",
              "\n\tdistance: \(targetDetent.distance)")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionEnded(sheet: sheet, targetDetent: targetDetent, percentageTotal: percentageTotal)
        }
    }    
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
