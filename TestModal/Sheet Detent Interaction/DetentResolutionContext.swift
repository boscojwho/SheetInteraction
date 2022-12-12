//
//  DetentResolutionContext.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-11.
//

import UIKit

final class Context: NSObject, UISheetPresentationControllerDetentResolutionContext {
    let containerTraitCollection: UITraitCollection
    let maximumDetentValue: CGFloat
    init(containerTraitCollection: UITraitCollection, maximumDetentValue: CGFloat) {
        self.containerTraitCollection = containerTraitCollection
        self.maximumDetentValue = maximumDetentValue
    }
}
