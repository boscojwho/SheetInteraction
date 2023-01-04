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
}
