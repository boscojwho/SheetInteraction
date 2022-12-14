//
//  Sheet+Detents.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-12.
//

import UIKit

// MARK: - Detents
public extension UISheetPresentationController {
    
    /// - Returns: First detent in `detents`, instead of `nil`.
    func identifierForSelectedDetent() -> Detent.Identifier {
        selectedDetentIdentifier ?? detents.first!.identifier
    }
    
    func detent(withIdentifier identifier: Detent.Identifier) -> Detent? {
        detents.first { $0.identifier == identifier }
    }
    
    /// By default, looks for the smallest *active* detent.
    /// Assumes detents is non-nil and ordered from smallest to largest, as specified by UIKit documentation.
    func identifierForSmallestDetent(active: Bool = true) -> Detent.Identifier {
        guard active == true else {
            return detents.first!.identifier
        }
        let context = Context(containerTraitCollection: traitCollection, maximumDetentValue: layoutInfo.maximumDetentValue())
        let smallestActive = detents.first { $0.resolvedValue(in: context) != nil }
        /// UIKit requires at least one active detent.
        return smallestActive!.identifier
    }
    
    func smallestActiveDetent() -> Detent {
        let context = Context(containerTraitCollection: traitCollection, maximumDetentValue: layoutInfo.maximumDetentValue())
        let smallestActive = detents.first { $0.resolvedValue(in: context) != nil }
        /// UIKit requires at least one active detent.
        return smallestActive!
    }
}
