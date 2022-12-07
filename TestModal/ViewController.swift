//
//  ViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-11-21.
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
    
    class func height(identifier: Identifier, maximumDetentValue: CGFloat) -> CGFloat? {
        switch identifier {
        case ._small:
            return 56
        case ._medSmall:
            return maximumDetentValue * 0.33
        case ._medium:
            return maximumDetentValue * 0.5
        case ._medLarge:
            return maximumDetentValue * 0.67
        case ._large:
            return maximumDetentValue * 0.98
        case ._full:
            return maximumDetentValue
        default:
            return nil
        }
    }
    
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
            context.maximumDetentValue * 0.98
        }
    }
    
    class func _full() -> UISheetPresentationController.Detent {
        .custom(identifier: ._full) { context in
            context.maximumDetentValue
        }
    }
}

extension UIViewController {
    
    func showModalSheet(animated: Bool, completion: (() -> Void)? = nil) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "TableViewController")
        let nc = SheetNavigationController(rootViewController: vc)

        nc.modalPresentationStyle = .pageSheet
        /// Use delegate to prevent interactive dismissal while also allowing user interaction outside view controller bounds. [2022.12]
//        nc.isModalInPresentation = true
        nc.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
        nc.sheetPresentationController?.delegate = vc as? UISheetPresentationControllerDelegate
        nc.sheetPresentationController?.detents = [
            ._small(), ._medSmall(), ._medium(), ._medLarge(), ._full()
        ]
        /// Set undimmed to allow pass-through interaction on presenting view controller.
        nc.sheetPresentationController?.largestUndimmedDetentIdentifier = .init(rawValue: "large")
        
        present(nc, animated: true, completion: completion)
    }
}

class ViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            showModalSheet(animated: false) {
                self.showStruts()
            }
        }
    }
    
    private func showStruts() {
        if let window = view.window, let sheetPresentationController = presentedViewController?.sheetPresentationController {
            let topSheetInsets = sheetPresentationController.topSheetInsets
            let bottomSheetInsets = sheetPresentationController.bottomSheetInsets
            
            let topInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.origin.y + bottomSheetInsets.top), size: .init(width: window.frame.width, height: 1)))
            topInset.backgroundColor = .red
            topInset.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(topInset)
            
            let sheetTopInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.origin.y + topSheetInsets.top), size: .init(width: window.frame.width, height: 1)))
            sheetTopInset.backgroundColor = .purple
            sheetTopInset.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(sheetTopInset)
            
            /// This will not be visible, as should be the case.
            let bottomInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.height-topSheetInsets.bottom), size: .init(width: window.frame.width, height: 1)))
            bottomInset.backgroundColor = .green
            bottomInset.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(bottomInset)
            
            let maxDetentValue = sheetPresentationController.maximumDetentValue()
            let detentMultiplier = 0.5
            /// 1 - detentMultiplier to get the yOrigin. We need to add top insets because origin starts from top-left at 0 value, and maximumDetentValue excludes top inset value.
            let y = (maxDetentValue * (1 - detentMultiplier)) + topSheetInsets.top
            let mediumDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y), size: .init(width: window.frame.width, height: 1)))
            mediumDetent.backgroundColor = .orange
            mediumDetent.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(mediumDetent)
            
            let medLargeDetentMultiplier = 0.67
            let y2 = (maxDetentValue * (1 - medLargeDetentMultiplier)) + topSheetInsets.top
            let medLargeDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y2), size: .init(width: window.frame.width, height: 1)))
            medLargeDetent.backgroundColor = .black
            medLargeDetent.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(medLargeDetent)
            
            let medSmallDetentMultiplier = 0.33
            let y3 = (maxDetentValue * (1 - medSmallDetentMultiplier)) + topSheetInsets.top
            let medSmallDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y3), size: .init(width: window.frame.width, height: 1)))
            medSmallDetent.backgroundColor = .cyan
            medSmallDetent.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(medSmallDetent)
        }
    }
}
