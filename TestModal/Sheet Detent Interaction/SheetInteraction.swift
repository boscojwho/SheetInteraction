//
//  SheetInteraction.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-06.
//

import UIKit

extension UISheetPresentationController.Detent {
    
    /// - Note: If the resolved value of self is nil, returns false. If the resolved value of `other` is nil, and self.resolvedValue is non-nil, returns true.
    /// - Returns: Self if greater than `other`.
    func greaterThan(other: UISheetPresentationController.Detent, in sheet: UISheetPresentationController) -> Bool {
        let context = Context(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.maximumDetentValue())
        guard let val1 = resolvedValue(in: context) else {
            return false
        }
        guard let val2 = other.resolvedValue(in: context) else {
            return true
        }
        return val1 > val2
    }
}

class Context: NSObject, UISheetPresentationControllerDetentResolutionContext {
    let containerTraitCollection: UITraitCollection
    let maximumDetentValue: CGFloat
    init(containerTraitCollection: UITraitCollection, maximumDetentValue: CGFloat) {
        self.containerTraitCollection = containerTraitCollection
        self.maximumDetentValue = maximumDetentValue
    }
}

/// Emit sheet interaction events.
protocol SheetInteractionDelegate: AnyObject {
    func sheetInteractionChanged(sheet: SheetInteraction, info: SheetInteractionInfo)
    
    /// - Parameter targetDetent: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    func sheetInteractionEnded(sheet: SheetInteraction, targetDetent: SheetInteractionInfo.Change)
}

/// Info relating to a sheet interaction event.
struct SheetInteractionInfo {

    struct Change {
        /// The relevant detent.
        let detent: UISheetPresentationController.Detent.Identifier
        /// Sheet's distance to specified `detent`, as measured from sheet's top edge.
        let distance: CGFloat
    }
    
    /// Equivalent to swiping down on a sheet stack.
    let isMinimizing: Bool
    
    /// - Parameter closestDetent: The detent with the shortest vertical distance from the top edge of a sheet stack. Sheet may or may not be moving away from this detent.
    let closest: Change
    /// - Parameter approachingDetent: This is `nil` if user interaction is stationary. Sheet may or may not end up resting at this detent, depending on sheet interaction velocity.
    let approaching: Change
    #warning("Rename var to `approachingFrom`?")
    /// The nearest detent a sheet's top edge is approaching *from*. For example: when moving from `small` to `medium`, preceding detent is `small`. Once sheet moves to `medium`, preceding will change to `medium`, even when user is actively interacting with sheet stack.
    let preceding: Change
    
    /// Use this value to interactively animate user-interface elements without having to check for interaction direction.
//    var percentageAnimating: CGFloat
    /// Interactive animation progress from preceding detent to approaching detent.
    let percentageApproaching: CGFloat
    /// Interactive animation progress from preceding detent.
    /// This added to `percentageApproaching` equals `1`.
    let percentagePreceding: CGFloat
}

/// - NOTE: Ensure *interactionGesture* recognizes simultaneously with all other gestures in `sheetView`.
final class SheetInteraction {
    
    weak var delegate: SheetInteractionDelegate?
    
    /// Controller managing a modal sheet stack.
    let sheet: UISheetPresentationController
    /// The root view associated with a sheet's `presentedViewController`. Be sure use the view that encompasses all subviews (e.g. navigation bars).
    let sheetView: UIView
    
    init(sheet: UISheetPresentationController, sheetView: UIView) {
        self.sheet = sheet
        self.sheetView = sheetView
        sheetView.addGestureRecognizer(sheetInteractionGesture)
    }
    
    /// The detent at which sheet interaction began.
    /// This value is available when sheet interaction is actively happening.
    private(set) var originDetent: UISheetPresentationController.Detent.Identifier?
    
    var currentDirections: UIPanGestureRecognizer.Directions {
        sheetInteractionGesture.directions
    }
    
    /// This allows callers to perform detent-specific percent-driven interactive animations.
    /// Calls `animationBlock` if sheet is currently greater than or equal to specified `detent`, but *is not* equal or greater to the next adjacent detent.
    func animating(_ detent: UISheetPresentationController.Detent.Identifier, interactionInfo: SheetInteractionInfo, animationBlock: (CGFloat) -> Void) {
        /// Check for `currentDirections` to ensure `animationBlock` only runs when sheet detent state is equal or greater than specified detent.
        if interactionInfo.approaching.detent == detent, currentDirections.contains(.down) {
            animationBlock(interactionInfo.percentagePreceding)
        } else if interactionInfo.preceding.detent == detent, currentDirections.contains(.up) {
            animationBlock(interactionInfo.percentageApproaching)
        } else {
            return
        }
    }
    
