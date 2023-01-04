//
//  SheetStackInteraction.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2023-01-03.
//

import UIKit
import os

public protocol SheetStackInteractionBehaviorDelegate: AnyObject {
    /// Root presenter is the non-modal view controller that originally presented a modal sheet stack.
    ///
    /// In a multi-sheet configuration, this value is only applicable to the top sheet (i.e. ignored for all other sheets).
    func notifyRootPresenter() -> Bool
    /// The view controller that presented this sheet.
    func notifyPresenter() -> Bool
}

/// Defines delegate callback behavior in a modal sheet stack. This behavior becomes important when there are multiple sheets in a stack.
public final class SheetStackInteractionBehavior {
    
    weak var delegate: SheetStackInteractionBehaviorDelegate?
    
    /// - Parameter presentingSheetInteraction: This is the same as `originSheetInteraction` when called from the top sheet.
    func sheetInteractionBegan(originSheetInteraction: SheetInteraction, presentingSheetInteraction: SheetInteraction, at detentBegan: DetentIdentifier) {
        guard let delegate else {
            SheetInteraction.logger.debug("Behavior delegate not found.")
            return
        }
        
        guard let presentingDelegate = presentingSheetInteraction.sheetController.presentingViewController as? SheetInteractionDelegate else {
            SheetInteraction.logger.debug("This sheet's presentingViewController does not participate in modal sheet interaction, and is most likely the originating non-modal root view controller. If you wish to update this non-modal root view, make it conform to `SheetInteractionDelegate`.")
            return
        }
        
        guard let presentingDelegateSheetInteraction = presentingDelegate.sheetInteraction() else {
#if DEBUG
            if presentingSheetInteraction.sheetController.presentedViewController.isTopSheet() == false {
                SheetInteraction.logger.warning("Encountered a sheet without a sheet interaction in sheet stack: Be sure to return non-nil from `SheetInteractionDelegate.sheetInteraction()`. Ignore this warning if it is intentional.")
            }
#endif
            if originSheetInteraction.sheetStackBehavior.delegate?.notifyRootPresenter() == true {
                SheetInteraction.logger.debug("Notifying root presenter: \(String(describing: presentingDelegate))")
                presentingDelegate.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
            }
            return
        }
        
        /// Notify origin once.
        if presentingSheetInteraction == originSheetInteraction || presentingSheetInteraction.sheetController.presentedViewController == originSheetInteraction.sheetController.presentedViewController {
            SheetInteraction.logger.debug("\(#function) - delegate: \(String(describing: delegate.self))")
            originSheetInteraction.delegate?.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
        }
        
        if delegate.notifyPresenter() == true {
            SheetInteraction.logger.debug("\(#function) - presentingDelegate: \(String(describing: presentingDelegate.self))")
            presentingDelegateSheetInteraction
                .sheetStackBehavior
                .sheetInteractionBegan(originSheetInteraction: originSheetInteraction, presentingSheetInteraction: presentingDelegateSheetInteraction, at: detentBegan)
        }
        
        if delegate.notifyRootPresenter() == true {
            
        }
    }
}
