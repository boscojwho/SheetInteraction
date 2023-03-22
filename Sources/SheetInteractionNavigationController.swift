//
//  SheetInteractionNavigationController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-05.
//

import UIKit

/// View controllers managed by this navigation controller are automatically included in `SheetInteraction`.
public class SheetInteractionNavigationController: UINavigationController {
    
    private(set) lazy var _sheetInteraction: SheetInteraction = .init(
        sheet: sheetPresentationController!,
        sheetView: view!)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        /// Detent observer gesture doesn't need to be exclusive.
        _sheetInteraction.sheetInteractionGesture.delegate = self
        _sheetInteraction.delegate = self
        /// `SheetInteraction` creates this by default, unless you wish to use your own implementation.
//        _sheetInteraction.navigationForwardingDelegate = .init(navigationController: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
#if DEBUG
        let ncIndex = self.levelInSheetHierarchy()
        _sheetInteraction.debugLabel = "Modal \(ncIndex)"
#endif
    }
}

// MARK: - SheetStackInteractionForwardingBehavior
extension SheetInteractionNavigationController: SheetStackInteractionForwardingBehavior {
    public func shouldNotifyRootPresenter() -> Bool {
        return true
    }
    
    public func shouldHandleSheetInteraction() -> Bool {
        return isTopSheet()
    }
}

// MARK: - SheetInteractionDelegate
extension SheetInteractionNavigationController: SheetInteractionDelegate {
    
    public func sheetInteraction() -> SheetInteraction? {
        _sheetInteraction
    }
    
    public func sheetStackDelegate() -> SheetStackInteractionForwarding? {
        _sheetInteraction.interactionForwarding
    }
    
    public func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        
    }
    
    public func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
    }
    
    public func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        
    }
    
    public func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        
    }
    
    public func sheetInteractionShouldDismiss(sheetInteraction: SheetInteraction) -> Bool {
        return sheetInteraction.shouldDismiss()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SheetInteractionNavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
