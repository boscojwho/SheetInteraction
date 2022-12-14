//
//  DetentResolutionContext.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-11.
//

import UIKit

/// A generic detent resolution context that can be used to get a detent's `resolvedValue`.
public final class Context: NSObject, UISheetPresentationControllerDetentResolutionContext {
    /// Preferrably use `sheetPresentationController.traitCollection`.
    public let containerTraitCollection: UITraitCollection
    /// Use `sheetPresentationController.layoutInfo.maximumDetentValue()`.
    public let maximumDetentValue: CGFloat
    /// - Parameter containerTraitCollection: Preferrably use `sheetPresentationController.traitCollection`.
    /// - Parameter maximumDetentValue: Use `sheetPresentationController.layoutInfo.maximumDetentValue()`.
    init(containerTraitCollection: UITraitCollection, maximumDetentValue: CGFloat) {
        self.containerTraitCollection = containerTraitCollection
        self.maximumDetentValue = maximumDetentValue
    }
}
