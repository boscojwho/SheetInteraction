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
    func sheetInteractionChanged(
        closestDetent: UISheetPresentationController.Detent.Identifier,
        closestDistance: CGFloat,
        approachingDetent: UISheetPresentationController.Detent.Identifier?,
        approachingDistance: CGFloat?,
        precedingDetent: UISheetPresentationController.Detent.Identifier?,
        precedingDistance: CGFloat?)
    
    /// - Parameter targetDetent: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    func sheetInteractionEnded(
        targetDetent: UISheetPresentationController.Detent.Identifier,
        targetDistance: CGFloat)
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
    
    private lazy var sheetHeightOnPreviousChange: CGFloat = sheetView.frame.height - sheet.topSheetInsets.bottom
    
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
            let direction = pan.direction
            let frame = sheetView.convert(sheetView.frame, from: window)
            let detents = sheet.detents
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
            let detentsAbove = heights.filter { $0.2 <= 0 }
            /// Detents with a positive distance are lower than sheet's current position (i.e. need to drag down).
            let detentsBelow = heights.filter { $0.2 > 0 }
            /// This may or may not be the same as `closest`.
            let approaching = {
                switch direction {
                case .up:
                    /// Sheet is moving up.
                    return detentsAbove.first
                case .down:
                    return detentsBelow.last
                default:
                    return nil
                }
            }()
            let approachingDetent = approaching?.0
            let approachingDistance = approaching?.1
            /// Moving away from preceding detent, which may or may not be the detent at which sheet interaction began.
            let preceding = {
                switch direction {
                case .up:
                    return detentsBelow.last
                case .down:
                    return detentsAbove.first
                default:
                    return nil
                }
            }()
            let precedingDetent = preceding?.0
            let precedingDistance = preceding?.1
            
            /// Keep track of previous sheet height so we can use it on sheet interaction end.
            /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
            let sheetHeight = frame.height - sheet.topSheetInsets.bottom
            print("sheetHeight: ", sheetHeight)
            sheetHeightOnPreviousChange = sheetHeight
            
            /// Percentage to approachingDetent, where 1 is closest to approachingDetent.
            let percentageApproaching: CGFloat? = {
                guard let preceding, let approaching, let approachingDistance else {
                    return nil
                }
                let precedingHeight = UISheetPresentationController.Detent.height(identifier: preceding.0, maximumDetentValue: sheet.maximumDetentValue())!
                let approachingHeight = UISheetPresentationController.Detent.height(identifier: approaching.0, maximumDetentValue: sheet.maximumDetentValue())!
                let d = abs(precedingHeight - approachingHeight)
                return 1 - (approachingDistance / d)
            }()
            print("percentage: \(percentageApproaching ?? -1)")
            
            delegate?.sheetInteractionChanged(closestDetent: closest.0, closestDistance: closest.1, approachingDetent: approachingDetent, approachingDistance: approachingDistance, precedingDetent: precedingDetent, precedingDistance: precedingDistance)
        case .ended, .cancelled, .failed:
            let targetDetent = sheet.selectedDetentIdentifier ?? sheet.detents.first!.identifier
            guard let detentHeight = UISheetPresentationController.Detent.height(identifier: targetDetent, maximumDetentValue: sheet.maximumDetentValue()) else {
                return
            }
            let sheetHeight = sheetHeightOnPreviousChange
            let targetDistance = abs(sheetHeight - detentHeight)
            delegate?.sheetInteractionEnded(targetDetent: targetDetent, targetDistance: targetDistance)
        default:
            break
        }
    }
}
