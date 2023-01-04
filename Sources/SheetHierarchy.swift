//
//  SheetHierarchy.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2023-01-03.
//

import UIKit.UIViewController

public extension UIViewController {
    
    func isBottomSheet() -> Bool {
        return levelInSheetHierarchy() == 0
    }
    
    func isTopSheet() -> Bool {
        return presentedViewController == nil
    }
    
    /// - Returns: `true` if this sheet is the only one in a modal sheet stack.
    func isSingleSheet() -> Bool {
        return isBottomSheet() && isTopSheet()
    }
    
    func levelInSheetHierarchy() -> Int {
        var level = 0
        var presenting = presentingViewController
        while presenting != nil {
            presenting = presenting?.presentingViewController
            level += 1
        }
        return level
    }
    
    internal func _printSheetHierarchy() {
        guard let sheetPresentationController else {
            SheetInteraction.logger.debug("Sheet hierarchy not found.")
            return
        }
        sheetPresentationController._printSheetHierarchy()
    }
}

internal extension UISheetPresentationController {
    
    func _printSheetHierarchy() {
        var hierarchy: [UIViewController] = []
        var sheet: UIViewController? = presentedViewController
        while sheet != nil {
            hierarchy.append(sheet!)
            sheet = sheet?.presentingViewController
        }
        var level = 0
        hierarchy.reversed().forEach {
            SheetInteraction.logger.debug("\(String(repeating: "--", count: level))\($0)")
            level += 1
        }
    }
}
