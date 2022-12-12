//
//  SheetPresentationController.swift
//  TestModal
//
//  Created by Bosco Ho on 2022-12-07.
//

import UIKit

// MARK: - Detents
extension UISheetPresentationController {
    
    /// - Returns: First detent in `detents`, instead of `nil`.
    func identifierForSelectedDetent() -> Detent.Identifier {
        selectedDetentIdentifier ?? detents.first!.identifier
    }
    
    func detent(withIdentifier identifier: Detent.Identifier) -> Detent? {
        detents.first { $0.identifier == identifier }
    }
}

// MARK: - Layout Info
extension UISheetPresentationController {
    
    var layoutInfo: SheetLayoutInfo {
        .init(sheet: self, window: presentedView!.window!)
    }
}
