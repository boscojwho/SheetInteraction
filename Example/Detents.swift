//
//  Detents.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-07.
//

import UIKit


extension UISheetPresentationController.Detent.Identifier {
    static let _small: Self = .init("small")
    static let _medSmall: Self = .init("medSmall")
    static let _medium: Self = .init("medium")
    static let _medLarge: Self = .init("medLarge")
    static let _large: Self = .init("large")
    static let _full: Self = .init("full")
}

/*
 Modal Sheet Layout
 The following info relates to the visual presentatio of modal page sheets in iOS .phone idiom devices.
 
 A resolution context's maximumDetentValue reflects the amount of space a sheet stack's **top sheet** has to present itself. While this value takes into consideration the safe area as it relates to user interaction (i.e. unobstructed touch input), it does not ensure a top sheet is always visible. Specifically, any value within maximumDetentValue * 0.0...1.0 ensures the top sheet can be safely touched without interference from the home indicator or status bar. But some values within this range may result in the top sheet being rendered just outside a sheet's window.
 
 When resolver returns context.maximumDetentValue * 0, the sheet view's top edge is equal to the window's height minus safeAreaInsets.bottom.
 When resolver returns context.maximumDetentValue * 1, the sheet view's top edge is equal to the window's origin.y plus safeAreaInsets.top.
 
 On .phone device idiom, the system performs sheet layout differently based on whether the device has a home button or home indicator.
 
 #Home Indicator Devices
 For example, on iPhone 14 Pro, where device height is 852 points, window.frame.height - window.safeAreaInsets.top - window.safeAreaInsets.bottom = 759.0, while context.maximumDetentValue = 749.0.
 That *extra* 10 points reflects that extra space where the sheet(s) behind the top sheet appear when the top sheet is in full height (i.e. iOS's system appearance where the sheets behind are visually tucked underneath with a slightly minimized appearance).
 
 #Home Button Devices
 On home button devices, the system places a sheet stack's true top edge at the window's top safe area inset *plus* an additional 10 points. The extra 10 points probably reflects a visual design decision.
 The top sheet is then place an additional 10 points lower from the sheet underneath.
 The resolution context's maximumDetentValue accounts for the above insets. For example, on iPhone SE (3rd generation), device height is 667 points, while resolutionContext.maximumDetentValue = 627 points. The status bar accounts for 20 points, and the distance between the status bar and the top edge of the top sheet accounts for the remaining 20 points.
 Oddly enough, if a custom detent is set to 0, the system lays out the top sheet such that its top edge is just off-screen above the home button.
 */
extension UISheetPresentationController.Detent {
    
    class func _small() -> UISheetPresentationController.Detent {
        .custom(identifier: ._small) { context in
            /// This should not be 0, as the resolutionContext.maximumDetentValue does not appear to account for visual presentation.
            /// We may wish to provide different values here for home button vs home indicator devices.
            56
        }
    }
    
    class func _medSmall() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medSmall) { context in
            context.maximumDetentValue * 0.33
        }
    }
    
    class func _medium() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medium) { context in
            context.maximumDetentValue * 0.5
        }
    }
    
    class func _medLarge() -> UISheetPresentationController.Detent {
        .custom(identifier: ._medLarge) { context in
            context.maximumDetentValue * 0.67
        }
    }
    
    class func _large() -> UISheetPresentationController.Detent {
        .custom(identifier: ._large) { context in
            context.maximumDetentValue * 0.95
        }
    }
    
    class func _full() -> UISheetPresentationController.Detent {
        .custom(identifier: ._full) { context in
            context.maximumDetentValue
        }
    }
}
