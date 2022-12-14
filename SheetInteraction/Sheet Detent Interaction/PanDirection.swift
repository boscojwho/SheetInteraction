//
//  PanDirection.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-06.
//

import UIKit

public extension UIPanGestureRecognizer {
    
    struct Directions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let stationary = Directions(rawValue: 1 << 0)
        public static let up = Directions(rawValue: 1 << 1)
        public static let down = Directions(rawValue: 1 << 2)
        public static let left = Directions(rawValue: 1 << 3)
        public static let right = Directions(rawValue: 1 << 4)
        
        public static let all: [Directions] = [.stationary, .up, .down, .left, .right]
        
        public var hasVerticalComponent: Bool {
            contains(.up) || contains(.down)
        }
        
        public var hasHorizontalComponent: Bool {
            contains(.left) || contains(.right)
        }
        
        public var isStationary: Bool {
            contains(.stationary)
        }
        
        public var debugDescription: String {
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
