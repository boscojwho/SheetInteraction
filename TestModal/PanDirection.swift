//
//  PanDirection.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-06.
//

import UIKit

extension UIPanGestureRecognizer {
    
    enum Direction: String {
        case up, down
        case left, right
        case stationary
        
        var isVertical: Bool {
            switch self {
            case .up, .down:
                return true
            case .left, .right:
                return false
            case .stationary:
                return false
            }
        }
        
        var isHorizontal: Bool {
            switch self {
            case .up, .down:
                return false
            case .left, .right:
                return true
            case .stationary:
                return false
            }
        }
    }
    
    var direction: Direction {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0:
            return .up
        case (true, _, let y) where y > 0:
            return .down
        case (false, let x, _) where x > 0:
            return .right
        case (false, let x, _) where x < 0:
            return .left
        default:
            return .stationary
        }
    }
}
