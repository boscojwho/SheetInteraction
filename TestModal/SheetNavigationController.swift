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
    
    func sheetInteractionChanged(info: SheetInteractionInfo) {
        print(#function,
              "\n\tclosest: \(info.closest.detent.rawValue)",
              "\n\tclosestDistance: \(info.closest.distance)",
              "\n\tapproaching: \(info.approaching.detent.rawValue )",
              "\n\tapproachingDistance: \(info.approaching.distance )",
              "\n\tpreceding: \(info.preceding.detent.rawValue )",
              "\n\tprecedingDistance: \(info.preceding.distance )")
        print("* * *")
    }
    
    func sheetInteractionEnded(targetDetent: SheetInteractionInfo.Change) {
        print(#function,
              "\n\ttarget: \(targetDetent.detent.rawValue)",
              "\n\tdistance: \(targetDetent.distance)")
        print("* * *")
    }    
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}