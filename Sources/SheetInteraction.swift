//
//  SheetInteraction.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-06.
//

import UIKit
import os

public typealias Detent = UISheetPresentationController.Detent
public typealias DetentIdentifier = UISheetPresentationController.Detent.Identifier

/// Emit sheet interaction events.
public protocol SheetInteractionDelegate: AnyObject {
    /// Optional: Default implementation is no-op.
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier)
    
    /// Stationary and x-axis change events are not emitted.
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change)
    
    /// Use this event to perform animation to the target detent.
    /// Called on touch up.  This event may be skipped if user quickly begins and ends sheet interaction (i.e. with a quick flick). See `SheetInteraction.isEnding`.
    /// - Parameter targetDetentInfo: Sheet is either animating (or animated) to its target detent after user interaction has ended.
    /// - Parameter targetPercentageTotal: The target detent's `resolvedValue` as a percentage of the sheet's `maximumDetentValue`, where 0 is the smallest detent.  Overscroll values are reported.  See `SheetInteraction.Change.percentageTotal`.
    /// - Parameter onTouchUpPercentageTotal: Sheet's percentageTotal animated the moment sheet interaction ends (i.e. on "touch up").
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat)
    
    /// Use this event to finalize any user-interface state and/or appearance when sheet finishes animating to its selected detent.
    /// Called when `UISheetPresentationController` finishes (or is close to) animating to a new selected detent.
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier)
}

public extension SheetInteractionDelegate {
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        /// no-op.
    }
}

