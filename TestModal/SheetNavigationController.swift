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
    
    func sheetInteractionChanged(closestDetent: UISheetPresentationController.Detent.Identifier, closestDistance: CGFloat, approachingDetent: UISheetPresentationController.Detent.Identifier?, approachingDistance: CGFloat?, precedingDetent: UISheetPresentationController.Detent.Identifier?, precedingDistance: CGFloat?) {
        print(#function, "\n\tclosest: \(closestDetent.rawValue)", "\n\tclosestDistance: \(closestDistance)", "\n\tapproaching: \(approachingDetent?.rawValue ?? "stationary")", "\n\tapproachingDistance: \(approachingDistance ?? -1)", "\n\tpreceding: \(precedingDetent?.rawValue ?? "stationary")", "\n\tprecedingDistance: \(precedingDistance ?? -1)")
        print("* * *")
    }
    
    func sheetInteractionEnded(targetDetent: UISheetPresentationController.Detent.Identifier, targetDistance: CGFloat) {
        print(#function, "\n\ttarget: \(targetDetent)", "\n\tdistance: \(targetDistance)")
        print("* * *")
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
