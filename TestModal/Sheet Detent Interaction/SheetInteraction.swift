//
//  SheetInteraction.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-06.
//

import UIKit

/// Emit sheet interaction events.
public protocol SheetInteractionDelegate: AnyObject {
    func sheetInteractionChanged(sheet: SheetInteraction, interactionInfo: SheetInteraction.Change)
    
    /// - Parameter targetDetent: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    /// - Parameter percentageTotal: See `SheetInteractionInfo.percentageTotal`.
    func sheetInteractionEnded(sheet: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, percentageTotal: CGFloat)
}

/// - NOTE: Ensure *interactionGesture* recognizes simultaneously with all other gestures in `sheetView`.
public final class SheetInteraction {
    
    /// Layout info relating to a detent during sheet interaction.
    /// - Parameter identifier: Info pertaining to this detent.
    /// - Parameter absDistance: Absolute distance in screen points to this detent for the current sheet interaction.
    /// - Parameter distance: Distance (including magnitude), where negative values indicate higher up detents (and vice-versa).
    /// - Parameter origin: Origin of the top edge of this detent in the window's coordinate space.
    private typealias DetentLayoutInfo = (identifier: UISheetPresentationController.Detent.Identifier, absDistance: CGFloat, distance: CGFloat, origin: CGPoint)
    
    weak public var delegate: SheetInteractionDelegate?
    
    /// Controller managing a modal sheet stack.
    public let sheetController: UISheetPresentationController
    /// The root view associated with a sheet's `presentedViewController`. Be sure use the view that encompasses all subviews (e.g. navigation bars).
    public let sheetView: UIView
    public let sheetWindow: UIWindow
    public let sheetLayoutInfo: SheetLayoutInfo
    
    /// - Parameter sheetView: Must already be added to view hierarchy connected to a window.
    public init(sheet: UISheetPresentationController, sheetView: UIView, sheetWindow: UIWindow) {
        self.sheetController = sheet
        self.sheetView = sheetView
        self.sheetWindow = sheetWindow
        self.sheetLayoutInfo = .init(sheet: sheetController, sheetView: sheetView, window: sheetWindow)
        sheetView.addGestureRecognizer(sheetInteractionGesture)
    }
    
    /// The detent at which sheet interaction began.
    /// This value is available when sheet interaction is actively happening.
    private(set) public var originDetent: UISheetPresentationController.Detent.Identifier?
    
    public var currentDirections: UIPanGestureRecognizer.Directions {
        sheetInteractionGesture.directions
    }
    
    public var isMinimizing: Bool {
        currentDirections.contains(.down)
    }
    
    /// This allows callers to perform detent-specific percent-driven interactive animations.
    /// Calls `animationBlock` if sheet is currently greater than or equal to specified `detent`, but *is not* equal or greater to the next adjacent detent.
    public func animating(_ detent: UISheetPresentationController.Detent.Identifier, interactionInfo: Change, animationBlock: (CGFloat) -> Void) {
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
    private(set) public lazy var sheetInteractionGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleSheetInteraction(pan:)))
        gesture.name = "detentPan"
        return gesture
    }()
    
    /// Keep track of previous sheet height so we can use it on sheet interaction end.
    private lazy var sheetFrameInWindowOnPreviousChange: CGRect = sheetLayoutInfo.sheetFrameInWindow
    /// Keep track of previous sheet height so we can use it on sheet interaction end.
    /// On sheet interaction end, sheet height is already updated to reflect final state, so we can't calculate target distance using that final value.
    private lazy var sheetHeightOnPreviousChange: CGFloat = sheetLayoutInfo.sheetHeightInSafeArea
    
    @objc private func handleSheetInteraction(pan: UIPanGestureRecognizer) {
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
            
            let sheetFrameInWindow = sheetLayoutInfo.sheetFrameInWindow
            sheetFrameInWindowOnPreviousChange = sheetFrameInWindow

            let detents = sheetController.detents
            let detentsLayoutInfo = detentsLayoutInfo(detents: detents)
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
            let sheetHeight = sheetLayoutInfo.sheetHeightInSafeArea
            print("sheetHeight: ", sheetHeight)
            sheetHeightOnPreviousChange = sheetHeight
            
            /// Percentage to approachingDetent, where 1 is closest to approachingDetent.
            /// On overscroll at top, sheet height is briefly and slightly greater than maximumDetentValue.
            /// But on overscroll at bottom, sheet height stays at the smallest detent's value + safeAreaInset.bottom.
            /// We will need to use sheet.origin to calculate overscroll values.
            let percentageApproaching: CGFloat = {
                let precedingDetent = sheetController.detent(withIdentifier: preceding.identifier)!
                let precedingHeight = precedingDetent.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue()))!
                let approachingDetent = sheetController.detent(withIdentifier: approaching.identifier)!
                let approachingHeight = approachingDetent.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue()))!
                let d = abs(precedingHeight - approachingHeight)
                let percentage = 1 - (approachingDistance / d)
                return percentage
            }()
            let percentagePreceding = 1 - percentageApproaching
            print("percentage: \(percentageApproaching)")
            
            let totalPercentageUsingHeight = sheetHeight/sheetLayoutInfo.maximumDetentValue()
            /// This method supports overscroll values.
            /// Note that this is a global percentage capped by the smallest and largest detents.
            let totalPercentageUsingOrigin = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindow)
            print("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOrigin)")

            let changeInfo = Change(
                isMinimizing: isMinimizing,
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
            guard let detentHeight = targetDetent?.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())) else {
                return
            }
            
            /// Note we are using *previous* sheet height/frame (i.e. the previous values on .change).
            let sheetHeight = sheetHeightOnPreviousChange
            let totalPercentageUsingHeight = sheetHeight/sheetLayoutInfo.maximumDetentValue()
            let totalPercentageUsingOriginOnTouchUp = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindowOnPreviousChange)
            
            let sheetFrameInWindow = sheetWindow.convert(sheetView.frame, from: sheetView)
            let totalPercentageUsingOriginTargetting = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindow)
            let targetDistance = abs(sheetHeight - detentHeight)
            print("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOriginOnTouchUp) --> targetting: \(totalPercentageUsingOriginTargetting)")

            delegate?.sheetInteractionEnded(sheet: self, targetDetentInfo: .init(
                detentIdentifier: targetDetentIdentifier, distance: targetDistance), percentageTotal: totalPercentageUsingOriginTargetting)
        default:
            break
        }
    }
}