/// - NOTE: Ensure *interactionGesture* recognizes simultaneously with all other gestures in `sheetView`.
public final class SheetInteraction: NSObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SheetInteraction.self)
    )
    
    /// Layout info relating to a detent during sheet interaction.
    /// - Parameter identifier: Info pertaining to this detent.
    /// - Parameter absDistance: Absolute distance in screen points to this detent for the current sheet interaction.
    /// - Parameter distance: Distance (including magnitude), where negative values indicate higher up detents (and vice-versa).
    /// - Parameter origin: Origin of the top edge of this detent in the window's coordinate space.
    private typealias DetentLayoutInfo = (identifier: DetentIdentifier, absDistance: CGFloat, distance: CGFloat, origin: CGPoint)
    
    weak public var delegate: SheetInteractionDelegate?
    
    /// Controller managing a modal sheet stack.
    public let sheetController: UISheetPresentationController
    /// The root view associated with a sheet's `presentedViewController`. Be sure use the view that encompasses all subviews (e.g. navigation bars).
    public let sheetView: UIView
    public private(set) lazy var sheetWindow: UIWindow = sheetView.window!
    public private(set) lazy var sheetLayoutInfo: SheetLayoutInfo = .init(sheet: sheetController, sheetView: sheetView, window: sheetWindow)
        
    public init(sheet: UISheetPresentationController, sheetView: UIView) {
        self.sheetController = sheet
        self.sheetView = sheetView
        
        super.init()
        
        sheetController.delegate = self
        sheetView.addGestureRecognizer(sheetInteractionGesture)
    }
    
    /// The detent at which sheet interaction began.
    /// This value is available when sheet interaction is actively happening.
    private(set) public var originDetent: DetentIdentifier?
    
    public var currentDirections: UIPanGestureRecognizer.Directions {
        sheetInteractionGesture.directions
    }
    
    public var isMinimizing: Bool {
        currentDirections.contains(.down)
    }
    
    /// Is `true` between `willEnd` and `didEnd` states.
    ///
    /// On rare occasions, `willEnd` state is skipped when user quickly begins then ends sheet interaction (i.e. with a quick flick). In this case, the `willEnd` event is not emitted to the delegate, and `didEnd` event is immediately emitted.
    /// - NOTE: This is set immediately before calling relevant delegate methods.
    public private(set) var isEnding: Bool = false
    
    /// This allows callers to perform detent-specific percent-driven interactive animations.
    /// Calls `animationBlock` if sheet is currently greater than or equal to specified `detent`, but *is not* equal or greater to the next adjacent detent.
    /// - Parameter animationBlock : The `percentageAnimating` is always reported such that its value approaches `1` when sheet is moving up, and vice-versa.
    public func animating(_ detent: DetentIdentifier, interactionChange: Change, animationBlock: (CGFloat) -> Void) {
        /// Check for `currentDirections` to ensure `animationBlock` only runs when sheet detent state is equal or greater than specified detent.
        if interactionChange.approaching.detentIdentifier == detent, currentDirections.contains(.down) {
            animationBlock(interactionChange.percentagePreceding)
        } else if interactionChange.preceding.detentIdentifier == detent, currentDirections.contains(.up) {
            animationBlock(interactionChange.percentageApproaching)
        } else {
            return
        }
    }
    
    public func totalPercentageAnimated() -> CGFloat {
        totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetLayoutInfo.sheetFrameInWindow)
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
        Self.logger.debug("\(#function) - \(pan.state.rawValue)")
        switch pan.state {
            /// Handling `.recognized` causes `.ended` to not register.... [2022.12]
//        case .recognized:
//            break
        case .began:
            handleSheetInteractionBegan()
        case .changed:
            handleSheetInteractionChanged(pan: pan)
        case .ended, .cancelled, .failed:
#if DEBUG
            if pan.state == .cancelled {
                Self.logger.debug("Sheet interaction finished with gesture cancellation.")
            } else if pan.state == .failed {
                Self.logger.debug("Sheet interaction finished with gesture failure.")
            }
#endif
            /// Run on next layout cycle to ensure layout info is correct.
            /// When sheet interaction begins on a descendant scroll view, sheet layout info does not match the selected detent when UIKit notifies us. [2022.12]
            Task { @MainActor in
                handleSheetInteractionWillEnd()
            }
        default:
            break
        }
    }
    
    private func handleSheetInteractionBegan() {
        let detentBegan = sheetController.identifierForSelectedDetent()
        originDetent = detentBegan
        delegate?.sheetInteractionBegan(sheetInteraction: self, at: detentBegan)
    }
    
    private func handleSheetInteractionChanged(pan: UIPanGestureRecognizer) {
        let directions = pan.directions
        guard directions.isStationary == false else {
            Self.logger.debug("stationary...: \(pan.velocity(in: pan.view).debugDescription)")
#if DEBUG
            fatalError()
#else
            return
#endif
        }
        
        let sheetFrameInWindow = sheetLayoutInfo.sheetFrameInWindow
        sheetFrameInWindowOnPreviousChange = sheetFrameInWindow
        
        let detents = sheetController.detents
        let detentsLayoutInfo = activeDetentsLayoutInfo(detents: detents)
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
        Self.logger.debug("sheetHeight: \(sheetHeight)")
        sheetHeightOnPreviousChange = sheetHeight
        
        /// Percentage to approachingDetent, where 1 is closest to approachingDetent.
        /// On overscroll at top, sheet height is briefly and slightly greater than maximumDetentValue.
        /// But on overscroll at bottom, sheet height stays at the smallest detent's value + safeAreaInset.bottom.
        /// We will need to use sheet.origin to calculate overscroll values.
        let percentageApproaching: CGFloat = {
            let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())
            let precedingDetent = sheetController.detent(withIdentifier: preceding.identifier)!
            let precedingHeight = precedingDetent.resolvedValue(in: context)!
            let approachingDetent = sheetController.detent(withIdentifier: approaching.identifier)!
            let approachingHeight = approachingDetent.resolvedValue(in: context)!
            let d = abs(precedingHeight - approachingHeight)
            let percentage = 1 - (approachingDistance / d)
            return percentage
        }()
        let percentagePreceding = 1 - percentageApproaching
        Self.logger.debug("percentage: \(percentageApproaching)")
        
        let totalPercentageUsingHeight = sheetHeight/sheetLayoutInfo.maximumDetentValue()
        /// This method supports overscroll values.
        /// Note that this is a global percentage capped by the smallest and largest detents.
        let totalPercentageUsingOrigin = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindow)
        Self.logger.debug("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOrigin)")
        
        let changeInfo = Change(
            isMinimizing: isMinimizing,
            closest: .init(
                detentIdentifier: closestDetent, distance: closestDistance),
            approaching: .init(
                detentIdentifier: approachingDetent, distance: approachingDistance),
            preceding: .init(
                detentIdentifier: precedingDetent, distance: precedingDistance),
            percentageTotal: totalPercentageUsingOrigin,
            percentageApproaching: percentageApproaching,
            percentagePreceding: percentagePreceding)
        delegate?.sheetInteractionChanged(sheetInteraction: self, interactionChange: changeInfo)
    }
    
    private func handleSheetInteractionWillEnd() {
        defer {
            originDetent = nil
        }
        let targetDetentIdentifier = sheetController.identifierForSelectedDetent()
        let targetDetent = sheetController.detent(withIdentifier: targetDetentIdentifier)
        /// We will assume that the target detent is active, since this value is provided by UIKit.
#if DEBUG
        guard let detentHeight = targetDetent?.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())) else {
            fatalError("Target detent's resolved value should not be nil.")
        }
#else
        let detentHeight = targetDetent!.resolvedValue(in: Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue()))!
