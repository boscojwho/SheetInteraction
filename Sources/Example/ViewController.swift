//
//  ViewController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-11-21.
//

import UIKit
import SheetInteraction_SPM

extension UIViewController {
    
    func showModalSheet(embedded embeddedInNavigationController: Bool = true, animated: Bool, completion: (() -> Void)? = nil) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        
        if embeddedInNavigationController == true {
            let nc = SheetInteractionNavigationController(rootViewController: vc)
            
            nc.modalPresentationStyle = .pageSheet
            /// Use delegate to prevent interactive dismissal while also allowing user interaction outside view controller bounds. [2022.12]
            //        nc.isModalInPresentation = true
            nc.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
//            nc.sheetPresentationController?.delegate = vc
            nc.sheetPresentationController?.detents = [
                ._small(), ._medSmall(), ._medium(), ._medLarge(), ._large(), ._full()
            ]
            /// Set undimmed to allow pass-through interaction on presenting view controller.
            nc.sheetPresentationController?.largestUndimmedDetentIdentifier = ._large
            nc.sheetPresentationController?.selectedDetentIdentifier = ._medSmall
            present(nc, animated: true, completion: completion)
        } else {
            vc.modalPresentationStyle = .pageSheet
            vc.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
//            vc.sheetPresentationController?.delegate = vc
            vc.sheetPresentationController?.detents = [
                ._small(), ._medSmall(), ._medium(), ._medLarge(), ._large(), ._full()
            ]
            vc.sheetPresentationController?.largestUndimmedDetentIdentifier = ._large
            vc.sheetPresentationController?.selectedDetentIdentifier = ._medSmall
            vc.observesSheetInteraction = true
            present(vc, animated: true, completion: completion)
        }
    }
}

class ViewController: UIViewController {
    
    private lazy var debugLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.backgroundColor = .white
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.text = "Detent: -, %: -"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var struts: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first {
            window.addSubview(debugLabel)
            debugLabel.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
            debugLabel.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            showModalSheet(embedded: true, animated: false) {
                self.showStruts()
                self.debugLabel.window?.bringSubviewToFront(self.debugLabel)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /// Reset strut positions after size change.
        /// Reset after animation so we get the correct safe area insets (i.e. on device rotation).
        coordinator.animate { _ in
            self.showStruts()
        }
    }
    
    private func showStruts() {
        if let window = view.window, let sheetPresentationController = presentedViewController?.sheetPresentationController {
            struts.forEach {
                $0.removeFromSuperview()
            }
            
            let topSheetInsets = sheetPresentationController.layoutInfo.topSheetInsets
            let bottomSheetInsets = sheetPresentationController.layoutInfo.bottomSheetInsets
            
            let topInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.origin.y + bottomSheetInsets.top), size: .init(width: window.frame.width, height: 1)))
            topInset.backgroundColor = .red
            topInset.translatesAutoresizingMaskIntoConstraints = false
            topInset.accessibilityIdentifier = "struts.topInset"
            window.addSubview(topInset)
            
