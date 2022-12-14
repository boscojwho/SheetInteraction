//
//  Detent.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-12.
//

import UIKit

// MARK: - Compare
public extension UISheetPresentationController.Detent {
    
    /// - Note: If the resolved value of self is nil, returns false. If the resolved value of `other` is nil, and self.resolvedValue is non-nil, returns true.
    /// - Returns: Self if greater than `other`.
    func greaterThan(_ other: UISheetPresentationController.Detent, in sheet: UISheetPresentationController) -> Bool {
        let context = Context(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.layoutInfo.maximumDetentValue())
        guard let val1 = resolvedValue(in: context) else {
            return false
        }
        guard let val2 = other.resolvedValue(in: context) else {
            return true
        }
        return val1 > val2
    }
}
