//
//  DetentResolutionContext.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-11.
//

import UIKit

public final class Context: NSObject, UISheetPresentationControllerDetentResolutionContext {
    public let containerTraitCollection: UITraitCollection
    public let maximumDetentValue: CGFloat
    init(containerTraitCollection: UITraitCollection, maximumDetentValue: CGFloat) {
        self.containerTraitCollection = containerTraitCollection
        self.maximumDetentValue = maximumDetentValue
    }
}
