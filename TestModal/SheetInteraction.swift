//
//  SheetInteraction.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-06.
//

import UIKit

protocol SheetInteractionDelegate: AnyObject {
    /// - Parameter closestDetent: The detent with the shortest vertical distance from the top edge of a sheet stack. Sheet may or may not be moving away from this detent.
    /// - Parameter approachingDetent: This is `nil` if user interaction is stationary. Sheet may or may not end up resting at this detent, depending on sheet interaction velocity.
    func sheetInteractionChanged(closestDetent: UISheetPresentationController.Detent.Identifier, approachingDetent: UISheetPresentationController.Detent.Identifier?)
    /// - Parameter targetDetent: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    func sheetInteractionEnded(targetDetent: UISheetPresentationController.Detent.Identifier)
}

/// - NOTE: Ensure *interactionGesture* recognizes simultaneously with all other gestures in `sheetView`.
final class SheetInteraction {
    
    weak var delegate: SheetInteractionDelegate?
    
    let sheet: UISheetPresentationController
    /// The root view associated with a sheet's `presentedViewController`.
    let sheetView: UIView
    init(sheet: UISheetPresentationController, sheetView: UIView) {
        self.sheet = sheet
        self.sheetView = sheetView
        sheetView.addGestureRecognizer(sheetInteractionGesture)
    }
    
    /// The gesture used to track sheet interaction and detent state.
    /// This gesture must be configured to recognize simultaneously with all other gestures in `sheetView`.
    private(set) lazy var sheetInteractionGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDetentPan(pan:)))
        gesture.name = "detentPan"
        return gesture
    }()
    
    @objc private func handleDetentPan(pan: UIPanGestureRecognizer) {
        guard let window = sheetView.window else {
            return
        }
        
        /// Track which detent is currently closest to the top edge of sheet statck.
        //        print(#function, "state: \(pan.state)")
        switch pan.state {
        case .began:
            break
        case .changed:
            let frame = sheetView.convert(sheetView.frame, from: window)
            let detents = sheet.detents
            let direction = pan.direction
            let heights = detents.compactMap {
                let identifier = $0.identifier
                let detentHeight = UISheetPresentationController.Detent.height(identifier: identifier, maximumDetentValue: sheet.maximumDetentValue())!
                /// Exclude sheet height outside safe area (bottom edge attached).
                let sheetHeight = frame.height - sheet.topSheetInsets.bottom
                let distance = sheetHeight - detentHeight
                /// 0: detent identifier, 1: distance to detent, 2: negative values indicate higher up detents (and vice-versa).
                return (identifier, abs(distance), distance)
            }
            /// Closest in terms of distance, not accounting for sheet momemtum, which may cause sheet to rest at a further detent.
            let closest = heights.sorted { $0.1 < $1.1 }.first!
            /// Detents with a negative distance are higher than sheet's current position (i.e. need to drag up).
            let detentsAbove = heights.filter { $0.2 < 0 }
            /// Detents with a positive distance are lower than sheet's current position (i.e. need to drag down).
            let detentsBelow = heights.filter { $0.2 > 0 }
            /// This may or may not be the same as `closest`.
            let approaching: UISheetPresentationController.Detent.Identifier? = {
                switch direction {
                case .up:
                    /// Sheet is moving up.
                    return detentsAbove.first?.0
                case .down:
                    return detentsBelow.last?.0
                default:
                    return nil
                }
            }()
            delegate?.sheetInteractionChanged(closestDetent: closest.0, approachingDetent: approaching)
        case .ended, .cancelled, .failed:
            delegate?.sheetInteractionEnded(targetDetent: sheet.selectedDetentIdentifier ?? sheet.detents.first!.identifier)
        default:
            break
        }
    }
}
