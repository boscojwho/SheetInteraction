//
//  TableViewController.swift
//  TestModal
//
//  Created by BozBook Air on 2022-12-02.
//

import UIKit

class TableViewController: UITableViewController {
    
    @IBAction func showModal(_ sender: Any) {
        let nc = storyboard!.instantiateViewController(withIdentifier: "navCon")
        nc.modalPresentationStyle = .pageSheet
        nc.isModalInPresentation = false
        nc.sheetPresentationController?.delegate = self
        let small = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "small")) { context in
            return 120
        }
        let large = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "large")) { context in
            return context.maximumDetentValue * 0.98
        }
        nc.sheetPresentationController?.detents = [
            small, .medium(), large
        ]
        /// Set undimmed to allow pass-through interaction on presenting view controller.
        nc.sheetPresentationController?.largestUndimmedDetentIdentifier = .init(rawValue: "large")
        present(nc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let origin = view.convert(view.frame.origin, to: view.window!)
        print(#function, "y: \(origin.y)")

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
        return true
    }
    
    func presentationController(_ presentationController: UIPresentationController, prepare adaptivePresentationController: UIPresentationController) {
        print(#function)
    }
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier)
    }
}