#endif
        
        /// Note we are using *previous* sheet height/frame (i.e. the previous values on .change).
        let sheetHeight = sheetHeightOnPreviousChange
        let totalPercentageUsingHeight = sheetHeight/sheetLayoutInfo.maximumDetentValue()
        let totalPercentageUsingOriginOnTouchUp = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindowOnPreviousChange)
        
        let sheetFrameInWindow = sheetWindow.convert(sheetView.frame, from: sheetView)
        let totalPercentageUsingOriginTargetting = totalPercentageWithOrigin(sheetLayoutInfo: sheetLayoutInfo, sheetFrame: sheetFrameInWindow)
        let targetDistance = abs(sheetHeight - detentHeight)
        Self.logger.debug("total percentage [height]: \(totalPercentageUsingHeight), [yOrigin]: \(totalPercentageUsingOriginOnTouchUp) --> targetting: \(totalPercentageUsingOriginTargetting) (\(targetDetentIdentifier.rawValue))")
        
        isEnding = true
        delegate?.sheetInteractionWillEnd(sheetInteraction: self, targetDetentInfo: .init(
            detentIdentifier: targetDetentIdentifier, distance: targetDistance), targetPercentageTotal: totalPercentageUsingOriginTargetting, onTouchUpPercentageTotal: totalPercentageUsingOriginOnTouchUp)
    }
    
    private func handleSheetInteractionDidEnd(identifier: UISheetPresentationController.Detent.Identifier) {
#if DEBUG
        if isEnding == false {
            Self.logger.debug("Sheet interaction ended without call to willEnd.")
        }
#endif
        Self.logger.debug("percentage: \(self.totalPercentageAnimated())")
        isEnding = false
        delegate?.sheetInteractionDidEnd(sheetInteraction: self, selectedDetentIdentifier: identifier)
    }
}

// MARK: - Layout Info (Detents)
private extension SheetInteraction {
    
    /// Generate layout info relating to the current sheet interaction for the specified detents.
    /// - Warning: Do not pass inactive detents.
    /// - Parameter sheetWindow: Window in which sheet statck is presented.
    /// - Parameter detents: Do not pass inactive detents.
    /// - Returns: Layout info for **active** detents only.
    private func activeDetentsLayoutInfo(detents: [UISheetPresentationController.Detent]) -> [DetentLayoutInfo] {
        let sheetFrameInWindow = sheetWindow.convert(sheetView.frame, from: sheetView)
        return detents.compactMap { detent in
            let identifier = detent.identifier
            let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())
            guard let detentHeight = detent.resolvedValue(in: context) else {
                Self.logger.debug("Encountered inactive detent while generating layout info: \(detent.identifier.rawValue)")
                return nil
            }
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
        let context = Context(containerTraitCollection: sheetController.traitCollection, maximumDetentValue: sheetLayoutInfo.maximumDetentValue())
        guard let smallestDetentValue = sheetController.smallestActiveDetent().resolvedValue(in: context) else {
            #if DEBUG
            fatalError("Illegal state: An active detent cannot have a `resolvedValue == nil`.")
            #else
            return 0
            #endif
        }
        let sheetFrame = sheetFrame ?? sheetLayoutInfo.sheetFrameInWindow
        let maxDetentValue = sheetLayoutInfo.maximumDetentValue()
        let y = sheetFrame.origin.y - sheetLayoutInfo.topSheetInsets.top
        /// Subtract value of smallest detent so that we get a range between 0-1, where 0 corresponds to smallest, and 1 to largest detent.
        /// This method means the in-between values will not correspond to any multiples specified in a detent's resolver closure (e.g. context.maximumDetentValue `*` 0.5).
        let p = y/(maxDetentValue-smallestDetentValue)
        return 1 - p
    }
}

extension SheetInteraction: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        Self.logger.debug("\(sheetPresentationController.presentedViewController) -> \(sheetPresentationController.identifierForSelectedDetent().rawValue)")
        /// Run on next layout cycle to ensure layout info is correct.
        /// When sheet interaction begins on a descendant scroll view, sheet layout info does not match the selected detent when UIKit notifies us. [2022.12]
        Task { @MainActor in
            handleSheetInteractionDidEnd(identifier: sheetPresentationController.selectedDetentIdentifier ?? sheetPresentationController.identifierForSmallestDetent())
        }
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if let sheet = presentationController as? UISheetPresentationController {
            Self.logger.debug("\(sheet.presentedViewController) -> \(sheet.identifierForSelectedDetent().rawValue)")
        }
        return (delegate as? UISheetPresentationControllerDelegate)?.presentationControllerShouldDismiss?(presentationController) ?? true
    }
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        if let sheet = presentationController as? UISheetPresentationController {
            Self.logger.debug("\(sheet.presentedViewController) -> \(sheet.identifierForSelectedDetent().rawValue)")
        }
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let sheet = presentationController as? UISheetPresentationController {
            Self.logger.debug("\(sheet.presentedViewController) -> \(sheet.identifierForSelectedDetent().rawValue)")
        }
    }
    
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if let sheet = presentationController as? UISheetPresentationController {
            Self.logger.debug("\(sheet.presentedViewController) -> \(sheet.identifierForSelectedDetent().rawValue)")
        }
    }
}
