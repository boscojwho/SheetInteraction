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
    func sheetInteractionChanged(sheet: SheetInteraction, interactionInfo: SheetInteractionInfo)
    
    /// - Parameter targetDetent: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    /// - Parameter percentageTotal: See `SheetInteractionInfo.percentageTotal`.
    func sheetInteractionEnded(sheet: SheetInteraction, targetDetentInfo: SheetInteractionInfo.Change, percentageTotal: CGFloat)
}

/// Info relating to a sheet interaction event.
struct SheetInteractionInfo {

    struct Change {
        /// The relevant detent.
        let detentIdentifier: UISheetPresentationController.Detent.Identifier
        /// Sheet's distance to specified `detentIdentifier`, as measured from sheet's top edge.
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
    
    /// From 0-1, this value represents where a sheet is at relative to its smallest detent, where 1 is the largest detent.
    let percentageTotal: CGFloat
    /// Interactive animation progress from preceding detent to approaching detent.
    let percentageApproaching: CGFloat
    /// Interactive animation progress from preceding detent.
    /// This added to `percentageApproaching` equals `1`.
    let percentagePreceding: CGFloat
}

/// - NOTE: Ensure *interactionGesture* recognizes simultaneously with all other gestures in `sheetView`.
final class SheetInteraction {
    
    /// Layout info relating to a detent during sheet interaction.
    /// - Parameter identifier: Info pertaining to this detent.
    /// - Parameter absDistance: Absolute distance in screen points to this detent for the current sheet interaction.
    /// - Parameter distance: Distance (including magnitude), where negative values indicate higher up detents (and vice-versa).
    /// - Parameter origin: Origin of the top edge of this detent in the window's coordinate space.
    private typealias DetentLayoutInfo = (identifier: UISheetPresentationController.Detent.Identifier, absDistance: CGFloat, distance: CGFloat, origin: CGPoint)
    
    weak var delegate: SheetInteractionDelegate?
    
    /// Controller managing a modal sheet stack.
    let sheetController: UISheetPresentationController
    /// The root view associated with a sheet's `presentedViewController`. Be sure use the view that encompasses all subviews (e.g. navigation bars).
    let sheetView: UIView
    
