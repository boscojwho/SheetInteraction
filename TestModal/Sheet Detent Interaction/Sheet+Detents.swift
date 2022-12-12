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
}
