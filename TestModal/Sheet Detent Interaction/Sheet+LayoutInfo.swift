//
//  Sheet+LayoutInfo.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-12.
//

import UIKit

// MARK: - Layout Info
public extension UISheetPresentationController {
    
    var layoutInfo: SheetLayoutInfo {
        .init(sheet: self, sheetView: sheetView, window: sheetView.window!)
    }
    
    private var sheetView: UIView {
        /// Don't use presentedView, which may return UIDropShadowView:
        /// Could cause issues if drop shadow view is not at the same origin or same size as layout container view.
        presentedViewController.view!
    }
}