    init(sheet: UISheetPresentationController, sheetView: UIView) {
        self.sheetController = sheet
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
        if interactionInfo.approaching.detentIdentifier == detent, currentDirections.contains(.down) {
            animationBlock(interactionInfo.percentagePreceding)
        } else if interactionInfo.preceding.detentIdentifier == detent, currentDirections.contains(.up) {
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
    
    private lazy var sheetFrameInWindowOnPreviousChange: CGRect = sheetView.window!.convert(sheetView.frame, to: sheetView.window!)
    /// Keep track of previous sheet height so we can use it on sheet interaction end.
    /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
    private lazy var sheetHeightOnPreviousChange: CGFloat = sheetView.frame.height - sheetController.topSheetInsets.bottom
    
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
            originDetent = sheetController.identifierForSelectedDetent()
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
            
            let sheetFrameInWindow = window.convert(sheetView.frame, from: sheetView)
            sheetFrameInWindowOnPreviousChange = sheetFrameInWindow

            let detents = sheetController.detents
            let detentsLayoutInfo = detentsLayoutInfo(sheetWindow: window, detents: detents)
            /// Detents with a negative distance are higher than sheet's current position (i.e. need to drag up).
            let detentsAbove = detentsLayoutInfo.filter { $0.distance <= 0 }
            /// Detents with a positive distance are lower than sheet's current position (i.e. need to drag down).
            let detentsBelow = detentsLayoutInfo.filter { $0.distance > 0 }
            
            /// Closest in terms of distance, not accounting for sheet momemtum, which may cause sheet to rest at a further detent.
            let closest = detentsLayoutInfo.sorted { $0.absDistance < $1.absDistance }.first!
            let closestDetent = closest.identifier
            let closestDistance = closest.absDistance
            
            /// This may or may not be the same as `closest`.
            let approaching = {
                if directions.contains(.up) {
                    /// Sheet is moving up.
                    return detentsAbove.first ?? detentsLayoutInfo.last
                } else if directions.contains(.down) {
                    return detentsBelow.last ?? detentsLayoutInfo.first
                } else {
                    fatalError()
                }
            }()!
            let approachingDetent = approaching.identifier
            let approachingDistance = approaching.absDistance
            
            /// Moving away from preceding detent, which may or may not be the detent at which sheet interaction began.
            let preceding = {
                if directions.contains(.up) {
                    /// Sheet is moving up.
                    return detentsBelow.last ?? detentsLayoutInfo.first
                } else if directions.contains(.down) {
                    return detentsAbove.first ?? detentsLayoutInfo.last
                } else {
                    fatalError()
                }
            }()!
            let precedingDetent = preceding.identifier
            let precedingDistance = preceding.absDistance
            
            /// Keep track of previous sheet height so we can use it on sheet interaction end.
            /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
            let sheetHeight = sheetFrameInWindow.height - sheetController.topSheetInsets.bottom
            print("sheetHeight: ", sheetHeight)
            sheetHeightOnPreviousChange = sheetHeight
            
            /// Percentage to approachingDetent, where 1 is closest to approachingDetent.
            #warning("Support overscroll values: Percentage is currently nan or inf on overscroll.")
            /// On overscroll at top, sheet height is briefly and slightly greater than maximumDetentValue.
            /// But on overscroll at bottom, sheet height stays at the smallest detent's value + safeAreaInset.bottom.
            /// We will need to use sheet.origin to calculate overscroll values.
            let percentageApproaching: CGFloat = {
                let precedingDetent = sheetController.detent(withIdentifier: preceding.identifier)!
                let precedingHeight = precedingDetent.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue()))!
                let approachingDetent = sheetController.detent(withIdentifier: approaching.identifier)!
                let approachingHeight = approachingDetent.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue()))!
                let d = abs(precedingHeight - approachingHeight)
                let percentage = 1 - (approachingDistance / d)
                return percentage
            }()
            let percentagePreceding = 1 - percentageApproaching
            print("percentage: \(percentageApproaching)")
            
            #warning("totalPercentage is never zero because height is never zero.")
            let totalPercentageUsingHeight = sheetHeight/sheetController.maximumDetentValue()
            /// This method supports overscroll values.
            /// Note that this is a global percentage capped by the smallest and largest detents.
            let totalPercentageUsingOrigin = {
                let maxDetentValue = sheetController.maximumDetentValue()
                let y = sheetFrameInWindow.origin.y - sheetController.topSheetInsets.top
                let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue())
                let smallestDetentValue = sheetController
                    .detent(withIdentifier: sheetController.detents.first!.identifier)!
                    .resolvedValue(in: context)!
                /// Subtract value of smallest detent so that we get a range between 0-1, where 0 corresponds to smallest, and 1 to largest detent.
                /// This method means the in-between values will not correspond to any multiples specified in a detent's resolver closure (e.g. context.maximumDetentValue `*` 0.5).
                let p = y/(maxDetentValue-smallestDetentValue)
                return 1 - p
            }()
            print("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOrigin)")

            let changeInfo = SheetInteractionInfo(
                isMinimizing: currentDirections.contains(.down),
                closest: .init(
                    detentIdentifier: closestDetent, distance: closestDistance),
                approaching: .init(
                    detentIdentifier: approachingDetent, distance: approachingDistance),
                preceding: .init(
                    detentIdentifier: precedingDetent, distance: precedingDistance),
                percentageTotal: totalPercentageUsingOrigin, percentageApproaching: percentageApproaching,
                percentagePreceding: percentagePreceding)
            delegate?.sheetInteractionChanged(sheet: self, interactionInfo: changeInfo)
        case .ended, .cancelled, .failed:
            defer {
                originDetent = nil
            }
            let targetDetentIdentifier = sheetController.identifierForSelectedDetent()
            let targetDetent = sheetController.detent(withIdentifier: targetDetentIdentifier)
            guard let detentHeight = targetDetent?.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue())) else {
                return
            }
            let sheetHeight = sheetHeightOnPreviousChange
            let totalPercentageUsingHeight = sheetHeight/sheetController.maximumDetentValue()
            let totalPercentageUsingOriginOnTouchUp = totalPercentageWithOrigin(sheetFrame: sheetFrameInWindowOnPreviousChange)
            
            let sheetFrameInWindow = window.convert(sheetView.frame, from: sheetView)
            let totalPercentageUsingOriginTargetting = totalPercentageWithOrigin(sheetFrame: sheetFrameInWindow)
            print("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOriginOnTouchUp) --> targetting: \(totalPercentageUsingOriginTargetting)")
            let targetDistance = abs(sheetHeight - detentHeight)
            delegate?.sheetInteractionEnded(sheet: self, targetDetentInfo: .init(
                detentIdentifier: targetDetentIdentifier, distance: targetDistance), percentageTotal: totalPercentageUsingOriginTargetting)
        default:
            break
        }
    }
}

