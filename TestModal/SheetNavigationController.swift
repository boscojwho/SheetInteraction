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
        sheetInteraction.detentPanGesture.delegate = self
        sheetInteraction.delegate = self
    }
}

extension SheetNavigationController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(closestDetent: UISheetPresentationController.Detent.Identifier, approachingDetent: UISheetPresentationController.Detent.Identifier?) {
        print(#function, "closest: \(closestDetent)", "approaching: \(approachingDetent ?? .init("stationary"))")
    }
    
    func sheetInteractionEnded(targetDetent: UISheetPresentationController.Detent.Identifier) {
        print(#function, "target: \(targetDetent)")
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