            let fullDetent = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.origin.y + topSheetInsets.top), size: .init(width: window.frame.width, height: 1)))
            fullDetent.backgroundColor = .purple
            fullDetent.translatesAutoresizingMaskIntoConstraints = false
            fullDetent.accessibilityIdentifier = "struts.fullDetent"
            window.addSubview(fullDetent)
            
            /// This will not be visible on home button devices, as should be the case.
            let bottomInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.height-topSheetInsets.bottom), size: .init(width: window.frame.width, height: 1)))
            bottomInset.backgroundColor = .green
            bottomInset.translatesAutoresizingMaskIntoConstraints = false
            bottomInset.accessibilityIdentifier = "struts.bottomInset"
            window.addSubview(bottomInset)
            
            let maxDetentValue = sheetPresentationController.layoutInfo.maximumDetentValue()
            let detentMultiplier = 0.5
            /// 1 - detentMultiplier to get the yOrigin. We need to add top insets because origin starts from top-left at 0 value, and maximumDetentValue excludes top inset value.
            let y = (maxDetentValue * (1 - detentMultiplier)) + topSheetInsets.top
            let mediumDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y), size: .init(width: window.frame.width, height: 1)))
            mediumDetent.backgroundColor = .orange
            mediumDetent.translatesAutoresizingMaskIntoConstraints = false
            mediumDetent.accessibilityIdentifier = "struts.mediumDetent"
            window.addSubview(mediumDetent)
            
            let medLargeDetentMultiplier = 0.67
            let y2 = (maxDetentValue * (1 - medLargeDetentMultiplier)) + topSheetInsets.top
            let medLargeDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y2), size: .init(width: window.frame.width, height: 1)))
            medLargeDetent.backgroundColor = .black
            medLargeDetent.translatesAutoresizingMaskIntoConstraints = false
            medLargeDetent.accessibilityIdentifier = "struts.medLargeDetent"
            window.addSubview(medLargeDetent)
            
            let medSmallDetentMultiplier = 0.33
            let y3 = (maxDetentValue * (1 - medSmallDetentMultiplier)) + topSheetInsets.top
            let medSmallDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y3), size: .init(width: window.frame.width, height: 1)))
            medSmallDetent.backgroundColor = .cyan
            medSmallDetent.translatesAutoresizingMaskIntoConstraints = false
            medSmallDetent.accessibilityIdentifier = "struts.medSmallDetent"
            window.addSubview(medSmallDetent)
            
            let y4 = window.frame.height - 56 - topSheetInsets.bottom
            let smallDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y4), size: .init(width: window.frame.width, height: 1)))
            smallDetent.backgroundColor = .systemPink
            smallDetent.translatesAutoresizingMaskIntoConstraints = false
            smallDetent.accessibilityIdentifier = "struts.smallDetent"
            window.addSubview(smallDetent)
            
            let largeDetentMultiplier = 0.95
            let y5 = (maxDetentValue * (1 - largeDetentMultiplier)) + topSheetInsets.top
            let largeDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y5), size: .init(width: window.frame.width, height: 1)))
            largeDetent.backgroundColor = .systemBrown
            largeDetent.translatesAutoresizingMaskIntoConstraints = false
            largeDetent.accessibilityIdentifier = "struts.largeDetent"
            window.addSubview(largeDetent)
            
            struts.append(contentsOf: [topInset, fullDetent, bottomInset, mediumDetent, medLargeDetent, medSmallDetent, smallDetent, largeDetent])
        }
    }
}

extension ViewController: SheetInteractionDelegate {
    
    func sheetInteractionBegan(sheetInteraction: SheetInteraction, at detent: DetentIdentifier) {
        print(#function)
    }
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        let value = {
            guard interactionChange.isOverscrolling == false else {
                return interactionChange.percentageTotal
            }
            return interactionChange.percentageApproaching
        }()
        debugLabel.text = "Detent: \(interactionChange.approaching.detentIdentifier.rawValue), %: \(value)"
    }
    
    func sheetInteractionWillEnd(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        debugLabel.text = "Detent: \(targetDetentInfo.detentIdentifier.rawValue), %: \(targetPercentageTotal)"
    }
    
    func sheetInteractionDidEnd(sheetInteraction: SheetInteraction, selectedDetentIdentifier: UISheetPresentationController.Detent.Identifier) {
        debugLabel.text = "Detent: \(selectedDetentIdentifier.rawValue), %: \(sheetInteraction.totalPercentageAnimated())"
    }
    
    func sheetInteractionShouldDismiss(sheetInteraction: SheetInteraction) -> Bool {
        /// Not part of a sheet stack.
        return false
    }
    
    func sheetInteractionWillDismiss(sheetInteraction: SheetInteraction) {
        print(#function)
    }
    
    func sheetInteractionDidDismiss(sheetInteraction: SheetInteraction) {
        print(#function)
    }
}
