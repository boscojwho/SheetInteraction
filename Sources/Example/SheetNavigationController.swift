//
//  SheetNavigationController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-05.
//

import UIKit
import SheetInteraction_SPM

class SheetNavigationController: UINavigationController {
    
    private lazy var _sheetInteraction: SheetInteraction = .init(
        sheet: sheetPresentationController!,
        sheetView: view!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Detent observer gesture doesn't need to be exclusive.
        _sheetInteraction.sheetInteractionGesture.delegate = self
        _sheetInteraction.delegate = self
        /// `SheetInteraction` creates this by default, unless you wish to use your own implementation.
//        _sheetInteraction.navigationForwardingDelegate = .init(navigationController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let ncIndex = self.levelInSheetHierarchy()
        _sheetInteraction.debugLabel = "Modal \(ncIndex)"
    }
}

extension SheetNavigationController: SheetStackInteractionForwardingBehavior {
    func shouldNotifyRootPresenter() -> Bool {
        return true
    }
    
    func shouldHandleSheetInteraction() -> Bool {
        return isTopSheet()
    }
}

extension SheetNavigationController: SheetInteractionDelegate {
    
    func sheetInteraction() -> SheetInteraction? {
        _sheetInteraction
    }
    
    func sheetStackDelegate() -> SheetStackInteractionForwarding? {
        _sheetInteraction.interactionForwarding
    }
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction_SPM.SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        
    }
}

extension SheetNavigationController: UISheetPresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        (topViewController as? UISheetPresentationControllerDelegate)?.presentationControllerShouldDismiss?(presentationController) ?? true
    }
}

extension SheetNavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
