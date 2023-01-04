//
//  SheetStackInteraction.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2023-01-03.
//

import UIKit
import os

public protocol SheetStackInteractionBehaviorDelegate: AnyObject {
    /// Returning `false` in top sheet is equivalent to temporarily disabling sheet interaction observation.
    func shouldHandleSheetInteraction() -> Bool
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
    
    private enum Notify {
        case none
        /// current sheet
        case presented(SheetInteractionDelegate?)
        /// i.e. sheet below
        case presenting(SheetStackInteractionBehavior, SheetInteraction)
        /// i.e. non-modal view controller that initiated a sheet stack.
        case root(SheetInteractionDelegate?)
    }
    
    /// Defines delegate call order in sheet stack.
    /// Contains logic for forwarding calls from top sheet down to the originating, non-modal, root view controller in sheet stack.
    private func handleSheetInteraction(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) -> [Notify] {
        var notify: [Notify] = []
        
        /// Notify this sheet's delegate, if necessary.
        if presentedSheetInteraction.sheetStackBehavior.delegate?.shouldHandleSheetInteraction() == true {
            notify.append(.presented(presentedSheetInteraction.delegate))
        }
        
        /// Find sheet below this one, and forward call to its `sheetStackBehavior`.
        if let sheetBelow = presentedSheetInteraction.sheetController.presentingViewController as? SheetInteractionDelegate {
            if let sheetBelowSheetInteraction = sheetBelow.sheetInteraction() {
                notify.append(.presenting(sheetBelowSheetInteraction.sheetStackBehavior, sheetBelowSheetInteraction))
            } else {
                SheetInteraction.logger.debug("This sheet's presentingViewController does not participate in modal sheet interaction, and is most likely the originating non-modal root view controller. If you wish to update this non-modal root view, make it conform to `SheetInteractionDelegate`.")
                if originSheetInteraction.sheetStackBehavior.delegate?.notifyRootPresenter() == true {
                    notify.append(.root(sheetBelow))
                }
            }
        } else {
            /// Sheet stack may be configured with one or more non `SheetInteraction`-conforming sheets:
            /// Find next sheet that conforms.
            var match: UIViewController? = presentedSheetInteraction.sheetController.presentingViewController
            while match is SheetInteractionDelegate == false, match != nil {
                match = match?.presentingViewController
            }
            if let sheetBelow = match as? SheetInteractionDelegate, let sheetBelowSheetInteraction = sheetBelow.sheetInteraction() {
                notify.append(.presenting(sheetBelowSheetInteraction.sheetStackBehavior, sheetBelowSheetInteraction))
            } else {
                SheetInteraction.logger.debug("Reached end of sheet stack while encountering one or more sheets that don't conform to `SheetInteractionDelegate`.")
                if originSheetInteraction.sheetStackBehavior.delegate?.notifyRootPresenter() == true {
                    SheetInteraction.logger.error("Can't notify sheet stack's non-modal root presenter because it doesn't conform to `SheetInteractionDelegate`.")
                }
            }
        }
        
        return notify
    }
    
    /// - Parameter presentedSheetInteraction: This is the same as `originSheetInteraction` when called from the top sheet (i.e. on initial call when walking down modal sheet stack).
    func sheetInteractionBegan(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction, at detentBegan: DetentIdentifier) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presented(let delegate):
                delegate?.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionBegan(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction, at: detentBegan)
            case .root(let delegate):
                delegate?.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionChanged(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presented(let delegate):
                delegate?.sheetInteractionChanged(sheetInteraction: originSheetInteraction, interactionChange: interactionChange)
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionChanged(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction, interactionChange: interactionChange)
            case .root(let delegate):
                delegate?.sheetInteractionChanged(sheetInteraction: originSheetInteraction, interactionChange: interactionChange)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionWillEnd(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionWillEnd(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
            case .presented(let delegate):
                delegate?.sheetInteractionWillEnd(sheetInteraction: originSheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
            case .root(let delegate):
                delegate?.sheetInteractionWillEnd(sheetInteraction: originSheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionDidEnd(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction, identifier: UISheetPresentationController.Detent.Identifier) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionDidEnd(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction, identifier: identifier)
            case .presented(let delegate):
                delegate?.sheetInteractionDidEnd(sheetInteraction: originSheetInteraction, selectedDetentIdentifier: identifier)
            case .root(let delegate):
                delegate?.sheetInteractionDidEnd(sheetInteraction: originSheetInteraction, selectedDetentIdentifier: identifier)
            case .none:
                break
            }
        }
    }
}
