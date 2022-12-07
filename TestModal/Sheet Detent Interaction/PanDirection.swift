//
//  PanDirection.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-06.
//

import UIKit

extension UIPanGestureRecognizer {
    
    struct Directions: OptionSet {
        let rawValue: Int
        
        static let stationary = Directions(rawValue: 1 << 0)
        static let up = Directions(rawValue: 1 << 1)
        static let down = Directions(rawValue: 1 << 2)
        static let left = Directions(rawValue: 1 << 3)
        static let right = Directions(rawValue: 1 << 4)
        
        static let all: [Directions] = [.stationary, .up, .down, .left, .right]
        
        var hasVerticalComponent: Bool {
            contains(.up) || contains(.down)
        }
        
        var hasHorizontalComponent: Bool {
            contains(.left) || contains(.right)
        }
        
        var isStationary: Bool {
            contains(.stationary)
        }
        
        var debugDescription: String {
            guard contains(.stationary) == false else {
                return "stationary"
            }
            var desc = ""
            if contains(.up) {
                desc += "up, "
            }
            if contains(.down) {
                desc += "down, "
            }
            if contains(.left) {
                desc += "left, "
            }
            if contains(.right) {
                desc += "right, "
            }
            return desc
        }
    }
    
    var directions: Directions {
        let velocity = self.velocity(in: view)
        let y = velocity.y
        let x = velocity.x
        if x == 0 && y == 0 {
            return .stationary
        }
        let yComponent: Directions = y > 0 ? .down : .up
        let xComponent: Directions = x > 0 ? .right : .left
        return [xComponent, yComponent]
    }
}
