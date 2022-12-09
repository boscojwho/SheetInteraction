//
//  NavigationController+Modal.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-08.
//

import UIKit.UINavigationController

extension UINavigationController {
    
    func isRootModal() -> Bool {
        return levelInModalHierarchy() == 0
    }
    
    func levelInModalHierarchy() -> Int {
        var level = 0
        var presenting = presentingViewController
        while presenting is UINavigationController {
            presenting = presenting?.presentingViewController
            level += 1
        }
        return level
    }
}
