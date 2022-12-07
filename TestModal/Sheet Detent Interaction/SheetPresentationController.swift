//
//  SheetPresentationController.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-07.
//

import UIKit

extension UISheetPresentationController {
    
    /// The vertical space required to display the bottom sheet in "minimized" state when the top sheet is displayed in full height.
    /// This **does not** vary based on device.
    private static let bottomSheetPeekThroughHeight: CGFloat = 10.0
    
    private var bottomSheetTopInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            /// This additional inset is likely a visual design consideration made by Apple, and is not present on home indicator devices. [2022.12]
            let additionalTopInset: CGFloat = 10
            return window.safeAreaInsets.top + additionalTopInset
        } else {
            return window.safeAreaInsets.top
        }
    }
    
    private var topSheetTopInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            return bottomSheetTopInset + UISheetPresentationController.bottomSheetPeekThroughHeight
        } else {
            return window.safeAreaInsets.top + UISheetPresentationController.bottomSheetPeekThroughHeight
        }
    }
    
    private var sheetBottomInset: CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    /// Layout insets inside window for the bottom sheet (visually underneath) in a sheet stack.
    var bottomSheetInsets: UIEdgeInsets {
        .init(top: bottomSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// Layout insets inside window for the top sheet (visually on top) in a sheet stack.
    var topSheetInsets: UIEdgeInsets {
        .init(top: topSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// The height available to the top sheet in a sheet stack (i.e. height within window's safe area).
    func maximumDetentValue() -> CGFloat {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            return 0
        }
        return window.frame.height - (topSheetInsets.top + topSheetInsets.bottom)
    }
}
