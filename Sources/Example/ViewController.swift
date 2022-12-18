//
//  ViewController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-11-21.
//

import UIKit
import SheetInteraction_SPM

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
            ._small(), ._medSmall(), ._medium(), ._medLarge(), ._large(), ._full()
        ]
        /// Set undimmed to allow pass-through interaction on presenting view controller.
        nc.sheetPresentationController?.largestUndimmedDetentIdentifier = .init(rawValue: "large")
        
        present(nc, animated: true, completion: completion)
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
            showModalSheet(animated: false) {
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
            window.addSubview(topInset)
            
            let sheetTopInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.origin.y + topSheetInsets.top), size: .init(width: window.frame.width, height: 1)))
            sheetTopInset.backgroundColor = .purple
            sheetTopInset.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(sheetTopInset)
            
            /// This will not be visible on home button devices, as should be the case.
            let bottomInset = UIView.init(frame: .init(origin: .init(x: 0, y: window.frame.height-topSheetInsets.bottom), size: .init(width: window.frame.width, height: 1)))
            bottomInset.backgroundColor = .green
            bottomInset.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(bottomInset)
            
            let maxDetentValue = sheetPresentationController.layoutInfo.maximumDetentValue()
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
            
            let y4 = window.frame.height - 56 - topSheetInsets.bottom
            let smallDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y4), size: .init(width: window.frame.width, height: 1)))
            smallDetent.backgroundColor = .systemPink
            smallDetent.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(smallDetent)
            
            let largeDetentMultiplier = 0.95
            let y5 = (maxDetentValue * (1 - largeDetentMultiplier)) + topSheetInsets.top
            let largeDetent = UIView.init(frame: .init(origin: .init(x: 0, y: y5), size: .init(width: window.frame.width, height: 1)))
            largeDetent.backgroundColor = .systemBrown
            largeDetent.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(largeDetent)
            
            struts.append(contentsOf: [topInset, sheetTopInset, bottomInset, mediumDetent, medLargeDetent, medSmallDetent, smallDetent, largeDetent])
        }
    }
}

extension ViewController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        let value = {
            if interactionChange.percentageApproaching.isInfinite {
                return interactionChange.percentageTotal
            } else if interactionChange.percentageApproaching.isNaN {
                return interactionChange.percentageTotal
            } else {
                return interactionChange.percentageApproaching
            }
        }()
        debugLabel.text = "Detent: \(interactionChange.approaching.detentIdentifier.rawValue), %: \(value)"
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        debugLabel.text = "Detent: \(targetDetentInfo.detentIdentifier.rawValue), %: \(targetPercentageTotal)"
    }
}