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
    
    func sheetInteractionChanged(sheet: SheetInteraction, info: SheetInteractionInfo) {
        print(#function,
              "\n\tclosest: \(info.closest.detent.rawValue)",
              "\n\tclosestDistance: \(info.closest.distance)",
              "\n\tapproaching: \(info.approaching.detent.rawValue )",
              "\n\tapproachingDistance: \(info.approaching.distance )",
              "\n\tpreceding: \(info.preceding.detent.rawValue )",
              "\n\tprecedingDistance: \(info.preceding.distance )")
        print("* * *")
        if let delegate = topViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheet: sheet, info: info)
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
