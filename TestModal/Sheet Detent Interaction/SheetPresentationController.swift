//
//  SheetPresentationController.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-07.
//

import UIKit

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