// MARK: - Layout Info (Detents)
private extension SheetInteraction {
    
    /// Generate layout info relating to the current sheet interaction for the specified detents.
    /// - Warning: Do not pass inactive detents.
    /// - Parameter sheetWindow: Window in which sheet statck is presented.
    /// - Parameter detents: Do not pass inactive detents.
    private func detentsLayoutInfo(detents: [UISheetPresentationController.Detent]) -> [DetentLayoutInfo] {
        let sheetFrameInWindow = sheetWindow.convert(sheetView.frame, from: sheetView)
        return detents.compactMap { detent in
            let identifier = detent.identifier
            let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())
#warning("Handle deactivated detent(s).")
            let detentHeight = detent.resolvedValue(in: context)!
            /// Exclude sheet height outside safe area (bottom edge attached).
            let sheetHeight = sheetFrameInWindow.height - sheetLayoutInfo.topSheetInsets.bottom
            let distance = sheetHeight - detentHeight
            let detentHeightIncludingInsets = detentHeight + sheetLayoutInfo.topSheetInsets.bottom
            let yOrigin = sheetWindow.frame.height - detentHeightIncludingInsets
            /// 0: detent identifier, 1: distance to detent, 2: negative values indicate higher up detents (and vice-versa).
            return (identifier: identifier, absDistance: abs(distance), distance: distance, origin: CGPoint(x: 0, y: yOrigin))
        }
    }
}

// MARK: - Animation Percentages
private extension SheetInteraction {
    
    /// Calculate the total percentage travelled from the smallest detent to the largest detent.
    ///
    /// Negative values indicate overscrolling past the smallest detent.
    /// Positive values indicate overscrolling past the largest detent.
    /// - Parameter sheetLayoutInfo: Use the values in this layout info to calculate the total percentage.
    /// - Parameter sheetFrame: If `nil`, uses the current sheet frame from `sheetLayoutInfo`. Specify an alternate value to calculate a, for example, previous total percentage.
    private func totalPercentageWithOrigin(sheetLayoutInfo: SheetLayoutInfo, sheetFrame: CGRect?) -> CGFloat {
        let sheetFrame = sheetFrame ?? sheetLayoutInfo.sheetFrameInWindow
        let maxDetentValue = sheetLayoutInfo.maximumDetentValue()
        let y = sheetFrame.origin.y - sheetLayoutInfo.topSheetInsets.top
        let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())
        let smallestDetentValue = sheetController
            .detent(withIdentifier: sheetController.detents.first!.identifier)!
            .resolvedValue(in: context)!
        /// Subtract value of smallest detent so that we get a range between 0-1, where 0 corresponds to smallest, and 1 to largest detent.
        /// This method means the in-between values will not correspond to any multiples specified in a detent's resolver closure (e.g. context.maximumDetentValue `*` 0.5).
        let p = y/(maxDetentValue-smallestDetentValue)
        return 1 - p
    }
}
