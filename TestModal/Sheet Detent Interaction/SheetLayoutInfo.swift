//
//  SheetLayoutInfo.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-11.
//

import UIKit

/// Layout info for the sheets in a modal sheet stack.
struct SheetLayoutInfo {
    let sheet: UISheetPresentationController
    let sheetView: UIView
    let window: UIWindow
    
    /// Sheet frame in provided window.
    var sheetFrameInWindow: CGRect {
        window.convert(sheetView.frame, from: sheetView)
    }
    
    var sheetHeight: CGFloat {
        sheetFrameInWindow.height - topSheetInsets.bottom
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
        return window.frame.height - (topSheetInsets.top + topSheetInsets.bottom)
    }
    
    /// The vertical space required to display the bottom sheet in "minimized" state when the top sheet is displayed in full height.
    private var bottomSheetPeekThroughHeight: CGFloat {
        switch sheet.traitCollection.userInterfaceIdiom {
        case .phone:
            if sheet.traitCollection.verticalSizeClass == .compact {
                return 8.0
            }
            return 10.0
        case .pad:
            return 20.0
        default:
            return 10.0
        }
    }
    
    private var bottomSheetTopInset: CGFloat {
        /// Assume home-button device.
        if window.safeAreaInsets.bottom == 0 {
            /// This additional inset is likely a visual design consideration made by Apple, and is not present on home indicator devices. [2022.12]
            let additionalTopInset: CGFloat = 10
            return window.safeAreaInsets.top + additionalTopInset
        } else {
            switch sheet.traitCollection.userInterfaceIdiom {
            case .phone:
                return window.safeAreaInsets.top
            case .pad:
                let bottomSheetTopEdgeInset: CGFloat = 10
                return window.safeAreaInsets.top + bottomSheetTopEdgeInset
            default:
                return window.safeAreaInsets.top
            }
        }
    }
    
    private var topSheetTopInset: CGFloat {
        /// Assume home-button device.
        if window.safeAreaInsets.bottom == 0 {
            return bottomSheetTopInset + bottomSheetPeekThroughHeight
        } else {
            return window.safeAreaInsets.top + bottomSheetPeekThroughHeight
        }
    }
    
    private var sheetBottomInset: CGFloat {
        return window.safeAreaInsets.bottom
    }
}