    /// The gesture used to track sheet interaction and detent state.
    /// This gesture must be configured to recognize simultaneously with all other gestures in `sheetView`.
    private(set) lazy var sheetInteractionGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleDetentPan(pan:)))
        gesture.name = "detentPan"
        return gesture
    }()
    
    /// Keep track of previous sheet height so we can use it on sheet interaction end.
    /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
    private lazy var sheetHeightOnPreviousChange: CGFloat = sheetView.frame.height - sheet.topSheetInsets.bottom
    
    @objc private func handleDetentPan(pan: UIPanGestureRecognizer) {
        guard let window = sheetView.window else {
            return
        }
        
        /// Track which detent is currently closest to the top edge of sheet statck.
        print(#function, "state: \(pan.state)")
        switch pan.state {
            /// Handling `.recognized` causes `.ended` to not register.... [2022.12]
//        case .recognized:
//            break
        case .began:
            originDetent = sheet.selectedDetentIdentifier ?? sheet.detents.first!.identifier
        case .changed:
            let directions = pan.directions
            guard directions.isStationary == false else {
                print("stationary...: \(pan.velocity(in: pan.view))")
                #if DEBUG
                fatalError()
                #else
                return
                #endif
            }
            let frame = sheetView.convert(sheetView.frame, from: window)
            let detents = sheet.detents
            let heights = detents.compactMap {
                let identifier = $0.identifier
                let detent = sheet.detents.first { $0.identifier == identifier }!
                let context = Context.init(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.maximumDetentValue())
                let detentHeight = detent.resolvedValue(in: context)!
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
                if directions.contains(.up) {
                    /// Sheet is moving up.
                    return detentsAbove.first ?? heights.last
                } else if directions.contains(.down) {
                    return detentsBelow.last ?? heights.first
                } else {
                    fatalError()
                }
            }()!
            let approachingDetent = approaching.0
            let approachingDistance = approaching.1
            /// Moving away from preceding detent, which may or may not be the detent at which sheet interaction began.
            let preceding = {
                if directions.contains(.up) {
                    /// Sheet is moving up.
                    return detentsBelow.last ?? heights.first
                } else if directions.contains(.down) {
                    return detentsAbove.first ?? heights.last
                } else {
                    fatalError()
                }
            }()!
            let precedingDetent = preceding.0
            let precedingDistance = preceding.1
            
            /// Keep track of previous sheet height so we can use it on sheet interaction end.
            /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
            let sheetHeight = frame.height - sheet.topSheetInsets.bottom
            print("sheetHeight: ", sheetHeight)
            sheetHeightOnPreviousChange = sheetHeight
            
            /// Percentage to approachingDetent, where 1 is closest to approachingDetent.
            #warning("Support overscroll values: Percentage is currently nan or inf on overscroll.")
            /// On overscroll at top, sheet height is briefly and slightly greater than maximumDetentValue.
            /// But on overscroll at bottom, sheet height stays at the smallest detent's value + safeAreaInset.bottom.
            /// We will need to use sheet.origin to calculate overscroll values.
            let percentageApproaching: CGFloat = {
                let precedingDetent = sheet.detents.first { $0.identifier == preceding.0 }!
                let precedingHeight = precedingDetent.resolvedValue(in: Context(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.maximumDetentValue()))!
                let approachingDetent = sheet.detents.first { $0.identifier == approaching.0 }!
                let approachingHeight = approachingDetent.resolvedValue(in: Context(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.maximumDetentValue()))!
                let d = abs(precedingHeight - approachingHeight)
                let percentage = 1 - (approachingDistance / d)
                return percentage
            }()
            print("percentage: \(percentageApproaching)")
            
            #warning("totalPercentage is never zero because height is never zero.")
            let totalPercentage = sheetHeight/sheet.maximumDetentValue()
            print("total percentage: \(totalPercentage)")
          
            let changeInfo = SheetInteractionInfo(
                isMinimizing: currentDirections.contains(.down),
                closest: .init(
                    detent: closest.0, distance: closest.1),
                approaching: .init(
                    detent: approachingDetent, distance: approachingDistance),
                preceding: .init(
                    detent: precedingDetent, distance: precedingDistance),
                percentageApproaching: percentageApproaching,
            percentagePreceding: 1 - percentageApproaching)
            delegate?.sheetInteractionChanged(sheet: self, info: changeInfo)
        case .ended, .cancelled, .failed:
            defer {
                originDetent = nil
            }
            let targetDetentIdentifier = sheet.selectedDetentIdentifier ?? sheet.detents.first!.identifier
            let targetDetent = sheet.detents.first { $0.identifier == targetDetentIdentifier }
            guard let detentHeight = targetDetent?.resolvedValue(in: Context(containerTraitCollection: sheet.traitCollection, maximumDetentValue: sheet.maximumDetentValue())) else {
                return
            }
            let sheetHeight = sheetHeightOnPreviousChange
            let totalPercentage = sheetHeight/sheet.maximumDetentValue()
            print("total percentage: \(totalPercentage)")
            let targetDistance = abs(sheetHeight - detentHeight)
            delegate?.sheetInteractionEnded(sheet: self, targetDetent: .init(
                detent: targetDetentIdentifier, distance: targetDistance))
        default:
            break
        }
    }
}