extension SheetInteraction {
    
    ///
    private func detentsLayoutInfo(sheetWindow: UIWindow, detents: [UISheetPresentationController.Detent]) -> [DetentLayoutInfo] {
        let sheetFrameInWindow = sheetWindow.convert(sheetView.frame, from: sheetView)
        return detents.compactMap { detent in
            let identifier = detent.identifier
            let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue())
#warning("Handle deactivated detent(s).")
            let detentHeight = detent.resolvedValue(in: context)!
            /// Exclude sheet height outside safe area (bottom edge attached).
            let sheetHeight = sheetFrameInWindow.height - sheetController.topSheetInsets.bottom
            let distance = sheetHeight - detentHeight
            let detentHeightIncludingInsets = detentHeight + sheetController.topSheetInsets.bottom
            let yOrigin = sheetWindow.frame.height - detentHeightIncludingInsets
            /// 0: detent identifier, 1: distance to detent, 2: negative values indicate higher up detents (and vice-versa).
            return (identifier: identifier, absDistance: abs(distance), distance: distance, origin: CGPoint(x: 0, y: yOrigin))
        }
    }
}

extension SheetInteraction {
    
    private func totalPercentageWithOrigin(sheetFrame: CGRect) -> CGFloat {
        let maxDetentValue = sheetController.maximumDetentValue()
        let y = sheetFrame.origin.y - sheetController.topSheetInsets.top
        let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetController.maximumDetentValue())
        let smallestDetentValue = sheetController
            .detent(withIdentifier: sheetController.detents.first!.identifier)!
            .resolvedValue(in: context)!
        /// Subtract value of smallest detent so that we get a range between 0-1, where 0 corresponds to smallest, and 1 to largest detent.
        /// This method means the in-between values will not correspond to any multiples specified in a detent's resolver closure (e.g. context.maximumDetentValue `*` 0.5).
        let p = y/(maxDetentValue-smallestDetentValue)
        return 1 - p
    }
    
    private func detentOrigins() -> [(detent: UISheetPresentationController.Detent, origin: CGPoint)] {
        guard let window = sheetView.window else {
            return []
        }
        let detents = sheetController.detents
        let origins = detents.compactMap { detent in
            let context = Context(containerTraitCollection: sheetView.traitCollection, maximumDetentValue: sheetController.maximumDetentValue())
            let detentHeightIncludingInsets = detent.resolvedValue(in: context)! + sheetController.topSheetInsets.bottom
            let yOrigin = window.frame.height - detentHeightIncludingInsets
            return (detent: detent, origin: CGPoint(x: 0, y: yOrigin))
        }
        return origins
    }
}
