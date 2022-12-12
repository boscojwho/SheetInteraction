//
//  SheetPresentationController.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-07.
//

import UIKit

// MARK: - Compare
extension UISheetPresentationController.Detent {
    
    /// - Note: If the resolved value of self is nil, returns false. If the resolved value of `other` is nil, and self.resolvedValue is non-nil, returns true.
    /// - Returns: Self if greater than `other`.
    func greaterThan(other: UISheetPresentationController.Detent, in sheet: UISheetPresentationController) -> Bool {
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

// MARK: - Detents
extension UISheetPresentationController {
    
    /// - Returns: First detent in `detents`, instead of `nil`.
    func identifierForSelectedDetent() -> Detent.Identifier {
        selectedDetentIdentifier ?? detents.first!.identifier
    }
    
    func detent(withIdentifier identifier: Detent.Identifier) -> Detent? {
        detents.first { $0.identifier == identifier }
    }
}

// MARK: - Layout Info
extension UISheetPresentationController {
    
    var layoutInfo: SheetLayoutInfo {
        .init(sheet: self, sheetView: sheetView, window: sheetView.window!)
    }
    
    var sheetView: UIView {
        /// Don't use presentedView, which may return UIDropShadowView:
        /// Could cause issues if drop shadow view is not at the same origin or same size as layout container view.
        presentedViewController.view!
    }
}
