//
//  SheetTableView.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-26.
//

import UIKit

class SheetTableView: UITableView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let isInside = super.point(inside: point, with: event)
        AppDelegate.logger.debug("\(Self.self).\(#function) - \(isInside)")
        AppDelegate.logger.debug("\(Self.self).allTouches: \(event?.allTouches?.count ?? 0)")
        if event?.allTouches?.isEmpty == false {
            
        }
        return isInside
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        AppDelegate.logger.debug("\(Self.self).\(#function) - \(hitView)")
        return hitView
    }
}
