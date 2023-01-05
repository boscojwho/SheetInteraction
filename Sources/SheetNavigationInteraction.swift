//
//  SheetNavigationInteraction.swift
//  SheetInteraction-SPM
//
//  Created by Bosco Ho on 2023-01-04.
//

import UIKit
import os

/// Manages sheet interaction forwarding on a sheet's navigation controller stack.
///
/// Calls are forwarded from top view controller down to root view controller, in that order. View controllers must conform to both `SheetInteractionDelegate` and `SheetStackInteractionForwardingBehavior`, and return `shouldHandleSheetInteraction() == true`. View controller(s) that fail to do so are skipped.
public final class SheetInteractionNavigationForwarding {
    
    private weak var navigationController: UINavigationController?
    public init?(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
}

extension SheetInteractionNavigationForwarding: SheetInteractionDelegate {
    
    public func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        navigationController?.viewControllers.reversed().forEach {
            if let delegate = $0 as? SheetInteractionDelegate, let forwardingBehavior = delegate as? SheetStackInteractionForwardingBehavior, forwardingBehavior.shouldHandleSheetInteraction() == true {
                delegate.sheetInteractionBegan(sheetInteraction: sheetInteraction, at: detent)
            }
        }
    }
    
    public func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        navigationController?.viewControllers.reversed().forEach {
            if let delegate = $0 as? SheetInteractionDelegate, let forwardingBehavior = delegate as? SheetStackInteractionForwardingBehavior, forwardingBehavior.shouldHandleSheetInteraction() == true {
                delegate.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionChange: interactionChange)
            }
        }
    }
    
    public func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        navigationController?.viewControllers.reversed().forEach {
            if let delegate = $0 as? SheetInteractionDelegate, let forwardingBehavior = delegate as? SheetStackInteractionForwardingBehavior, forwardingBehavior.shouldHandleSheetInteraction() == true {
                delegate.sheetInteractionWillEnd(sheetInteraction: sheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
            }
        }
    }
    
    public func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        navigationController?.viewControllers.reversed().forEach {
            if let delegate = $0 as? SheetInteractionDelegate, let forwardingBehavior = delegate as? SheetStackInteractionForwardingBehavior, forwardingBehavior.shouldHandleSheetInteraction() == true {
                delegate.sheetInteractionDidEnd(sheetInteraction: sheetInteraction, selectedDetentIdentifier: selectedDetentIdentifier)
            }
        }
    }
}