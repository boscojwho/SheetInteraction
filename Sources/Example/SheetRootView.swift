//
//  SheetRootView.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-22.
//

import UIKit

final class SheetRootView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitView = subviews.first {
            $0.hitTest(point, with: event) != nil
        }
        if let hitView = hitView as? UIScrollView {
            print(#function, hitView)
            /// - TODO: Handle case where `UISheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false`.
            /// Also check if sheet is already at largest detent height.
            if hitView.bounds.origin.y > 0 {
                return false
            } else {
                return true
            }
        } else {
            return super.point(inside: point, with: event)
        }
    }
}
