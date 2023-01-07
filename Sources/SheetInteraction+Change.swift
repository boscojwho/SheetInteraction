//
//  SheetInteraction+Change.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-12.
//

import UIKit

public extension SheetInteraction {
    
    /// Info relating to a sheet interaction event.
    struct Change {
        
        public struct Info {
            /// The relevant detent.
            public let detentIdentifier: DetentIdentifier
            /// Sheet's distance to specified `detentIdentifier`, as measured from sheet's top edge.
            public let distance: CGFloat
        }
        
        /// Equivalent to swiping down on a sheet stack.
        public let isMinimizing: Bool
        
        /// i.e. rubberbanding.
        public let isOverscrolling: Bool
        
        /// - Parameter closestDetent: The detent with the shortest vertical distance from the top edge of a sheet stack. Sheet may or may not be moving away from this detent.
        public let closest: Info
        /// - Parameter approachingDetent: This is `nil` if user interaction is stationary. Sheet may or may not end up resting at this detent, depending on sheet interaction velocity.
        public let approaching: Info
#warning("Rename var to `approachingFrom`?")
        /// The nearest detent a sheet's top edge is approaching *from*. For example: when moving from `small` to `medium`, preceding detent is `small`. Once sheet moves to `medium`, preceding will change to `medium`, even when user is actively interacting with sheet stack.
        public let preceding: Info
        
        /// From 0-1, this value represents where a sheet is at relative to its smallest detent, where 1 is the largest detent.
        ///
        /// - Warning: Currently, this value is not calculated relative to a sheet's `maximumDetentValue`. In other words, `detent.resolutionContext.maximumDetentValue * 0.5` does not equal `percentageTotal = 0.5`.
        public let percentageTotal: CGFloat
        /// Interactive animation progress from preceding detent to approaching detent.
        ///
        /// On overscroll, returns `-1`.
        public let percentageApproaching: CGFloat
        /// Interactive animation progress from preceding detent.
        /// This added to `percentageApproaching` equals `1`.
        ///
        /// On overscroll, returns `-1`.
        public let percentagePreceding: CGFloat
    }
}
