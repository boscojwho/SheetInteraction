//
//  TableViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-02.
//

import UIKit

extension UISheetPresentationController {
    
    /// The vertical space required to display the bottom sheet in "minimized" state when the top sheet is displayed in full height.
    /// This **does not** vary based on device.
    private static let bottomSheetPeekThroughHeight: CGFloat = 10.0
    
    private var bottomSheetTopInset: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            /// This additional inset is likely a visual design consideration made by Apple, and is not present on home indicator devices. [2022.12]
            let additionalTopInset: CGFloat = 10
            return window.safeAreaInsets.top + additionalTopInset
        } else {
            return window.safeAreaInsets.top
        }
    }

    private var topSheetTopInset: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0
        }
        if window.safeAreaInsets.bottom == 0 {
            return bottomSheetTopInset + UISheetPresentationController.bottomSheetPeekThroughHeight
        } else {
            return window.safeAreaInsets.top + UISheetPresentationController.bottomSheetPeekThroughHeight
        }
    }
    
    private var sheetBottomInset: CGFloat {
        guard let window = UIApplication.shared.keyWindow else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }
    
    /// Layout insets inside window for the bottom sheet (visually underneath) in a sheet stack.
    var bottomSheetInsets: UIEdgeInsets {
        .init(top: bottomSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
    
    /// Layout insets inside window for the top sheet (visually on top) in a sheet stack.
    var topSheetInsets: UIEdgeInsets {
        .init(top: topSheetTopInset, left: 0, bottom: sheetBottomInset, right: 0)
    }
}

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

class TableViewController: UITableViewController {
    
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
        if let vcIndex = navigationController?.viewControllers.firstIndex(of: self) {
            let ncIndex = navigationController?.levelInModalHierarchy() ?? 0
            navigationItem.title = "Modal \(ncIndex).\(vcIndex)"
        }
        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let sheetPresentationController, let window = view.window {
            let topInsets = sheetPresentationController.topSheetInsets
            let topSheetFrame = window.frame.inset(by: topInsets)
            let mediumDetent = topSheetFrame.height/2
            print("medium: \(mediumDetent)")
            
            let origin = view.convert(view.frame, to: window)
            print(#function, "y: \(origin.minY), \(sheetPresentationController.selectedDetentIdentifier?.rawValue ?? "n/a")")
        }
    }
}

extension TableViewController {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(#function)
    }
        
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(#function)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(#function)
        print(sheetPresentationController?.selectedDetentIdentifier?.rawValue ?? "n/a")
    }
    
    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(#function)
    }
    
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print(#function)
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
        print(#function)
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier ?? sheetPresentationController.detents.first!)
    }
}
