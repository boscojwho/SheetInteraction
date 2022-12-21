//
//  TableViewController.swift
//  SheetInteraction
//
//  Created by Bosco Ho on 2022-12-02.
//

import UIKit
import SheetInteraction_SPM

class TableViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var observesSheetInteraction: Bool = false
    private lazy var sheetInteraction: SheetInteraction = .init(sheet: sheetPresentationController!, sheetView: view)
    
    private var activeDetent: UISheetPresentationController.Detent.Identifier = ._small {
        didSet {
            guard oldValue != activeDetent else {
                return
            }
            tableView.performBatchUpdates {
                tableView.reloadSections(.init(integersIn: 0..<4), with: .automatic)
            }
        }
    }
    
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func showModal(_ sender: Any) {
        showModalSheet(animated: true)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        guard navigationController?.isRootModal() == false else {
            return
        }
        presentingViewController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if observesSheetInteraction == true {
            sheetInteraction.sheetInteractionGesture.delegate = self
            sheetInteraction.delegate = self
        }
        
        if let vcIndex = navigationController?.viewControllers.firstIndex(of: self) {
            let ncIndex = navigationController?.levelInModalHierarchy() ?? 0
            navigationItem.title = "Modal \(ncIndex).\(vcIndex)"
        }
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// This method doesn't allow us to determine when sheet interaction begins, changes, or ends.
        /// We also cannot disambiguate between sheet interaction events and other events that trigger layout.
        /// Ensure we use view that contains navigation bar, if sheet stack is embedded in a navigation controller.
        /*
        if let sheetPresentationController, let window = view.window, let sheetView = navigationController?.view {
            ///  Use both view origin and size to determine detent state.
            ///  Determine whch direction sheet is moving?
            ///  - Can't use touch events in here or in navigation controller because those get cancelled.
//            let frame = sheetView.convert(sheetView.frame, to: window)
//            print(#function, "origin: \(frame.origin)", "size: \(frame.size)")
//            if frame.height < sheetPresentationController.topSheetInsets.bottom + 100 {
//                UIView.animate(withDuration: 0.3) {
//                    self.tableView.alpha = 0
//                }
//            } else {
//                UIView.animate(withDuration: 0.3) {
//                    self.tableView.alpha = 1
//                }
//            }
        }
         */
    }
}

extension TableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 5 {
            return 30
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 4:
            switch activeDetent {
            case ._full:
                return 30
            default:
                return 0
            }
        case 3:
            switch activeDetent {
            case ._full, ._large:
                return 30
            default:
                return 0
            }
        case 2:
            switch activeDetent {
            case ._full, ._large, ._medLarge:
                return 30
            default:
                return 0
            }
        case 1:
            switch activeDetent {
            case ._full, ._large, ._medLarge, ._medium:
                return 30
            default:
                return 0
            }
        case 0:
            switch activeDetent {
            case ._full, ._large, ._medLarge, ._medium, ._medSmall:
                return 30
            default:
                return 0
            }
        default:
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
}

extension TableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TableViewController: UISheetPresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard navigationController?.isRootModal() == false else {
            return false
        }
        return true
    }
    
    func presentationController(_ presentationController: UIPresentationController, prepare adaptivePresentationController: UIPresentationController) {
        AppDelegate.logger.debug(#function)
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        AppDelegate.logger.debug("\(#function) - \(sheetPresentationController.identifierForSelectedDetent().rawValue)")
    }
}

extension TableViewController: SheetInteractionDelegate {
    
    func sheetInteractionChanged(sheetInteraction: SheetInteraction, interactionChange: SheetInteraction.Change) {
        if let delegate = presentingViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionChanged(sheetInteraction: sheetInteraction, interactionChange: interactionChange)
        }
        
        activeDetent = interactionChange.approaching.detentIdentifier
        
        /// Update/animate UI elements based on sheet's total percentage animated from smallest detent to largest detent, where 0 is the smallest detent.
        /// Note that overscroll values are also reported.
        detailsButton.alpha = interactionChange.percentageTotal
        
        /// Example of running percent-driven animations tied to a particular detent while user is actively interacting with a sheet stack
        /// The `percentageAnimating` is always reported such that its value approaches `1` when sheet is moving up, and vice-versa.
        sheetInteraction.animating(._medSmall, interactionChange: interactionChange) { percentageAnimating in
            AppDelegate.logger.debug("_medSmall: \(percentageAnimating)")
            segmentedControl.alpha = percentageAnimating
        }
        sheetInteraction.animating(._small, interactionChange: interactionChange) { percentageAnimating in
            AppDelegate.logger.debug("_small: \(percentageAnimating)")
            doneButton.alpha = percentageAnimating
        }
    }
    
    func sheetInteractionEnded(sheetInteraction: SheetInteraction, targetDetentInfo: SheetInteraction.Change.Info, targetPercentageTotal: CGFloat, onTouchUpPercentageTotal: CGFloat) {
        if let delegate = presentingViewController as? SheetInteractionDelegate {
            delegate.sheetInteractionEnded(sheetInteraction: sheetInteraction, targetDetentInfo: targetDetentInfo, targetPercentageTotal: targetPercentageTotal, onTouchUpPercentageTotal: onTouchUpPercentageTotal)
        }
        
        activeDetent = targetDetentInfo.detentIdentifier
        
        detailsButton.alpha = targetPercentageTotal
        
        /// On touch up, update UI elements when sheet rests at or above a specifc detent.
        if let target = sheetInteraction.sheetController.detent(withIdentifier: targetDetentInfo.detentIdentifier) {
            /// If target detent is greater than `small`.
            if target.greaterThan(._small(), in: sheetInteraction.sheetController) == true {
                doneButton.alpha = 1
            } else {
                doneButton.alpha = 0
            }
            
            /// If target detent is greater than `medSmall`.
            if target.greaterThan(._medSmall(), in: sheetInteraction.sheetController) == true {
                segmentedControl.alpha = 1
            } else {
                segmentedControl.alpha = 0
            }
        }
    }
}

extension TableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == sheetInteraction.sheetInteractionGesture {
            return true
        }
        return false
    }
}

/// This method doesn't work because UIKit will intercept touches associated with sheet.
/*
extension TableViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        super.touchesCancelled(touches, with: event)
    }
}
 */

/// This method doesn't work if user interacts with sheet using grabber, navigation bar, or anywhere outside scroll view.
extension TableViewController: UIScrollViewDelegate {
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print(#function)
//    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        print(#function)
//        AppDelegate.logger.debug("\(self.sheetPresentationController!.selectedDetentIdentifier!.rawValue)")
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print(#function)
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(#function)
//    }
//
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        print(#function)
//        AppDelegate.logger.debug("\(self.sheetPresentationController!.selectedDetentIdentifier!.rawValue)")
//    }
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print(#function)
//        AppDelegate.logger.debug("\(self.sheetPresentationController!.selectedDetentIdentifier!.rawValue)")
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print(#function)
//        AppDelegate.logger.debug("\(self.sheetPresentationController!.selectedDetentIdentifier!.rawValue)")
//    }
}
