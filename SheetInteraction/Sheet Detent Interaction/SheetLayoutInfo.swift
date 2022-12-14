//
//  SheetLayoutInfo.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-11.
//

import UIKit

/// Layout info for the sheets in a modal sheet stack.
///
/// - topSheet: The modal view at the front of a sheet stack.
/// - bottomSheet: A (modal) view behind the top sheet. This could either be the view associated with an app's root view controller, or a previously presented modal view.
public struct SheetLayoutInfo {
    public let sheet: UISheetPresentationController
    public let sheetView: UIView
    public let window: UIWindow
    
    /// Sheet frame in provided window.
    /// - Warning: This value does not account for safe area insets. You may need to use one of the provided variables in this layout info, or manually inset frame values.
    public var sheetFrameInWindow: CGRect {
        window.convert(sheetView.frame, from: sheetView)
    }
    
    /// A sheet's height ouside its safe area should **not** be used when making calculations relating to a sheet's `maximumDetentValue`, since the latter represents the maximum height a sheet should occupy *inside* a window's safe area.
    public var sheetHeightInSafeArea: CGFloat {
        sheetFrameInWindow.height - topSheetInsets.bottom
    }
    
    /// Layout insets inside window for the bottom sheet (visually underneath) in a sheet stack.
    public var bottomSheetInsets: UIEdgeInsets {
        .init(top: bottomSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// Layout insets inside window for the top sheet (visually on top) in a sheet stack.
    public var topSheetInsets: UIEdgeInsets {
        .init(top: topSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// The height available to the top sheet in a sheet stack (i.e. height within window's safe area).
    ///
    /// This is the same as that provided by a detent's resolution context in its resolver closure.
    public func maximumDetentValue() -> CGFloat {
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
    
    /// The top edge inset for the bottom sheet, as measured from its window's top edge.
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
    
    /// The top edge inset for the top sheet, as measured from its window's top edge.
    private var topSheetTopInset: CGFloat {
        /// Assume home-button device.
        if window.safeAreaInsets.bottom == 0 {
            return bottomSheetTopInset + bottomSheetPeekThroughHeight
        } else {
            return window.safeAreaInsets.top + bottomSheetPeekThroughHeight
        }
    }
    
    /// The bottom edge inset for both top and bottom sheets, as measured from its window's bottom edge.
    ///
    /// `UISheetPresentationController` does *not* vary the visual presentation of both top and bottom sheets.
    private var sheetBottomInset: CGFloat {
        return window.safeAreaInsets.bottom
    }
}
