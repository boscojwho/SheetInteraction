//
//  SheetStackInteraction.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2023-01-03.
//

import UIKit
import os

public protocol SheetStackInteractionForwardingBehavior: AnyObject {
    /// Returning `false` in top sheet is equivalent to temporarily disabling sheet interaction observation.
    func shouldHandleSheetInteraction() -> Bool
    /// Root presenter is the non-modal view controller that originally presented a modal sheet stack.
    ///
    /// In a multi-sheet configuration, this value is only applicable to the top sheet (i.e. ignored for all other sheets).
    /// This value is not used when forwarding interaction calls on a navigation controller stack.
    ///
    /// Default: `true`.
    func shouldNotifyRootPresenter() -> Bool
}

public extension SheetStackInteractionForwardingBehavior {
    func shouldNotifyRootPresenter() -> Bool {
        return true
    }
}

/// Defines delegate callback behavior in a modal sheet stack. This behavior becomes important when there are multiple sheets in a stack.
///
/// Delegates calls are sent from top sheet to bottom sheet, in that order, until the root presenter is found (and, optionally, forwarded delegate calls). Sheets that opt-out are simply skipped over.
public final class SheetStackInteractionForwarding {
    
    weak var delegate: SheetStackInteractionForwardingBehavior?
    
    private enum Notify {
        case none
        /// current sheet
        case presented(SheetInteractionDelegate?)
        /// i.e. sheet below
        case presenting(SheetStackInteractionForwarding, SheetInteraction)
        /// i.e. non-modal view controller that initiated a sheet stack.
        case root(SheetInteractionDelegate?)
    }
    
    /// Defines delegate call order in sheet stack.
    /// Contains logic for forwarding calls from top sheet down to the originating, non-modal, root view controller in sheet stack.
    private func handleSheetInteraction(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) -> [Notify] {
        var notify: [Notify] = []
        
        /// Notify this sheet's delegate, if necessary.
        if presentedSheetInteraction.interactionForwarding.delegate?.shouldHandleSheetInteraction() == true {
            notify.append(.presented(presentedSheetInteraction.delegate))
        }
        
        /// Find sheet below this one, and forward call to its `sheetStackBehavior`.
        if let sheetBelow = presentedSheetInteraction.sheetController.presentingViewController as? SheetInteractionDelegate {
            if let sheetBelowSheetInteraction = sheetBelow.sheetInteraction() {
                notify.append(.presenting(sheetBelowSheetInteraction.interactionForwarding, sheetBelowSheetInteraction))
            } else {
                SheetInteraction.logger.debug("This sheet's presentingViewController does not participate in modal sheet interaction, and is most likely the originating non-modal root view controller. If you wish to update this non-modal root view, make it conform to `SheetInteractionDelegate`.")
                if originSheetInteraction.interactionForwarding.delegate?.shouldNotifyRootPresenter() == true {
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
                notify.append(.presenting(sheetBelowSheetInteraction.interactionForwarding, sheetBelowSheetInteraction))
            } else {
                SheetInteraction.logger.debug("Reached end of sheet stack while encountering one or more sheets that don't conform to `SheetInteractionDelegate`.")
                if originSheetInteraction.interactionForwarding.delegate?.shouldNotifyRootPresenter() == true {
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
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
                } else {
                    delegate?.sheetInteractionBegan(sheetInteraction: originSheetInteraction, at: detentBegan)
                }
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
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionChanged(sheetInteraction: originSheetInteraction, interactionChange: interactionChange)
                } else {
                    delegate?.sheetInteractionChanged(sheetInteraction: originSheetInteraction, interactionChange: interactionChange)
                }
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
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionWillEnd(sheetInteraction: originSheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
                } else {
                    delegate?.sheetInteractionWillEnd(sheetInteraction: originSheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
                }
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
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionDidEnd(sheetInteraction: originSheetInteraction, selectedDetentIdentifier: identifier)
                } else {
                    delegate?.sheetInteractionDidEnd(sheetInteraction: originSheetInteraction, selectedDetentIdentifier: identifier)
                }
            case .root(let delegate):
                delegate?.sheetInteractionDidEnd(sheetInteraction: originSheetInteraction, selectedDetentIdentifier: identifier)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionShouldDismiss(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) -> Bool {
        if let navigationController = originSheetInteraction.sheetController.presentedViewController as? UINavigationController {
            /// In a navigation stack:
            /// `topViewController` should repsond.
            if let delegate = navigationController.topViewController as? SheetInteractionDelegate {
                return delegate.sheetInteractionShouldDismiss(sheetInteraction: originSheetInteraction)
            }
            SheetInteraction.logger.warning("\(navigationController).topViewController should be configured to respond to `sheetInteractionShouldDismiss()`.")
            if let delegate = navigationController as? SheetInteractionDelegate {
                return delegate.sheetInteractionShouldDismiss(sheetInteraction: originSheetInteraction)
            }
            SheetInteraction.logger.warning("\(navigationController) should be configured to respond to `sheetInteractionShouldDismiss()`.")
            if let delegate = originSheetInteraction.delegate {
                return delegate.sheetInteractionShouldDismiss(sheetInteraction: originSheetInteraction)
            }
            SheetInteraction.logger.warning("\(originSheetInteraction) does not have a delegate it can ask whether the current sheet should be dismissed: Fallback to default behaviour...")
            return originSheetInteraction.shouldDismiss()

        } else {
            /// Not in a navigation stack:
            /// Going to asssume `presentedViewController` is the currently visible/interactive sheet.
            guard let delegate = originSheetInteraction.sheetController.presentedViewController as? SheetInteractionDelegate else {
                SheetInteraction.logger.warning("\(originSheetInteraction)'s presented sheet does not have a delegate it can ask whether the current sheet should be dismissed: Fallback to default behaviour...")
                return originSheetInteraction.shouldDismiss()
            }
            return delegate.sheetInteractionShouldDismiss(sheetInteraction: originSheetInteraction)
        }
    }
    
    func sheetInteractionWillDismiss(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionWillDismiss(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction)
            case .presented(let delegate):
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionWillDismiss(sheetInteraction: originSheetInteraction)
                } else {
                    delegate?.sheetInteractionWillDismiss(sheetInteraction: originSheetInteraction)
                }
            case .root(let delegate):
                delegate?.sheetInteractionWillDismiss(sheetInteraction: originSheetInteraction)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionDidDismiss(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionDidDismiss(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction)
            case .presented(let delegate):
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionDidDismiss(sheetInteraction: originSheetInteraction)
                } else {
                    delegate?.sheetInteractionDidDismiss(sheetInteraction: originSheetInteraction)
                }
            case .root(let delegate):
                delegate?.sheetInteractionDidDismiss(sheetInteraction: originSheetInteraction)
            case .none:
                break
            }
        }
    }
    
    func sheetInteractionDidAttemptToDismiss(originSheetInteraction: SheetInteraction, presentedSheetInteraction: SheetInteraction) {
        let notify = handleSheetInteraction(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: presentedSheetInteraction)
        notify.forEach {
            switch $0 {
            case .presenting(let behavior, let interaction):
                behavior.sheetInteractionDidAttemptToDismiss(originSheetInteraction: originSheetInteraction, presentedSheetInteraction: interaction)
            case .presented(let delegate):
                if let navigationDelegate = delegate?.sheetInteraction()?.navigationForwardingDelegate {
                    navigationDelegate.sheetInteractionDidAttemptToDismiss(sheetInteraction: originSheetInteraction)
                } else {
                    delegate?.sheetInteractionDidAttemptToDismiss(sheetInteraction: originSheetInteraction)
                }
            case .root(let delegate):
                delegate?.sheetInteractionDidAttemptToDismiss(sheetInteraction: originSheetInteraction)
            case .none:
                break
            }
        }
    }
}
